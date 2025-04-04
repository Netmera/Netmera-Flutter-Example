///
/// Copyright (c) 2022 Inomera Research.
///

import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate, NetmeraPushDelegate {
    private let CHANNEL = "nm_flutter_example_channel"

    let NETMERA_UAT_API_KEY = "gFtyH_nz5WCdXraTsOOgL25er1sBpuQdFa8bAMVGhv9Xo5voVRPFY2gFcVkuTQeZIgoa3gN1rww"
    let NETMERA_UAT_BASE_URL = "https://sdk-cloud-uat.sdpaas.com"

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
            FNetmeraService.handleWork(ON_PUSH_RECEIVE, dict:["userInfo" : notification])
        }
        
        let netmeraApiKey = UserDefaults.standard.string(forKey: "apiKey") ?? NETMERA_UAT_API_KEY
        let baseUrl = UserDefaults.standard.string(forKey: "baseUrl") ?? NETMERA_UAT_BASE_URL
        
        FNetmera.logging(true) // Enable Netmera logging
        FNetmera.initNetmera(netmeraApiKey ?? "") // Your Netmera api key.
        Netmera.setBaseURL(baseUrl ?? "")
        FNetmera.setPushDelegate(self)
        Netmera.setAppGroupName("group.com.netmera.flutter") // Your app group name
        
        
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
        FNetmeraService.handleWork(ON_PUSH_REGISTER, dict: ["pushToken": deviceToken])
    }
    
    @available(iOS 10.0, *)
    override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                         didReceive response: UNNotificationResponse,
                                         withCompletionHandler completionHandler:
                                         @escaping () -> Void) {
        
        if response.actionIdentifier == UNNotificationDismissActionIdentifier {
            FNetmeraService.handleWork(ON_PUSH_DISMISS,dict:["userInfo" : response.notification.request.content.userInfo])
        }
        else if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            FNetmeraService.handleWork(ON_PUSH_OPEN, dict:["userInfo" : response.notification.request.content.userInfo])
        }
        completionHandler()
    }
    
    @available(iOS 10.0, *)
    override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([UNNotificationPresentationOptions.alert])
        
        if UIApplication.shared.applicationState == .active {
            FNetmeraService.handleWork(ON_PUSH_RECEIVE, dict:["userInfo" : notification.request.content.userInfo])
        } else {
            FNetmeraService.handleWork(ON_PUSH_RECEIVE_BACKGROUND, dict:["userInfo" : notification.request.content.userInfo])
        }
    }
    
}

private enum MethodName: String {
    case SET_API_KEY = "setApiKey"
    case SET_BASE_URL = "setBaseUrl"
}
