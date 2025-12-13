package com.itheamc.paypal_payment

import FlutterError
import PayPalPaymentWebCheckoutHostApi
import PayPalWebCheckoutCanceledResultEvent
import PayPalWebCheckoutErrorResultEvent
import PayPalWebCheckoutFailureResultEvent
import PayPalWebCheckoutResultEvent
import PayPalWebCheckoutResultEventStreamHandler
import PayPalWebCheckoutSuccessResultEvent
import PigeonEventSink
import android.app.Activity
import android.content.Intent
import com.paypal.android.corepayments.CoreConfig
import com.paypal.android.paypalwebpayments.PayPalPresentAuthChallengeResult
import com.paypal.android.paypalwebpayments.PayPalWebCheckoutClient
import com.paypal.android.paypalwebpayments.PayPalWebCheckoutFinishStartResult
import com.paypal.android.paypalwebpayments.PayPalWebCheckoutFundingSource
import com.paypal.android.paypalwebpayments.PayPalWebCheckoutRequest
import io.flutter.embedding.engine.plugins.FlutterPlugin
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

/**
 * Handles PayPal web checkout flow.
 *
 * @property config The configuration for PayPal payments.
 * @property getActivity The callback to get the current activity.
 * @property getPluginBinding The callback to get the current plugin binding.
 */
