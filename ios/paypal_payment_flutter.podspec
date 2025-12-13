#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint paypal_payment_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'paypal_payment_flutter'
  s.version          = '0.0.2'
  s.summary          = 'A Flutter plugin that enables seamless PayPal payment processing and integration within Flutter apps.'
  s.description      = <<-DESC
This is a flutter plugin to handle the paypal payment in flutter app.
                       DESC
  s.homepage         = 'https://github.com/itheamc/paypal_payment'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Amit Chaudhary' => 'itheamc@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'PayPal', '2.0.1'
  s.platform = :ios, '15.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'paypal_payment_flutter_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
