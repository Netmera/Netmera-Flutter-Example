import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../integration_test/support/app_driver.dart';
import '../integration_test/support/stub_client.dart';
import 'support/notification_driver.dart';

void main() {
  final stub = StubClient();
  tearDownAll(stub.close);
  setUp(stub.reset);

  patrolTest('Push Receiving switch disables and enables push', ($) async {
    // Without notification permission the SDK cannot turn push on.
    await openNotificationPageWithPushPermission($);

    final pushSwitch = find.descendant(
      of: find.byKey(const ValueKey('notification.pushReceiving')),
      matching: find.byType(Switch),
    );
    await pumpUntilFound($.tester, pushSwitch);
    // The page reads the current state on open.
    await pumpFor($.tester, const Duration(seconds: 1));

    // Push that was never on is first registered (push/register), so start
    // from "on", as the native suites do.
    if (!$.tester.widget<Switch>(pushSwitch).value) {
      final after = await stub.requestCount();
      await tap($.tester, pushSwitch);
      await stub.waitForRequest('push/', after: after);
    }

    for (final path in const ['push/disable', 'push/enable']) {
      final after = await stub.requestCount();
      await tap($.tester, pushSwitch);

      final request = await stub.waitForRequest(path, after: after);
      expect(request.body, isNotEmpty);
    }
  });
}
