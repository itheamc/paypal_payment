import Flutter

/**
 * Represents the main plugin class for PayPal payments integration within a Flutter application.
 * It conforms to NSObject (base class for many Objective-C/Swift objects) and the FlutterPlugin protocol
 * (required for Flutter platform-specific code) and PaypalPaymentHostApi (likely a generated protocol
 * for communication from Flutter to the native platform).
 */
public class PaypalPaymentPlugin: NSObject, FlutterPlugin, PaypalPaymentHostApi {
    
    // Configuration object to hold PayPal-specific settings like the client ID and environment.
    // It's initialized immediately.
    var paypalPaymentConfig: PaypalPaymentConfig = .init()
    
    
    // MARK: - FlutterPlugin Registration
    
    // The static function required by the FlutterPlugin protocol.
    // It's the entry point called by Flutter when the plugin is loaded.
    public static func register(with registrar: FlutterPluginRegistrar) {
        // Create an instance of the plugin.
        let instance = PaypalPaymentPlugin()
        
        // Set up the communication channel (Method Channel or Pigeon) for the host API.
        // This allows the Dart/Flutter code to call methods implemented in this Swift class (e.g.initialize`).
        PaypalPaymentHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: instance)
        
        // Initialize a handler for web-based checkout processes.
        // This likely manages the presentation and lifecycle of a web view for the PayPal login/paymenlow.
        _ = WebCheckoutHandler.init(
            pluginInstance: instance, // Pass the main plugin instance (often for shared state/config)
            messenger: registrar.messenger() // Use the same messenger for potential communication baco Flutter
        )
    }
     
     // MARK: - PaypalPaymentHostApi Implementation
     
     // Implementation of the `initialize` method defined in the PaypalPaymentHostApi protocol (likely generatey Pigeon).
     // This method is called from the Flutter side to configure the PayPal SDK settings.
     // It takes the required credentials: the client ID and the target environment (e.g., "production"sandbox").
    func initialize(clientId: String, environment: String) throws {
        // Store the received client ID in the configuration object.
        paypalPaymentConfig.clientId = clientId
        
        // Store the received environment in the configuration object.
        paypalPaymentConfig.environment = environment
    }
}
