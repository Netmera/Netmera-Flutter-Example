import 'package:flutter_test/flutter_test.dart';
import 'package:netmera_flutter_sdk/Netmera.dart';
import 'package:netmera_flutter_sdk/NotificationPermissionStatus.dart';
import 'package:patrol/patrol.dart';

import '../integration_test/support/stub_client.dart';
import 'support/notification_driver.dart';

void main() {
  final stub = StubClient();
  tearDownAll(stub.close);
  setUp(stub.reset);

  patrolTest('Register Push: allowing the permission enables push', (
    $,
  ) async {
    await openNotificationPage($);
    // Each file runs on a fresh install; any other state means the test would
    // not exercise the permission request at all.
    expect(
      await Netmera.checkNotificationPermission(),
      NotificationPermissionStatus.notDetermined,
    );

    final after = await stub.requestCount();
    await tapRegisterPushAndAllow($);

    expect(
      await Netmera.checkNotificationPermission(),
      NotificationPermissionStatus.granted,
    );
    final request = await stub.waitForRequest('push/enable', after: after);
    expect(request.body, isNotEmpty);
  });
}
