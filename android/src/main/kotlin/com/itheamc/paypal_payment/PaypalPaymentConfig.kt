package com.itheamc.paypal_payment

import com.paypal.android.corepayments.Environment

class PaypalPaymentConfig(
    val clientId: String,
    val environment: String,
)

fun PaypalPaymentConfig.toPaypalEnvironment(): Environment {
    return runCatching {
        Environment.valueOf(environment.uppercase())
    }.getOrDefault(Environment.SANDBOX)
}
