import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let adChannel = FlutterMethodChannel(name: "com.appsbay.classic_15_puzzle/ad_config",
                                              binaryMessenger: controller.binaryMessenger)
    adChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "getAdBannerUnitId" {
        let bannerId = Bundle.main.object(forInfoDictionaryKey: "AdBannerUnitId") as? String
        result(bannerId)
      } else if call.method == "getAdOpenUnitId" {
        let openId = Bundle.main.object(forInfoDictionaryKey: "AdOpenUnitId") as? String
        result(openId)
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
