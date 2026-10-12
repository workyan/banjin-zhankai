import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let screenshotChannelName = "banjin_zhankai/screenshot_config"
  private let screenshotModeFlag = "--app-store-screenshot-mode"
  private let screenshotSceneFlag = "--app-store-screenshot-scene"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let channel = FlutterMethodChannel(
      name: screenshotChannelName,
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "getInitialScene" else {
        result(FlutterMethodNotImplemented)
        return
      }

      result(self?.resolveInitialScene())
    }
  }

  private func resolveInitialScene() -> String? {
    let environment = ProcessInfo.processInfo.environment
    if let enabled = environment["APP_STORE_SCREENSHOT_MODE"]?.lowercased(),
      ["1", "true", "yes", "on"].contains(enabled),
      let scene = environment["APP_STORE_SCREENSHOT_SCENE"],
      scene.isEmpty == false
    {
      return scene
    }

    let arguments = ProcessInfo.processInfo.arguments
    guard arguments.contains(screenshotModeFlag),
      let flagIndex = arguments.firstIndex(of: screenshotSceneFlag)
    else {
      return nil
    }

    let sceneIndex = arguments.index(after: flagIndex)
    guard sceneIndex < arguments.endIndex else {
      return nil
    }

    let scene = arguments[sceneIndex]
    return scene.isEmpty ? nil : scene
  }
}
