package com.itheamc.paypal_payment_flutter

import FlutterError
import PaypalWebPaymentHostApi
import PaypalWebPaymentRequestCanceledResultEvent
import PaypalWebPaymentRequestErrorResultEvent
import PaypalWebPaymentRequestFailureResultEvent
import PaypalWebPaymentRequestResultEvent
import PaypalWebPaymentRequestResultEventStreamHandler
import PaypalWebPaymentRequestSuccessResultEvent
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
 * @property getConfig The callback to get the paypal payment configuration
 * @property getActivity The callback to get the current activity.
 * @property getPluginBinding The callback to get the current plugin binding.
 */
class WebPaymentsHandler(
    private val getConfig: () -> PaypalPaymentConfig,
    private val getActivity: () -> Activity?,
    private val getPluginBinding: () -> FlutterPlugin.FlutterPluginBinding?,
) : PaypalWebPaymentHostApi {

    /**
     * The client for handling PayPal web checkout.
     */
    private var checkoutClient: PayPalWebCheckoutClient? = null

    /**
     * The listener for checkout result events.
     */
    private var listener: PaypalWebPaymentRequestResultEventListener? = null

    /**
     * The flag to check if the checkout on intent is called or not
     */
    private var isCheckoutOnIntentCalled = false

    /**
     * Currently processing order id
     */
    private var currentlyProcessingOrderId: String? = null

    init {
        getPluginBinding()?.let {
            PaypalWebPaymentHostApi.setUp(it.binaryMessenger, this)
        }
    }

    /**
     * Initiates the PayPal web checkout.
     *
     * @param orderId The ID of the order to be processed.
     * @param fundingSource The funding source for the payment.
     * @throws FlutterError if the activity, binding, or PayPal configuration is null.
     */
    override fun initiatePaymentRequest(
        orderId: String,
        fundingSource: String
    ) {
        // STEP 1: Make checkout intent called variable false and set the
        // currently processing order id
        isCheckoutOnIntentCalled = false
        currentlyProcessingOrderId = orderId

        // STEP 2: Initialize & register Result Listener
        listener = PaypalWebPaymentRequestResultEventListener()

        PaypalWebPaymentRequestResultEventStreamHandler.register(
            getPluginBinding()!!.binaryMessenger,
            listener!!
        )

        // STEP 3: Creating Configuration Object for Paypal Web Payment
        val paypalConfig = getConfig()

        if (paypalConfig.clientId == null) {
            listener?.onError("SDK not initialized")
            listener = null
            currentlyProcessingOrderId = null
            return
        }

        val config = CoreConfig(
            paypalConfig.clientId!!,
            paypalConfig.toPaypalEnvironment()
        )

        // STEP 4: Initializing Checkout Client
        checkoutClient = PayPalWebCheckoutClient(
            context = getActivity()!!,
            configuration = config,
            urlScheme = "itheamc://paypal"
        )

        // STEP 5: Creating the web checkout request
        val request = PayPalWebCheckoutRequest(
            orderId = orderId,
            fundingSource = fundingSource.toPayPalWebCheckoutFundingSource()
        )

        // STEP 6: Starting Checkout Request
        checkoutClient?.start(
            activity = getActivity()!!,
            request = request,
            callback = { result ->
                when (result) {
                    is PayPalPresentAuthChallengeResult.Failure -> {
                        listener?.onFailure(
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

        // If the checkout client or currently processing order id is null, return false
        if (checkoutClient == null || currentlyProcessingOrderId == null) return false;

        // Else if the intent scheme is "itheamc", go ahead and finish start checkout
        if (intent.scheme == "itheamc") {
            // STEP 7: Make checkout intent called variable true
            isCheckoutOnIntentCalled = true

            // STEP 8: Finish Start Checkout
            when (val result = checkoutClient?.finishStart(intent)) {
                is PayPalWebCheckoutFinishStartResult.Canceled -> {
                    listener?.onCanceled(
                        orderId = result.orderId,
                    )
                }

                is PayPalWebCheckoutFinishStartResult.Failure -> {
                    listener?.onFailure(
                        orderId = result.orderId,
                        reason = result.error.errorDescription,
                        code = result.error.code,
                        correlationId = result.error.correlationId
                    )
                }

                PayPalWebCheckoutFinishStartResult.NoResult -> {
                    listener?.onSuccess(
                        orderId = intent.data?.getQueryParameter("token"),
                        payerId = intent.data?.getQueryParameter("PayerID")
                    )
                }

                is PayPalWebCheckoutFinishStartResult.Success -> {
                    listener?.onSuccess(
                        orderId = result.orderId,
                        payerId = result.payerId
                    )
                }

                null -> {
                    listener?.onError("Something went wrong")
                }
            }

            // STEP 9: Reset client and listener
            checkoutClient = null
            listener = null
            currentlyProcessingOrderId = null
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
        if (checkoutClient != null && listener != null) {
            CoroutineScope(Dispatchers.Main).launch {
                delay(2000)

                // If the checkout flow has already been handled by onNewIntent, return early
                if (isCheckoutOnIntentCalled) return@launch

                // Cancel the checkout process and send a cancellation event
                listener?.onCanceled(currentlyProcessingOrderId)

                checkoutClient = null
                listener = null
                currentlyProcessingOrderId = null
            }
        }
    }

    /**
     * An event listener for PayPal web payment request results.
     */
    private class PaypalWebPaymentRequestResultEventListener :
        PaypalWebPaymentRequestResultEventStreamHandler() {
        private var eventSink: PigeonEventSink<PaypalWebPaymentRequestResultEvent>? = null

        override fun onListen(p0: Any?, sink: PigeonEventSink<PaypalWebPaymentRequestResultEvent>) {
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
                PaypalWebPaymentRequestSuccessResultEvent(
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
                PaypalWebPaymentRequestFailureResultEvent(
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
                PaypalWebPaymentRequestCanceledResultEvent(
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
                PaypalWebPaymentRequestErrorResultEvent(
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