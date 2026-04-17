//
//  NotificationViewController.swift
//  NetmeraFlutterNotificationContentExtension
//
//  Created by Inomera Research on 14.07.2022.
//

// Add this class to receive Media Push
import UserNotifications
import UserNotificationsUI
import NetmeraNotificationContentExtension

class NotificationViewController: NotificationContentExtension {
  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func didReceive(_ notification: UNNotification) {
    super.didReceive(notification)
  }
}
