//
//  NotificationService.swift
//  NetmeraFlutterNotificationServiceExtension
//
//  Created by Inomera Research on 14.07.2022.
//

// Add this class to receive Media Push
import UserNotifications

import NetmeraNotificationServiceExtension

class NotificationService : NetmeraNotificationServiceExtension {

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (_ contentToDeliver: UNNotificationContent) -> Void) {
        super.didReceive(request, withContentHandler: contentHandler)
    }

    override func serviceExtensionTimeWillExpire() {
        super.serviceExtensionTimeWillExpire()
    }
}
