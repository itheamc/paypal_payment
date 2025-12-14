//
//  WebPaymentsHandler.swift
//  Pods
//
//  Created by Amit on 14/12/2025.
//

import Flutter
import Foundation
import PayPal

/**
 * Handles PayPal Web Payment flow for the Flutter iOS platform.
 */
class WebPaymentsHandler: NSObject, PaypalWebPaymentHostApi {
    private let paypalConfig: PaypalPaymentConfig
    private let messenger: FlutterBinaryMessenger
    
    init(paypalConfig: PaypalPaymentConfig, messenger: FlutterBinaryMessenger) {
        self.paypalConfig = paypalConfig
        self.messenger = messenger
        super.init()
        
        // Setup the host API on the messenger
        PaypalWebPaymentHostApiSetup.setUp(binaryMessenger: messenger, api: self)
    }
    
    
    /// Starts the PayPal Web Payment flow for the given order and funding source.
    /// - Parameters:
    ///   - orderId: The PayPal order ID to be processed.
    ///   - fundingSource: The selected funding source (e.g., "paypal", "card").
    /// - Throws: `PigeonError` if the SDK is not initialized.
    func initiatePaymentRequest(
        orderId: String,
        fundingSource: String
    ) throws {
        
        // MARK: STEP 1 — Create & Register Checkout Result Listener
        // This listener receives success/failure callbacks from the SDK.
        // It is registered through the event stream handler so results can be
        // forwarded back to Dart/Flutter.
        let listener = WebPaymentRequestResultEventListener()
        
        // Register the event listener with Flutter’s binary messenger.
        WebPaymentRequestResultEventListener.register(
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
        // (sandbox/live) used by PayPal's SDK to operate the checkout flow.
        let config = CoreConfig(
            clientID: clientId,
            environment: paypalConfig.toPaypalEnvironment()
        )
        
        // MARK: STEP 4 — Initialize Web Checkout Client
        // The checkout client is responsible for launching and managing
        // the PayPal web-based authorization and payment process.
        let checkoutClient = PayPalWebCheckoutClient(config: config)
        
        // MARK: STEP 5 — Build Checkout Request
        // This request includes the order ID and selected funding source
        // and is passed to the PayPal checkout client to initiate the flow.
        let request = PayPalWebCheckoutRequest(
            orderID: orderId,
            fundingSource: fundingSource.toPayPalWebCheckoutFundingSource()
        )
        
        // MARK: STEP 6 — Start Checkout Flow
        // The `start` method triggers the PayPal authorization experience.
        // The callback reports initial validation or technical failures.
        checkoutClient.start(request: request, completion: { result in
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
                    
                case .success(let webCheckoutResult):
                    // Checkout launched successfully and final approval completed.
                    // The result contains order and payer IDs.
                    listener.onSuccess(
                        orderId: webCheckoutResult.orderID,
                        payerId: webCheckoutResult.payerID
                    )
            }
        })
    }
    
    /**
     * Event stream handler that bridges PayPal Web Payment Request results from native iOS to Flutter.
     * This listener captures the Flutter event sink when Dart starts listening and sends exactly
     * one terminal event (success, failure, canceled, or error). After emitting, the stream is
     * closed and the sink is cleared.
     */
    private class WebPaymentRequestResultEventListener: PaypalWebPaymentRequestResultEventStreamHandler {
        
        // The active Flutter event sink used to emit `PaypalWebPaymentRequestResultEvent` values back to Dart.
        private var eventSink: PigeonEventSink<PaypalWebPaymentRequestResultEvent>?
        
        // Called when the Dart side begins listening to the event stream.
        // Stores the provided sink so native can send result events back to Flutter.
        override func onListen(
            withArguments arguments: Any?,
            sink: PigeonEventSink<PaypalWebPaymentRequestResultEvent>
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
        func onSuccess(orderId: String?, payerId: String?) {
            let event = PaypalWebPaymentRequestSuccessResultEvent(
                orderId: orderId,
                payerId: payerId
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
            let event = PaypalWebPaymentRequestFailureResultEvent(
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
            let event = PaypalWebPaymentRequestCanceledResultEvent(orderId: orderId)
            eventSink?.success(event)
            end()
        }
        
        // Emits a generic error event and closes the stream.
        func onError(_ error: String) {
            let event = PaypalWebPaymentRequestErrorResultEvent(error: error)
            eventSink?.success(event)
            end()
        }
    }
    
    
}

// Helper extension function to convert string funding source to
// Paypal webcheckout funding source
extension String {
    /**
     Converts a textual funding source into a `PayPalWebCheckoutFundingSource`.
     
     - Returns: The matching `PayPalWebCheckoutFundingSource` value. If the string
     does not match a known funding source, `.paypal` is returned by default.
     
     Supported inputs (case-sensitive):
     - "paypal"     -> `.paypal`
     - "credit"     -> `.paypalCredit`
     - "payLater"   -> `.paylater`
     
     Notes:
     - This helper is intentionally conservative and case-sensitive to avoid
     accidental mappings. Normalize your input (e.g., lowercasing) upstream if
     needed.
     - The default branch returns `.paypal` to provide a safe fallback that
     continues the checkout flow with the most common funding source.
     */
    func toPayPalWebCheckoutFundingSource() -> PayPalWebCheckoutFundingSource {
        switch self {
            case "paypal":
                return .paypal
            case "credit":
                return .paypalCredit
            case "payLater":
                return .paylater
            default:
                return .paypal
        }
    }
}
