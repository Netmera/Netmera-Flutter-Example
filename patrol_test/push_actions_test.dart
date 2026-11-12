import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../integration_test/support/app_driver.dart';
import '../integration_test/support/stub_client.dart';
import 'support/notification_driver.dart';
import 'support/push_driver.dart';

/// The template comes from session/init, which push_actions_test.stub.json
/// answers before the app starts; its image lets the stub see it rendered.
const _templateId = 'e2e_template';

/// The scheme each app registers.
final _deeplink = Platform.isIOS
    ? 'netmerademoflutter://e2e-deeplink?key=value'
    : 'netmeraflutterexample://e2e-deeplink?key=value';

void main() {
  // Resetting would drop the launch-time responses from the seed file.
  final stub = StubClient();
  tearDownAll(stub.close);

  patrolTest('Opening a push sends push open with its push id', ($) async {
    await openNotificationPageWithPushPermission($);
    final after = await stub.requestCount();
    await openPush(
      $,
      stub,
      pushId: 'e2e-open',
      title: 'E2E open app',
      action: {'at': openAppAction},
    );

    final pushOpen = await stub.waitForEvent('n:po', after: after);
    expect(eventAttributes(pushOpen)['fs'], 'e2e-open');
  });

  patrolTest('A deeplink push opens its URL in the app', ($) async {
    await openNotificationPageWithPushPermission($);
    await openPush(
      $,
      stub,
      pushId: 'e2e-deeplink',
      title: 'E2E deeplink',
      action: {'at': deeplinkAction, 'uri': _deeplink},
    );

    await pumpUntilFound($.tester, find.text('Deeplink url is: $_deeplink'));
  });

  patrolTest('A web view push loads its URL', ($) async {
    await openNotificationPageWithPushPermission($);
    final after = await stub.requestCount();
    await openPush(
      $,
      stub,
      pushId: 'e2e-web-view',
      title: 'E2E web view',
      action: {
        'at': webViewAction,
        'url': 'http://127.0.0.1:${stub.port}/e2e-web-view',
      },
    );

    await stub.waitForRequest('/e2e-web-view', after: after);
  });

  patrolTest('A template push shows the template from the app config', (
    $,
  ) async {
    await openNotificationPageWithPushPermission($);
    final after = await stub.requestCount();
    await openPush(
      $,
      stub,
      pushId: 'e2e-template',
      title: 'E2E template',
      // The iOS SDK shows a template only with its parameters.
      action: {'at': webViewAction, 'tid': _templateId, 'tprms': {}},
    );

    await stub.waitForRequest('/e2e-template-image', after: after);
  });
}
