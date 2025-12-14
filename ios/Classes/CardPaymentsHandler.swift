//
//  CardPaymentsHandler.swift
//  Pods
//
//  Created by Amit on 14/12/2025.
//

import Flutter
import Foundation
import PayPal

/**
 * Handles PayPal Card Payment flow for the Flutter iOS platform.
 */
class CardPaymentsHandler: NSObject, PaypalCardPaymentHostApi {
    private let paypalConfig: PaypalPaymentConfig
    private let messenger: FlutterBinaryMessenger
    
    init(paypalConfig: PaypalPaymentConfig, messenger: FlutterBinaryMessenger) {
        self.paypalConfig = paypalConfig
        self.messenger = messenger
        super.init()
        
        // Setup the host API on the messenger
        PaypalCardPaymentHostApiSetup.setUp(binaryMessenger: messenger, api: self)
    }
    
    
    /// Starts the PayPal Web Payment flow for the given order and funding source.
    /// - Parameters:
    ///   - orderId: The PayPal order ID to be processed.
    ///   - card: The card details for the payment.
    ///   - sca: The SCA (Strong Customer Authentication) value.
    ///
    func initiatePaymentRequest(
        orderId: String,
        card: CardData,
        sca: String
    ) throws {
        
        // MARK: STEP 1 — Create & Register Checkout Result Listener
        // This listener receives success/failure callbacks from the SDK.
        // It is registered through the event stream handler so results can be
        // forwarded back to Dart/Flutter.
        let listener = CardPaymentRequestResultEventListener()
        
        // Register the event listener with Flutter’s binary messenger.
        CardPaymentRequestResultEventListener.register(
            with: messenger,
            streamHandler: listener
        )
        
        // MARK: STEP 2 — Validate that the SDK has been initialized
        // Validate that the SDK has been initialized and a valid client ID exists.
        // If not available, checkout cannot proceed.
        guard let clientId = paypalConfig.clientId else {
            listener.onError("Plugin not initialized. Please initialize the SDK first.")
            return
        }
        
        // MARK: STEP 3 — Create PayPal Core Configuration
        // This configuration object defines the client ID and environment
        // (sandbox/live) used by PayPal's SDK to operate the card payment flow.
        let config = CoreConfig(
            clientID: clientId,
            environment: paypalConfig.toPaypalEnvironment()
        )
        
        // MARK: STEP 4 — Initialize Card Payment Client
        // The checkout client is responsible for launching and managing
        // the PayPal web-based authorization and payment process.
        let client = CardClient(config: config)
        
        // MARK: STEP 5 — Build Card Payment Request
        // This request includes the order ID, card details and sca
        // which is passed to the PayPal Card Client to initiate the payment.
        let request = CardRequest(
            orderID: orderId,
            card: card.toCard(),
            sca: sca.toSca()
        )
        
        // MARK: STEP 6 — Start Payment Request Flow
        // The `start` method triggers the PayPal authorization experience.
        // The callback reports initial validation or technical failures.
        client.approveOrder(request: request, completion: { result in
            switch result {
                case .failure(let error):
                    // Handles any failure occurring before the checkout UI loads
                    // (e.g., invalid request, network failure).
                    listener.onFailure(
                        orderId: orderId,
                        reason: error.errorDescription ?? "Unknown authorization error",
                        code: error.code ?? 0,
                        correlationId: nil
                    )
                    
                    
                case .success(let cardResult):
                    // Checkout launched successfully and final approval completed.
                    // The result contains order and status and didAttemptThreeDSecureAuthentication.
                    listener.onSuccess(
                        orderId: cardResult.orderID,
                        status: cardResult.status,
                        didAttemptThreeDSecureAuthentication: cardResult.didAttemptThreeDSecureAuthentication
                    )
            }
        })
    }
    
