//
//  PaypalPaymentsHandler.swift
//  Pods
//
//  Created by Amit on 14/12/2025.
//

import Flutter
import Foundation
import PayPal

/**
 * Handles PayPal Payments flow for the Flutter iOS platform.
 */
class PaypalPaymentsHandler: NSObject, PaypalPaymentHostApi {
    private let messenger: FlutterBinaryMessenger
    
    // Configuration object to hold PayPal-specific settings like the client ID and environment.
    // It's initialized immediately.
    private var config: PaypalPaymentConfig = .init()
    
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
        
        // Initialize the web payments handler
        _ = WebPaymentsHandler(
            paypalConfig: config,
            messenger: messenger
        )
        
        // Initialize the card payment handler
        _ = CardPaymentsHandler(
            paypalConfig: config,
            messenger: messenger
        )
        
        // Set up the communication channel (Method Channel or Pigeon) for the host API.
        // This allows the Dart/Flutter code to call methods implemented in this Swift class (e.g.initialize`).
        PaypalPaymentHostApiSetup.setUp(binaryMessenger: messenger, api: self)
    }
    
    
    // MARK: - PaypalPaymentHostApi Implementation
    
    // Implementation of the `initialize` method defined in the PaypalPaymentHostApi protocol (likely generatey Pigeon).
    // This method is called from the Flutter side to configure the PayPal SDK settings.
    // It takes the required credentials: the client ID and the target environment (e.g., "production"sandbox").
    func initialize(clientId: String, environment: String) throws {
        // Store the received client ID in the configuration object.
        config.clientId = clientId
        
        // Store the received environment in the configuration object.
        config.environment = environment
    }
}
