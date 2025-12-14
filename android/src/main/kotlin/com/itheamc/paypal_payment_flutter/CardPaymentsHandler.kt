package com.itheamc.paypal_payment_flutter

import CardData
import FlutterError
import PaypalCardPaymentHostApi
import PaypalCardPaymentRequestCanceledResultEvent
import PaypalCardPaymentRequestErrorResultEvent
import PaypalCardPaymentRequestFailureResultEvent
import PaypalCardPaymentRequestResultEvent
import PaypalCardPaymentRequestResultEventStreamHandler
import PaypalCardPaymentRequestSuccessResultEvent
import PigeonEventSink
import android.app.Activity
import android.content.Intent
import com.paypal.android.cardpayments.Card
import com.paypal.android.cardpayments.CardApproveOrderResult
import com.paypal.android.cardpayments.CardClient
import com.paypal.android.cardpayments.CardFinishApproveOrderResult
import com.paypal.android.cardpayments.CardRequest
import com.paypal.android.cardpayments.threedsecure.SCA
import com.paypal.android.corepayments.Address
import com.paypal.android.corepayments.CoreConfig
import io.flutter.embedding.engine.plugins.FlutterPlugin
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

/**
 * Handles PayPal Card Payments Request Flow.
 *
 * @property getConfig The callback to get the paypal payment configuration
 * @property getActivity The callback to get the current activity.
 * @property getPluginBinding The callback to get the current plugin binding.
 */