    /**
     * Event stream handler that bridges PayPal Card Payment Request results from native iOS to Flutter.
     * This listener captures the Flutter event sink when Dart starts listening and sends exactly
     * one terminal event (success, failure, canceled, or error). After emitting, the stream is
     * closed and the sink is cleared.
     */
    private class CardPaymentRequestResultEventListener: PaypalCardPaymentRequestResultEventStreamHandler {
        
        // The active Flutter event sink used to emit `PaypalCardPaymentRequestResultEvent` values back to Dart.
        private var eventSink: PigeonEventSink<PaypalCardPaymentRequestResultEvent>?
        
        // Called when the Dart side begins listening to the event stream.
        // Stores the provided sink so native can send result events back to Flutter.
        override func onListen(
            withArguments arguments: Any?,
            sink: PigeonEventSink<PaypalCardPaymentRequestResultEvent>
        ) {
            self.eventSink = sink
        }
        
        // Called when Dart cancels its subscription.
        // Releases the sink reference to prevent further emissions.
        override func onCancel(withArguments arguments: Any?) {
            self.eventSink = nil
        }
        
        // Ends the event stream by notifying Flutter and clearing the sink.
        // Called internally after sending any terminal event.
        private func end() {
            eventSink?.endOfStream()
            self.eventSink = nil
        }
        
        // Emits a successful checkout result and closes the stream.
        func onSuccess(
            orderId: String?,
            status: String?,
            didAttemptThreeDSecureAuthentication: Bool = false
        ) {
            let event = PaypalCardPaymentRequestSuccessResultEvent(
                orderId: orderId,
                status: status,
                didAttemptThreeDSecureAuthentication: didAttemptThreeDSecureAuthentication
            )
            eventSink?.success(event)
            end()
        }
        
        // Emits a failure result and closes the stream.
        func onFailure(
            orderId: String?,
            reason: String,
            code: Int,
            correlationId: String?
        ) {
            let event = PaypalCardPaymentRequestFailureResultEvent(
                orderId: orderId,
                reason: reason,
                code: Int64(code),
                correlationId: correlationId
            )
            eventSink?.success(event)
            end()
        }
        
        // Emits a cancellation result and closes the stream.
        func onCanceled(orderId: String?) {
            let event = PaypalCardPaymentRequestCanceledResultEvent(orderId: orderId)
            eventSink?.success(event)
            end()
        }
        
        // Emits a generic error event and closes the stream.
        func onError(_ error: String) {
            let event = PaypalCardPaymentRequestErrorResultEvent(error: error)
            eventSink?.success(event)
            end()
        }
    }
    
    
}

// Helper extension function to convert string sca to
// Paypal Strong Customer Authentication (SCA)
extension String {
    /**
     Converts a textual sca into a `SCA`.
     
     - Returns: The matching `SCA` value. If the string
     does not match a known sca, `.scaWhenRequired` is returned by default.
     
     Supported inputs (case-sensitive):
     - "always"     -> `.scaAlways`
     - "whenRequired"     -> `.scaWhenRequired`
     
     Notes:
     - This helper is intentionally conservative and case-sensitive to avoid
     accidental mappings. Normalize your input (e.g., lowercasing) upstream if
     needed.
     - The default branch returns `.scaWhenRequired` to provide a safe fallback that
     continues the checkout flow.
     */
    func toSca() -> SCA {
        switch self {
            case "always":
                return .scaAlways
            case "whenRequired":
                return .scaWhenRequired
            default:
                return .scaWhenRequired
        }
    }
}


/// Converts a `CardData` object to a `Card` object.
/// - Returns: The converted `Card` object.
private extension CardData {
    func toCard() -> Card {
        return Card(
            number: number,
            expirationMonth: expirationMonth,
            expirationYear: expirationYear,
            securityCode: securityCode,
            cardholderName: cardholderName,
            billingAddress: Address(
                addressLine1: billingAddress.streetAddress,
                addressLine2: billingAddress.extendedAddress,
                locality: billingAddress.locality,
                region: billingAddress.region,
                postalCode: billingAddress.postalCode,
                countryCode: billingAddress.countryCode,
            )
        )
    }
}
