package com.itheamc.paypal_payment

import com.paypal.android.corepayments.Environment

/**
 * Configuration for the PayPal payment.
 *
 * @property clientId The PayPal client ID.
 * @property environment The PayPal environment ("live" or "sandbox").
 */
class PaypalPaymentConfig(
    var clientId: String? = null,
    var environment: String? = null,
)

/**
 * Converts the [PaypalPaymentConfig] to a PayPal [Environment].
 *
 * @return The PayPal [Environment] corresponding to the configuration.
 */
fun PaypalPaymentConfig.toPaypalEnvironment(): Environment {
    return runCatching {
        Environment.valueOf(environment!!.uppercase())
    }.getOrDefault(Environment.SANDBOX)
}