class CardsPaymentsHandler(
    private val getConfig: () -> PaypalPaymentConfig,
    private val getActivity: () -> Activity?,
    private val getPluginBinding: () -> FlutterPlugin.FlutterPluginBinding?,
) : PaypalCardPaymentHostApi {

    /**
     * The client for handling PayPal Card Payment Request.
     */
    private var cardClient: CardClient? = null

    /**
     * The listener for card payment request result events.
     */
    private var listener: PaypalCardPaymentRequestResultEventListener? = null

    /**
     * The flag to check if the checkout on intent is called or not
     */
    private var isCardCheckoutOnIntentCalled = false

    /**
     * Currently processing order id
     */
    private var currentlyProcessingOrderId: String? = null

    init {
        getPluginBinding()?.let {
            PaypalCardPaymentHostApi.setUp(it.binaryMessenger, this)
        }
    }

    /**
     * Initiates the PayPal Card Payment Request.
     *
     * @param orderId The ID of the order to be processed.
     * @param card The card details for the payment.
     * @param sca The SCA (Security Code Authentication) value.
     * @throws FlutterError if the activity, binding, or PayPal configuration is null.
     */
    override fun initiatePaymentRequest(
        orderId: String,
        card: CardData,
        sca: String
    ) {
        // STEP 1: Make card checkout intent called variable false and set the
        // currently processing order id
        isCardCheckoutOnIntentCalled = false
        currentlyProcessingOrderId = orderId

        // STEP 2: Initialize & register Result Listener
        listener = PaypalCardPaymentRequestResultEventListener()

        PaypalCardPaymentRequestResultEventStreamHandler.register(
            getPluginBinding()!!.binaryMessenger,
            listener!!
        )

        val paypalConfig = getConfig()

        if (paypalConfig.clientId == null) {
            listener?.onError("SDK not initialized")
            listener = null
            currentlyProcessingOrderId = null
            return
        }

        // STEP 3: Creating Configuration Object for Paypal Payment
        val config = CoreConfig(
            paypalConfig.clientId!!,
            paypalConfig.toPaypalEnvironment()
        )

        // STEP 4: Initializing Card Client
        cardClient = CardClient(
            context = getActivity()!!,
            configuration = config,
        )

        // STEP 5: Creating the card request
        val request = CardRequest(
            orderId = orderId,
            card = card.toCard(),
            returnUrl = "itheamc://paypal",
            sca = sca.toSca(),
        )

        // STEP 6: Approving the card payment request
        cardClient?.approveOrder(
            cardRequest = request,
            callback = {
                when (it) {
                    is CardApproveOrderResult.AuthorizationRequired -> {
                        cardClient?.presentAuthChallenge(
                            getActivity()!!,
                            it.authChallenge
                        )
                    }

                    is CardApproveOrderResult.Failure -> {
                        listener?.onFailure(
                            orderId = currentlyProcessingOrderId,
                            reason = it.error.errorDescription,
                            code = it.error.code,
                            correlationId = it.error.correlationId
                        )
                    }

                    is CardApproveOrderResult.Success -> {
                        listener?.onSuccess(
                            orderId = it.orderId,
                            status = it.status,
                            didAttemptThreeDSecureAuthentication = it.didAttemptThreeDSecureAuthentication
                        )
                    }
                }
            }
        )
    }

    /**
     * Handles the result from the PayPal Card Payment Approve Order.
     *
     * @param intent The intent containing the result data.
     * @return `true` if the intent was handled, `false` otherwise.
     */
    fun onNewIntent(intent: Intent): Boolean {

        // If the card client or currently processing order id is null, return false
        if (cardClient == null || currentlyProcessingOrderId == null) return false;

        // Else if the intent scheme is "itheamc", go ahead and finish approve order
        if (intent.scheme == "itheamc") {
            // STEP 7: Make checkout intent called variable true
            isCardCheckoutOnIntentCalled = true

            // STEP 8: Finish Start Checkout
            when (val result = cardClient?.finishApproveOrder(intent)) {
                is CardFinishApproveOrderResult.Success -> {
                    listener?.onSuccess(
                        orderId = result.orderId,
                        status = result.status,
                        didAttemptThreeDSecureAuthentication = result.didAttemptThreeDSecureAuthentication
                    )
                }

                CardFinishApproveOrderResult.NoResult -> {
                    listener?.onSuccess(
                        orderId = currentlyProcessingOrderId,
                        status = "No Result",
                        didAttemptThreeDSecureAuthentication = false
                    )
                }

                CardFinishApproveOrderResult.Canceled -> {
                    listener?.onCanceled(currentlyProcessingOrderId)
                }

                is CardFinishApproveOrderResult.Failure -> {
                    listener?.onFailure(
                        orderId = currentlyProcessingOrderId,
                        reason = result.error.errorDescription,
                        code = result.error.code,
                        correlationId = result.error.correlationId
                    )
                }

                null -> {
                    listener?.onError("Something went wrong")
                }
            }

            // STEP 9: Reset client and listener
            cardClient = null
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
        if (cardClient != null && listener != null) {
            CoroutineScope(Dispatchers.Main).launch {
                delay(2000)

                // If the checkout flow has already been handled by onNewIntent, return early
                if (isCardCheckoutOnIntentCalled) return@launch

                // Cancel the checkout process and send a cancellation event
                listener?.onCanceled(currentlyProcessingOrderId)

                cardClient = null
                listener = null
                currentlyProcessingOrderId = null
            }
        }
    }

    /**
     * An event listener for PayPal Card Payment Request results.
     */
    private class PaypalCardPaymentRequestResultEventListener :
        PaypalCardPaymentRequestResultEventStreamHandler() {
        private var eventSink: PigeonEventSink<PaypalCardPaymentRequestResultEvent>? = null

        override fun onListen(
            p0: Any?,
            sink: PigeonEventSink<PaypalCardPaymentRequestResultEvent>
        ) {
            eventSink = sink
        }

        override fun onCancel(p0: Any?) {
            eventSink = null
        }

        /**
         * Handles a successful checkout.
         *
         * @param orderId The ID of the order.
         * @param status The status of the checkout.
         * @param didAttemptThreeDSecureAuthentication Whether 3D Secure authentication was attempted.
         */
        fun onSuccess(
            orderId: String? = null,
            status: String? = null,
            didAttemptThreeDSecureAuthentication: Boolean = false,
        ) {
            eventSink?.success(
                PaypalCardPaymentRequestSuccessResultEvent(
                    orderId = orderId,
                    status = status,
                    didAttemptThreeDSecureAuthentication = didAttemptThreeDSecureAuthentication,
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
                PaypalCardPaymentRequestFailureResultEvent(
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
                PaypalCardPaymentRequestCanceledResultEvent(
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
                PaypalCardPaymentRequestErrorResultEvent(
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
 * Converts a [CardData] object to a [Card] object.
 *
 * @return The converted [Card] object.
 */
private fun CardData.toCard(): Card = Card(
    number = number,
    expirationMonth = expirationMonth,
    expirationYear = expirationYear,
    securityCode = securityCode,
    cardholderName = cardholderName,
    billingAddress = Address(
        countryCode = billingAddress.countryCode,
        streetAddress = billingAddress.streetAddress,
        extendedAddress = billingAddress.extendedAddress,
        locality = billingAddress.locality,
        region = billingAddress.region,
        postalCode = billingAddress.postalCode,
    )
)

/**
 * Converts a string to a [SCA].
 *
 * @return The corresponding [SCA], or [SCA.SCA_WHEN_REQUIRED] if the string is not recognized.
 */
private fun String.toSca(): SCA {
    return when (this) {
        "always" -> SCA.SCA_ALWAYS
        "whenRequired" -> SCA.SCA_WHEN_REQUIRED
        else -> SCA.SCA_WHEN_REQUIRED
    }
}