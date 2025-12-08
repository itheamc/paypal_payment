package com.itheamc.paypal_payment

import PaypalPaymentHostApi
import android.app.Activity
import android.content.Intent
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.PluginRegistry.NewIntentListener
import io.flutter.plugin.platform.PlatformViewRegistry


class PaypalPaymentPlugin :
    FlutterPlugin,
    ActivityAware,
    NewIntentListener,
    PaypalPaymentHostApi {

    private var activity: Activity? = null
    private var pluginBinding: FlutterPlugin.FlutterPluginBinding? = null
    private var activityPluginBinding: ActivityPluginBinding? = null
    private var platformViewRegistry: PlatformViewRegistry? = null
    private var webCheckoutHandler: WebCheckoutHandler? = null

    private var paypalPaymentConfig: PaypalPaymentConfig? = null


    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        pluginBinding = binding
        platformViewRegistry = binding.platformViewRegistry
        PaypalPaymentHostApi.setUp(binding.binaryMessenger, this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        platformViewRegistry = null
        pluginBinding = null
        paypalPaymentConfig = null
    }


    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityPluginBinding = binding
        activity = binding.activity
        webCheckoutHandler = WebCheckoutHandler(paypalPaymentConfig, activity, pluginBinding)
        binding.addOnNewIntentListener(this)
    }

    override fun onDetachedFromActivity() {
        activityPluginBinding?.removeOnNewIntentListener(this)

        activityPluginBinding = null
        activity = null
        webCheckoutHandler = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    override fun onNewIntent(intent: Intent): Boolean {
        return webCheckoutHandler?.onNewIntent(intent) ?: false
    }

    override fun init(clientId: String, environment: String) {
        paypalPaymentConfig = PaypalPaymentConfig(clientId, environment)
    }
}