class WebCheckoutHandler(
    private val config: PaypalPaymentConfig,
    private val getActivity: () -> Activity?,
    private val getPluginBinding: () -> FlutterPlugin.FlutterPluginBinding?,
) : PayPalPaymentWebCheckoutHostApi {

    /**
     * The client for handling PayPal web checkout.
     */
    private var _checkoutClient: PayPalWebCheckoutClient? = null

    /**
     * The listener for checkout result events.
     */
    private var _listener: CheckoutResultEventListener? = null

    /**
     * The flag to check if the checkout on intent is called or not
     */
    private var _isCheckoutOnIntentCalled = false

    /**
     * Currently processing order id
     */
    private var _currentlyProcessingOrderId: String? = null

    init {
        getPluginBinding()?.let {
            PayPalPaymentWebCheckoutHostApi.setUp(it.binaryMessenger, this)
        }
    }

    /**
     * Initiates the PayPal web checkout.
     *
     * @param orderId The ID of the order to be processed.
     * @param fundingSource The funding source for the payment.
     * @throws FlutterError if the activity, binding, or PayPal configuration is null.
     */
    override fun startCheckout(
        orderId: String,
        fundingSource: String
    ) {
        // STEP 1: Make checkout intent called variable false and set the
        // currently processing order id
        _isCheckoutOnIntentCalled = false
        _currentlyProcessingOrderId = orderId

        // STEP 2: Initialize & register Result Listener
        _listener = CheckoutResultEventListener()

        PayPalWebCheckoutResultEventStreamHandler.register(
            getPluginBinding()!!.binaryMessenger,
            _listener!!
        )

        if (config.clientId == null) {
            _listener?.onError("SDK not initialized")
            _listener = null
            _currentlyProcessingOrderId = null
            return
        }

        // STEP 3: Creating Configuration Object for Paypal Payment
        val config = CoreConfig(
            config.clientId!!,
            config.toPaypalEnvironment()
        )

        // STEP 4: Initializing Checkout Client
        _checkoutClient = PayPalWebCheckoutClient(
            context = getActivity()!!,
            configuration = config,
            urlScheme = "itheamc://paypal"
        )

        // STEP 5: Starting Checkout Request
        _checkoutClient?.start(
            activity = getActivity()!!,
            request = PayPalWebCheckoutRequest(
                orderId = orderId,
                fundingSource = fundingSource.toPayPalWebCheckoutFundingSource()
            ),
            callback = { result ->
                when (result) {
                    is PayPalPresentAuthChallengeResult.Failure -> {
                        _listener?.onFailure(
                            orderId = orderId,
                            reason = result.error.errorDescription,
                            code = result.error.code,
                            correlationId = result.error.correlationId
                        )
                    }

                    is PayPalPresentAuthChallengeResult.Success -> {
                        // Do nothing here
                    }
                }
            }
        )
    }

    /**
     * Handles the result from the PayPal web checkout flow.
     *
     * @param intent The intent containing the result data.
     * @return `true` if the intent was handled, `false` otherwise.
     */
    fun onNewIntent(intent: Intent): Boolean {
        if (intent.scheme == "itheamc") {
            // STEP 6: Make checkout intent called variable true
            _isCheckoutOnIntentCalled = true

            // STEP 7: Finish Start Checkout
            when (val result = _checkoutClient?.finishStart(intent)) {
                is PayPalWebCheckoutFinishStartResult.Canceled -> {
                    _listener?.onCanceled(
                        orderId = result.orderId,
                    )
                }

                is PayPalWebCheckoutFinishStartResult.Failure -> {
                    _listener?.onFailure(
                        orderId = result.orderId,
                        reason = result.error.errorDescription,
                        code = result.error.code,
                        correlationId = result.error.correlationId
                    )
                }

                PayPalWebCheckoutFinishStartResult.NoResult -> {
                    _listener?.onSuccess(
                        orderId = intent.data?.getQueryParameter("token"),
                        payerId = intent.data?.getQueryParameter("PayerID")
                    )
                }

                is PayPalWebCheckoutFinishStartResult.Success -> {
                    _listener?.onSuccess(
                        orderId = result.orderId,
                        payerId = result.payerId
                    )
                }

                null -> {
                    _listener?.onError("Something went wrong")
                }
            }

            // STEP 6: Reset client and listener
            _checkoutClient = null
            _listener = null
            _currentlyProcessingOrderId = null
            return true
        }
        return false
    }

    /**
     * Handles the lifecycle event when the app is resumed.
     *
     * This method checks if the user has returned to the app without completing the
     * checkout process via the deep link (`onNewIntent`). This can happen, for example,
     * if the user manually navigates back to the app or closes the browser.
     *
     * If `onNewIntent` was not called and a checkout session is active, it waits for a
     * brief moment (2 seconds) to ensure it's not a false positive, then cancels the
     * checkout process, sends a cancellation event, and cleans up the associated resources.
     *
     * The early return `if (_isCheckoutOnIntentCalled) return` prevents this cancellation
     * logic from running if the checkout flow has already been handled by `onNewIntent`.
     */
    fun onResume() {
        if (_checkoutClient != null && _listener != null) {
            CoroutineScope(Dispatchers.Main).launch {
                delay(2000)

                // If the checkout flow has already been handled by onNewIntent, return early
                if (_isCheckoutOnIntentCalled) return@launch

                // Cancel the checkout process and send a cancellation event
                _listener?.onCanceled(_currentlyProcessingOrderId)

                _checkoutClient = null
                _listener = null
                _currentlyProcessingOrderId = null
            }
        }
    }

    /**
     * An event listener for PayPal web checkout results.
     */
    private class CheckoutResultEventListener : PayPalWebCheckoutResultEventStreamHandler() {
        private var eventSink: PigeonEventSink<PayPalWebCheckoutResultEvent>? = null

        override fun onListen(p0: Any?, sink: PigeonEventSink<PayPalWebCheckoutResultEvent>) {
            eventSink = sink
        }

        override fun onCancel(p0: Any?) {
            eventSink = null
        }

        /**
         * Handles a successful checkout.
         *
         * @param orderId The ID of the order.
         * @param payerId The ID of the payer.
         */
        fun onSuccess(
            orderId: String?,
            payerId: String?
        ) {
            eventSink?.success(
                PayPalWebCheckoutSuccessResultEvent(
                    orderId = orderId,
                    payerId = payerId
                )
            )

            end()
        }

        /**
         * Handles a failed checkout.
         *
         * @param orderId The ID of the order.
         * @param reason The reason for the failure.
         * @param code The error code.
         * @param correlationId The correlation ID for the request.
         */
        fun onFailure(
            orderId: String?,
            reason: String,
            code: Int,
            correlationId: String?
        ) {
            eventSink?.success(
                PayPalWebCheckoutFailureResultEvent(
                    orderId = orderId,
                    reason = reason,
                    code = code.toLong(),
                    correlationId = correlationId
                )
            )

            end()
        }

        /**
         * Handles a canceled checkout.
         *
         * @param orderId The ID of the order.
         */
        fun onCanceled(orderId: String?) {
            eventSink?.success(
                PayPalWebCheckoutCanceledResultEvent(
                    orderId = orderId
                )
            )

            end()
        }

        /**
         * Handles an error during checkout.
         *
         * @param error The error message.
         */
        fun onError(error: String) {
            eventSink?.success(
                PayPalWebCheckoutErrorResultEvent(
                    error = error
                )
            )

            end()
        }

        /**
         * Ends the event stream.
         */
        private fun end() {
            eventSink?.endOfStream()
            eventSink = null
        }
    }
}


/**
 * Converts a string to a [PayPalWebCheckoutFundingSource].
 *
 * @return The corresponding [PayPalWebCheckoutFundingSource], or [PayPalWebCheckoutFundingSource.PAYPAL] if the string is not recognized.
 */
private fun String.toPayPalWebCheckoutFundingSource(): PayPalWebCheckoutFundingSource {
    return when (this) {
        "paypal" -> PayPalWebCheckoutFundingSource.PAYPAL
        "credit" -> PayPalWebCheckoutFundingSource.PAYPAL_CREDIT
        "payLater" -> PayPalWebCheckoutFundingSource.PAY_LATER
        else -> PayPalWebCheckoutFundingSource.PAYPAL
    }
}