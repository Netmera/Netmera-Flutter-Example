///
/// Copyright (c) 2026 Netmera Research.
///

import UIKit
import Flutter
import netmera_flutter_sdk
import NetmeraCore

@main
@objc class AppDelegate: FlutterAppDelegate {
    private let CHANNEL = "nm_flutter_example_channel"

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        } else {
            // Fallback on earlier versions
        };
        
        //For triggering onPushReceive when app is killed and push clicked by user
        let notification = launchOptions?[.remoteNotification]
        if notification != nil {
            FNetmeraService.handleWork(FNetmeraService.ON_PUSH_RECEIVE, dict:["userInfo" : notification])
        }
        
        // Netmera config from iOS Settings (Config/NetmeraConfigProvider)
        NetmeraConfigProvider.registerSettingsBundleDefaults()
        let (apiKey, baseUrl) = NetmeraConfigProvider.configFromSettings()
        
        let netmeraParams = NetmeraParams(apiKey: apiKey, baseUrl: baseUrl)
        Netmera.initialize(params: netmeraParams)
        Netmera.setLogLevel(.debug)
        
        if let flutterViewController = window?.rootViewController as? FlutterViewController {
            let methodChannel = FlutterMethodChannel(name: CHANNEL, binaryMessenger: flutterViewController.binaryMessenger)
                    
            methodChannel.setMethodCallHandler { (call: FlutterMethodCall, result: FlutterResult) in
                switch call.method {
                case MethodName.SET_API_KEY.rawValue:
                    if let apiKeyDict = call.arguments as? [String: Any], let apiKey = apiKeyDict["apiKey"] as? String {
                            UserDefaults.standard.set(apiKey, forKey: "apiKey")
                            result(nil)
                        }
                case MethodName.SET_BASE_URL.rawValue:
                    if let baseUrlDict = call.arguments as? [String: Any], let baseUrl = baseUrlDict["baseUrl"] as? String {
                            UserDefaults.standard.set(baseUrl, forKey: "baseUrl")
                            result(nil)
                        }
                    default:
                        break
                }
            }
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        FNetmeraService.handleWork(FNetmeraService.ON_PUSH_REGISTER, dict: ["pushToken": deviceToken])
    }
    
    @available(iOS 10.0, *)
    override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                         didReceive response: UNNotificationResponse,
                                         withCompletionHandler completionHandler:
                                         @escaping () -> Void) {
        
        if response.actionIdentifier == UNNotificationDismissActionIdentifier {
            FNetmeraService.handleWork(FNetmeraService.ON_PUSH_DISMISS,dict:["userInfo" : response.notification.request.content.userInfo])
        }
        else if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            FNetmeraService.handleWork(FNetmeraService.ON_PUSH_OPEN, dict:["userInfo" : response.notification.request.content.userInfo])
        }
        completionHandler()
    }
    
    @available(iOS 10.0, *)
    override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([UNNotificationPresentationOptions.alert])
        
        if UIApplication.shared.applicationState == .active {
            FNetmeraService.handleWork(FNetmeraService.ON_PUSH_RECEIVE, dict:["userInfo" : notification.request.content.userInfo])
        } else {
            FNetmeraService.handleWork(FNetmeraService.ON_PUSH_RECEIVE_BACKGROUND, dict:["userInfo" : notification.request.content.userInfo])
        }
    }
    
}
