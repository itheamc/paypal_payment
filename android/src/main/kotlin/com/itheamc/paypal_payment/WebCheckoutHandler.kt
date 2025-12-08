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

class WebCheckoutHandler(
    private val paypalPaymentConfig: PaypalPaymentConfig?,
    private val activity: Activity?,
    private val binding: FlutterPlugin.FlutterPluginBinding?,
) : PayPalPaymentWebCheckoutHostApi {

    private var checkoutClient: PayPalWebCheckoutClient? = null
    private var listener: CheckoutResultEventListener? = null

    init {
        binding?.binaryMessenger?.let {
            PayPalPaymentWebCheckoutHostApi.setUp(it, this)
        }
    }

    override fun initiateCheckout(
        orderId: String,
        fallbackUrl: String,
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

        if (paypalPaymentConfig == null) {
            throw FlutterError(
                code = "SDK_NOT_INITIALIZED",
                message = "SDK not initialized"
            )
        }

        // STEP 1: Creating Configuration Object for Paypal Payment
        val config = CoreConfig(
            paypalPaymentConfig.clientId,
            paypalPaymentConfig.toPaypalEnvironment()
        )

        // STEP 2: Initializing Checkout Client
        checkoutClient = PayPalWebCheckoutClient(
            context = activity,
            configuration = config,
            urlScheme = fallbackUrl
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
                orderId = "YOUR_ORDER_ID",
                fundingSource = PayPalWebCheckoutFundingSource.PAYPAL
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

    fun onNewIntent(intent: Intent): Boolean {
        if (intent.action == Intent.ACTION_VIEW && intent.scheme == "itheamc") {

            intent.data?.let {
                // STEP 5: Finish Start Checkout
                when (val result = checkoutClient?.finishStart(Intent())) {
                    is PayPalWebCheckoutFinishStartResult.Canceled -> {
                        listener?.onCanceled(
                            orderId = result.orderId,
                        )
                    }

                    is PayPalWebCheckoutFinishStartResult.Failure -> {
                        listener?.onFailure(
                            orderId = null,
                            reason = result.error.errorDescription,
                            code = result.error.code,
                            correlationId = result.error.correlationId
                        )
                    }

                    PayPalWebCheckoutFinishStartResult.NoResult -> {
                        listener?.onError("Unable to process your request")
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
            }

            return true
        }
        return false
    }

    private class CheckoutResultEventListener : PayPalWebCheckoutResultEventStreamHandler() {
        private var eventSink: PigeonEventSink<PayPalWebCheckoutResultEvent>? = null

        override fun onListen(p0: Any?, sink: PigeonEventSink<PayPalWebCheckoutResultEvent>) {
            eventSink = sink
        }

        override fun onCancel(p0: Any?) {
            eventSink = null
        }

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

        fun onCanceled(orderId: String?) {
            eventSink?.success(
                PayPalWebCheckoutCanceledResultEvent(
                    orderId = orderId
                )
            )

            end()
        }

        fun onError(error: String) {
            eventSink?.success(
                PayPalWebCheckoutErrorResultEvent(
                    error = error
                )
            )

            end()
        }

        private fun end() {
            eventSink?.endOfStream()
            eventSink = null
        }
    }
}