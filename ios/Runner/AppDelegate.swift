///
/// Copyright (c) 2026 Netmera Research.
///

import UIKit
import Flutter
import netmera_flutter_sdk
import NetmeraCore
import NetmeraNotification

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // Add it if you are using Firebase.
        UNUserNotificationCenter.current().delegate = self

        initializeNetmera()
        Netmera.setPushDelegate(self)

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
      GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    }
    
    // Add it if you are using Firebase.
    @available(iOS 10.0, *)
    override func userNotificationCenter(
      _ center: UNUserNotificationCenter,
      willPresent notification: UNNotification,
      withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        if #available(iOS 14, *) {
          completionHandler([.banner, .list, .badge, .sound])
        } else {
          completionHandler([.alert, .badge, .sound])
        }
    }
    
    private func initializeNetmera() {
        // Netmera config from iOS Settings (Config/NetmeraConfigProvider)
        NetmeraConfigProvider.registerSettingsBundleDefaults()
        let (apiKey, baseUrl) = NetmeraConfigProvider.configFromSettings()
        
        let netmeraParams = NetmeraParams(apiKey: apiKey, baseUrl: baseUrl)
        FNetmera.initialize(params: netmeraParams)
    }
}

extension AppDelegate: NetmeraPushDelegate {
    func urlOpeningDecision(for url: URL, push: NetmeraBasePush) -> PushDelegateDecision {
        return .appHandles
    }
    
    func openURL(_ url: URL, for push: NetmeraBasePush) {
        FNetmera.handleOpenURL(url: url, forPushObject: push)
    }
}
