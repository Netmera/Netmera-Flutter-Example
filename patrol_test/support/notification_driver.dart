import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:netmera_flutter_sdk/Netmera.dart';
import 'package:netmera_flutter_sdk/NotificationPermissionStatus.dart';
import 'package:patrol/patrol.dart';

import '../../integration_test/support/app_driver.dart';

Future<void> openNotificationPage(PatrolIntegrationTester $) async {
  await launchAppWithNativeAutomation($);
  await openMenu($.tester, ['home.menu.notification']);
}

/// Opens the Notification page and makes sure push permission is granted.
Future<void> openNotificationPageWithPushPermission(
  PatrolIntegrationTester $,
) async {
  await openNotificationPage($);
  if (await Netmera.checkNotificationPermission() !=
      NotificationPermissionStatus.granted) {
    await tapRegisterPushAndAllow($);
  }
}

Future<void> launchAppWithNativeAutomation(PatrolIntegrationTester $) async {
  // Native automation turns on iOS accessibility for the app; Flutter then
  // opens a semantics handle the test does not own and fails the test at its
  // end. The tests use no semantics finders, so the platform signal is ignored.
  final dispatcher = $.tester.binding.platformDispatcher;
  dispatcher.semanticsEnabledTestValue = false;
  addTearDown(dispatcher.clearSemanticsEnabledTestValue);

  await launchApp($.tester);
}

/// Taps Register Push and allows the system permission dialog.
Future<void> tapRegisterPushAndAllow(PatrolIntegrationTester $) async {
  await tapKey($.tester, 'notification.register');
  await dismissPageSizeWarning($);
  expect(
    await $.platform.mobile.isPermissionDialogVisible(
      timeout: const Duration(seconds: 5),
    ),
    isTrue,
    reason: 'The notification permission dialog did not open.',
  );
  await $.platform.mobile.grantPermissionWhenInUse();
  await pumpFor($.tester, const Duration(seconds: 1));
}

// Emulators with 16 KB pages warn about the app's non-aligned native
// libraries after every fresh install; the warning covers the permission
// dialog.
Future<void> dismissPageSizeWarning(PatrolIntegrationTester $) async {
  if (!Platform.isAndroid) return;
  try {
    await $.platform.android.tap(
      const AndroidSelector(text: 'OK'),
      timeout: const Duration(seconds: 3),
    );
  } on PatrolActionException {
    // The device shows no warning.
  }
}
