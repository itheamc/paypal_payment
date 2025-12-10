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

/**
 * Handles PayPal web checkout flow.
 *
 * @property paypalPaymentConfig The configuration for PayPal payments.
 * @property activity The current Android activity.
 * @property binding The Flutter plugin binding.
 */
class WebCheckoutHandler(
    private val paypalPaymentConfig: PaypalPaymentConfig,
    private val activity: Activity?,
    private val binding: FlutterPlugin.FlutterPluginBinding?,
) : PayPalPaymentWebCheckoutHostApi {

    /**
     * The client for handling PayPal web checkout.
     */
    private var checkoutClient: PayPalWebCheckoutClient? = null

    /**
     * The listener for checkout result events.
     */
    private var listener: CheckoutResultEventListener? = null

    init {
        binding?.binaryMessenger?.let {
            PayPalPaymentWebCheckoutHostApi.setUp(it, this)
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
        if (activity == null) {
            throw FlutterError(
                code = "ACTIVITY_NULL",
                message = "Activity is null"
            )
        }

        if (binding == null) {
            throw FlutterError(
                code = "BINDING_NULL",
                message = "Binding is null"
            )
        }

        if (paypalPaymentConfig.clientId == null) {
            throw FlutterError(
                code = "SDK_NOT_INITIALIZED",
                message = "SDK not initialized"
            )
        }

        // STEP 1: Creating Configuration Object for Paypal Payment
        val config = CoreConfig(
            paypalPaymentConfig.clientId!!,
            paypalPaymentConfig.toPaypalEnvironment()
        )

        // STEP 2: Initializing Checkout Client
        checkoutClient = PayPalWebCheckoutClient(
            context = activity,
            configuration = config,
            urlScheme = "itheamc://paypal"
        )

        // STEP 3: Initialize & register Result Listener
        listener = CheckoutResultEventListener()

        PayPalWebCheckoutResultEventStreamHandler.register(
            binding.binaryMessenger,
            listener!!
        )

        // STEP 4: Starting Checkout Request
        checkoutClient?.start(
            activity = activity,
            request = PayPalWebCheckoutRequest(
                orderId = orderId,
                fundingSource = fundingSource.toPayPalWebCheckoutFundingSource()
            ),
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
        if (intent.scheme == "itheamc") {
            // STEP 5: Finish Start Checkout
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

            // STEP 6: Reset client and listener
            checkoutClient = null
            listener = null
            return true
        }
        return false
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