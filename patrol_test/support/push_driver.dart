import 'dart:convert';
import 'dart:io';

import 'package:netmera_flutter_sdk/Netmera.dart';
import 'package:patrol/patrol.dart';

import '../../integration_test/support/app_driver.dart';
import '../../integration_test/support/stub_client.dart';

/// Action types of a Netmera push (`act.at`).
const openAppAction = 0;
const deeplinkAction = 1;
const webViewAction = 2;

/// Delivers a Netmera push and taps its notification from the background, as a
/// user would.
///
/// Android gets the FCM data through the plugin entry the demo's
/// FirebaseMessaging handler uses; the iOS simulator gets an APNs payload
/// through `simctl push`.
Future<void> openPush(
  PatrolIntegrationTester $,
  StubClient stub, {
  required String pushId,
  required String title,
  required Map<String, Object?> action,
}) async {
  final nm = {
    'pid': pushId,
    'pt': 1,
    'act': action,
    // The server always sends custom JSON.
    'prms': <String, Object?>{},
  };
  await $.platform.mobile.pressHome();
  if (Platform.isIOS) {
    await stub.pushToSimulator({
      'aps': {
        'alert': {'title': title, 'body': 'Body'},
      },
      '_nm': nm,
    });
    // Opening Notification Center while the banner is still on screen swipes
    // the banner instead; it moves there on its own after a few seconds.
    await Future<void>.delayed(const Duration(seconds: 8));
  } else {
    // The sender id of the FCM message; the native suite uses the same
    // placeholder.
    Netmera.onNetmeraFirebasePushMessageReceived('0000000000', {
      '_nm': jsonEncode({
        ...nm,
        'ps': {'ctitle': title, 'ctext': 'Body'},
      }),
    });
  }
  await $.platform.mobile.openNotifications();
  await $.platform.mobile.tapOnNotificationBySelector(
    Selector(textContains: title),
    timeout: const Duration(seconds: 10),
  );
  await pumpFor($.tester, const Duration(seconds: 2));
}
