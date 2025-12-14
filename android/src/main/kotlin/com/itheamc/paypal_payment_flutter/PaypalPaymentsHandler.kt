package com.itheamc.paypal_payment_flutter

import android.app.Activity
import android.content.Intent
import io.flutter.embedding.engine.plugins.FlutterPlugin

/**
 * A handler for managing PayPal payments, including web and card payments.
 *
 * This class acts as a central point for handling different types of PayPal payment flows.
 *
 * @property getConfig A function that returns the [PaypalPaymentConfig].
 * @property getActivity A function that returns the current [Activity].
 * @property getPluginBinding A function that returns the [FlutterPlugin.FlutterPluginBinding].
 */
class PaypalPaymentsHandler(
    private val getConfig: () -> PaypalPaymentConfig,
    private val getActivity: () -> Activity?,
    private val getPluginBinding: () -> FlutterPlugin.FlutterPluginBinding?,
) {

    // Eagerly initialize handlers to ensure Pigeon APIs are set up immediately.
    private val webPaymentsHandler = WebPaymentsHandler(
        getConfig,
        getActivity,
        getPluginBinding
    )

    private val cardsPaymentsHandler = CardsPaymentsHandler(
        getConfig,
        getActivity,
        getPluginBinding
    )

    /**
     * Forwards the new intent to the appropriate payment handlers.
     *
     * This should be called from the main activity's `onNewIntent` method.
     *
     * @param intent The new intent.
     * @return True if the intent was handled, false otherwise.
     */
    fun onNewIntent(intent: Intent): Boolean {
        return webPaymentsHandler.onNewIntent(intent) || cardsPaymentsHandler.onNewIntent(intent)
    }

    /**
     * Forwards the onResume event to the payment handlers.
     *
     * This should be called from the main activity's `onResume` method.
     */
    fun onResume() {
        webPaymentsHandler.onResume()
        cardsPaymentsHandler.onResume()
    }
}