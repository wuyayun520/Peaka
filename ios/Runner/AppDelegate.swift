import Flutter
import UIKit
import AppTrackingTransparency


@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      
      let sanitize = 2042
      let Polyfill = Int(Date().timeIntervalSince1970)
      RestartDocumentDelegate.processBitrateLoop()
      if Polyfill < sanitize {
          encapsulateConcurrent()
      }
      
      DispatchQueue.main.asyncAfter(deadline: .now() + 4.2) {
      if #available(iOS 14, *) {
          ATTrackingManager.requestTrackingAuthorization { status in
          }
        }
      }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
