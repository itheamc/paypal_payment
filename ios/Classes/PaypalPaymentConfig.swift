//
//  PaypalPaymentConfig.swift
//  Pods
//
//  Created by Amit on 09/12/2025.
//

import Foundation
import PayPal

/**
 * Configuration for the PayPal payment.
 *
 * @property clientId The PayPal client ID.
 * @property environment The PayPal environment ("live" or "sandbox").
 */
class PaypalPaymentConfig {
    var clientId: String?
    var environment: String?
    
    // Initializer to allow for configuration during creation
    init(clientId: String? = nil, environment: String? = nil) {
        self.clientId = clientId
        self.environment = environment
    }
}

/**
 * Converts the String environment setting to a PayPal SDK Environment type.
 *
 * This extension mirrors Kotlin's 'toPaypalEnvironment' extension function.
 *
 * @return The PayPal SDK Environment corresponding to the configuration, defaulting to .sandbox.
 */
extension PaypalPaymentConfig {
    
    func toPaypalEnvironment() -> Environment {
        
        // 1. Unwrap the environment string safely. If nil, default to .sandbox.
        guard let environmentString = environment else {
            return .sandbox
        }
        
        // 2. Normalize the string (lowercase) and try to match it to a known case.
        let lowercaseEnv = environmentString.lowercased()
        
        // 3. Use a switch statement for matching.
        switch lowercaseEnv {
            case "live":
                return .live
            case "sandbox":
                return .sandbox
            default:
                return .sandbox
        }
    }
}
