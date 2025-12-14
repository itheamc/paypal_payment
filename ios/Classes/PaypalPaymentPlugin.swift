import Flutter

/**
 * Represents the main plugin class for PayPal payments integration within a Flutter application.
 * It conforms to NSObject (base class for many Objective-C/Swift objects) and the FlutterPlugin protocol
 * (required for Flutter platform-specific code) and PaypalPaymentHostApi (likely a generated protocol
 * for communication from Flutter to the native platform).
 */
public class PaypalPaymentPlugin: NSObject, FlutterPlugin {
    
    // MARK: - FlutterPlugin Registration
    
    // The static function required by the FlutterPlugin protocol.
    // It's the entry point called by Flutter when the plugin is loaded.
    public static func register(with registrar: FlutterPluginRegistrar) {
        // Initialize a handler for web-based checkout processes.
        // This likely manages the presentation and lifecycle of a web view for the PayPal login/paymenlow.
        _ = PaypalPaymentsHandler.init(
            // Use the same messenger for potential communication with Flutter
            messenger: registrar.messenger()
        )
    }
}
