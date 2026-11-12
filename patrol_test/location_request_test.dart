import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../integration_test/support/app_driver.dart';
import '../integration_test/support/stub_client.dart';
import 'support/notification_driver.dart';

void main() {
  final stub = StubClient();
  tearDownAll(stub.close);
  setUp(stub.reset);

  // Each Patrol run starts from a fresh install, so the permission was never
  // asked.
  patrolTest(
    'Allowing location only while in use reports the missing background permission',
    ($) async {
      await launchAppWithNativeAutomation($);
      await openMenu($.tester, ['home.menu.location']);

      final after = await stub.requestCount();
      await tapKey($.tester, 'location.requestLocationAuthorization');
      await dismissPageSizeWarning($);
      await $.platform.mobile.grantPermissionWhenInUse();

      await stub.waitForEvent('n:blp', after: after);
    },
  );
}
