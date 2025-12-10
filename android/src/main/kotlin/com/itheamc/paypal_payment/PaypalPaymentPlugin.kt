package com.itheamc.paypal_payment

import PaypalPaymentHostApi
import android.app.Activity
import android.content.Intent
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.PluginRegistry.NewIntentListener

/**
 * The main plugin class for the paypal_payment Flutter plugin.
 *
 * This class handles the communication with the Flutter side and manages the Android lifecycle.
 */
class PaypalPaymentPlugin :
    FlutterPlugin,
    ActivityAware,
    NewIntentListener,
    PaypalPaymentHostApi {

    /** The current Android [Activity]. */
    private var activity: Activity? = null

    /** The binding to the Flutter engine. */
    private var pluginBinding: FlutterPlugin.FlutterPluginBinding? = null

    /** The binding to the activity. */
    private var activityPluginBinding: ActivityPluginBinding? = null

    /** The handler for web-based PayPal checkout. */
    private var webCheckoutHandler: WebCheckoutHandler? = null

    /** The configuration for the PayPal payment. */
    private var paypalPaymentConfig: PaypalPaymentConfig = PaypalPaymentConfig()


    /**
     * Called when the plugin is attached to the Flutter engine.
     */
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        pluginBinding = binding
        PaypalPaymentHostApi.setUp(binding.binaryMessenger, this)
    }

    /**
     * Called when the plugin is detached from the Flutter engine.
     */
    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        pluginBinding = null
        paypalPaymentConfig.apply {
            clientId = null
            environment = null
        }
    }


    /**
     * Called when the plugin is attached to an activity.
     */
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityPluginBinding = binding
        activity = binding.activity
        webCheckoutHandler = WebCheckoutHandler(paypalPaymentConfig, activity, pluginBinding)
        binding.addOnNewIntentListener(this)
    }

    /**
     * Called when the plugin is detached from an activity.
     */
    override fun onDetachedFromActivity() {
        activityPluginBinding?.removeOnNewIntentListener(this)

        activityPluginBinding = null
        activity = null
        webCheckoutHandler = null
    }

    /**
     * Called when the activity is reattached after a configuration change.
     */
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    /**
     * Called when the activity is detached for a configuration change.
     */
    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    /**
     * Called when a new intent is received.
     *
     * @param intent The new intent.
     * @return True if the intent was handled, false otherwise.
     */
    override fun onNewIntent(intent: Intent): Boolean {
        return webCheckoutHandler?.onNewIntent(intent) ?: false
    }

    /**
     * Initializes the PayPal payment configuration.
     *
     * @param clientId The PayPal client ID.
     * @param environment The PayPal environment ("live" or "sandbox").
     */
    override fun initialize(clientId: String, environment: String) {
        paypalPaymentConfig.apply {
            this.clientId = clientId
            this.environment = environment
        }
    }
}
