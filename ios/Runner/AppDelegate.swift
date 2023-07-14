///
/// Copyright (c) 2022 Inomera Research.
///

import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate,NetmeraPushDelegate {
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
            self.application(application, didReceiveRemoteNotification: notification as! [AnyHashable : Any])
        }
        
        var keys: NSDictionary?
        
        if let path = Bundle.main.path(forResource: "keys", ofType: "plist") {
            keys = NSDictionary(contentsOfFile: path)
        }
        if let dict = keys {
            let netmeraApiKey = dict["netmera-api-key"] as? String
        
            FNetmera.logging(true) // Enable Netmera logging
            FNetmera.initNetmera(netmeraApiKey) // Your Netmera api key.
            FNetmera.setPushDelegate(self)
            Netmera.setAppGroupName("group.com.netmera.flutter") // Your app group name
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        FNetmeraService.handleWork(ON_PUSH_REGISTER, dict: ["pushToken": deviceToken])
    }
    
    override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        if UIApplication.shared.applicationState == .active {
            FNetmeraService.handleWork(ON_PUSH_RECEIVE, dict:["userInfo" : userInfo])
        } else {
            FNetmeraService.handleWork(ON_PUSH_RECEIVE_BACKGROUND, dict:["userInfo" : userInfo])
        }
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
    }
    
}
