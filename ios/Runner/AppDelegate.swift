import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
            GMSServices.provideAPIKey("AIzaSyCCgMn1ujH0DhwYSA0vY8SIla5R6daJP5A")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
