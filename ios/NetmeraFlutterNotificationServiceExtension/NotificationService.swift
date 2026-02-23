//
//  NotificationService.swift
//  NetmeraFlutterNotificationServiceExtension
//
//  Created by Netmera Research on 14.07.2022.
//

// Add this class to receive Media Push
import UserNotifications
import NetmeraNotificationServiceExtension

class NotificationService: NotificationServiceExtension {
  override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
    super.didReceive(request, withContentHandler: contentHandler)
  }

  override func serviceExtensionTimeWillExpire() {
    super.serviceExtensionTimeWillExpire()
  }
}
