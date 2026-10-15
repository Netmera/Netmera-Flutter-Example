import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support/app_driver.dart';
import 'support/stub_client.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final stub = StubClient();
  tearDownAll(stub.close);
  setUp(stub.reset);

  Future<void> openUserPage(WidgetTester tester, String page) async {
    await launchApp(tester);
    await openMenu(tester, ['home.menu.user', 'user.menu.$page']);
  }

  group('Identify', () {
    testWidgets('Identify User sends user/update-identify', (tester) async {
      await openUserPage(tester, 'identify');
      await enterText(tester, 'userIdentify.userId', 'ui-test-user');

      final after = await stub.requestCount();
      await tapKey(tester, 'userIdentify.submit');

      final request = await stub.waitForRequest(
        'user/update-identify',
        after: after,
      );
      expect(request.body, contains('ui-test-user'));
    });

    testWidgets('Identify User With Callback sends user/update-identify', (
      tester,
    ) async {
      await openUserPage(tester, 'identify');
      await enterText(tester, 'userIdentify.email', 'uitest@example.com');

      final after = await stub.requestCount();
      await tapKey(tester, 'userIdentify.submitWithCallback');

      final request = await stub.waitForRequest(
        'user/update-identify',
        after: after,
      );
      expect(request.body, contains('uitest@example.com'));
    });
  });

  group('Update', () {
    Future<Map<String, dynamic>> update(
      WidgetTester tester, {
      String submitKey = 'userProfile.submit',
    }) async {
      final after = await stub.requestCount();
      await tapKey(tester, submitKey);
      final request = await stub.waitForRequest(
        'user/update-user-profile',
        after: after,
      );
      return (request.jsonBody as Map<String, dynamic>)['prfl']
          as Map<String, dynamic>;
    }

    Future<void> selectOperation(
      WidgetTester tester,
      String field,
      String operation,
    ) => tap(
      tester,
      find.descendant(
        of: find.byKey(ValueKey('userProfile.$field.operation')),
        matching: find.text(operation),
      ),
    );

    testWidgets('Name Set is sent as pa SET', (tester) async {
      await openUserPage(tester, 'update');
      await enterText(tester, 'userProfile.name.value', 'Ali');

      final profile = await update(tester);

      expect(profile['pa'], [
        {'opr': 'SET', 'value': 'Ali'},
      ]);
    });

    testWidgets('Update User With Callback sends the profile', (tester) async {
      await openUserPage(tester, 'update');
      await enterText(tester, 'userProfile.name.value', 'Test');

      final profile = await update(
        tester,
        submitKey: 'userProfile.submitWithCallback',
      );

      expect(profile['pa'], [
        {'opr': 'SET', 'value': 'Test'},
      ]);
    });

    testWidgets('An empty name is left out of the profile', (tester) async {
      await openUserPage(tester, 'update');
      // A profile without any change sends no request at all.
      await enterText(tester, 'userProfile.surname.value', 'Doe');

      final profile = await update(tester);

      expect(profile.containsKey('pa'), isFalse);
    });

    testWidgets('External segments Add is sent as pc ADD', (tester) async {
      await openUserPage(tester, 'update');
      await selectOperation(tester, 'externalSegments1', 'Add');
      await enterText(
        tester,
        'userProfile.externalSegments1.value',
        'seg1,seg2',
      );

      final profile = await update(tester);

      expect(profile['pc'], [
        {
          'opr': 'ADD',
          'value': ['seg1', 'seg2'],
        },
      ]);
    });

    testWidgets('External segments Remove is sent as pc REMOVE', (
      tester,
    ) async {
      await openUserPage(tester, 'update');
      await selectOperation(tester, 'externalSegments1', 'Remove');
      await enterText(tester, 'userProfile.externalSegments1.value', 'seg1');

      final profile = await update(tester);

      expect(profile['pc'], [
        {
          'opr': 'REMOVE',
          'value': ['seg1'],
        },
      ]);
    });
  });

  group('Settings', () {
    testWidgets('Opening the page reads the three permissions', (tester) async {
      await launchApp(tester);
      await openMenu(tester, ['home.menu.user']);

      final after = await stub.requestCount();
      await tapKey(tester, 'user.menu.settings');

      for (final path in const [
        'user/getEmailPermission',
        'user/getSmsPermission',
        'user/getWhatsAppPermission',
      ]) {
        await stub.waitForRequest(path, after: after);
      }
    });

    for (final (channel, path) in const [
      ('email', 'user/setEmailPermission'),
      ('sms', 'user/setSmsPermission'),
      ('whatsApp', 'user/setWhatsAppPermission'),
    ]) {
      testWidgets('Allow and Disallow $channel send $path', (tester) async {
        await openUserPage(tester, 'settings');

        var after = await stub.requestCount();
        await tapKey(tester, 'userSettings.$channel.allow');
        final allow = await stub.waitForRequest(path, after: after);
        expect((allow.jsonBody as Map<String, dynamic>)['allowed'], isTrue);

        // Disallow is skipped while the page already shows "false", so it is
        // tested right after Allow.
        after = await stub.requestCount();
        await tapKey(tester, 'userSettings.$channel.disallow');
        final disallow = await stub.waitForRequest(path, after: after);
        expect((disallow.jsonBody as Map<String, dynamic>)['allowed'], isFalse);
      });
    }
  });

  group('Coupons', () {
    Map<String, dynamic> filterOf(RecordedRequest request) {
      final body = request.jsonBody as Map<String, dynamic>;
      // iOS nests the paging under `filter`; Android sends it at the top.
      return (body['filter'] as Map<String, dynamic>?) ?? body;
    }

    testWidgets('Fetch Coupons sends the default page and size', (
      tester,
    ) async {
      await openUserPage(tester, 'coupons');

      final after = await stub.requestCount();
      await tapKey(tester, 'coupons.fetch');

      final request = await stub.waitForRequest('coupon/fetch', after: after);
      expect(filterOf(request), containsPair('page', 0));
      expect(filterOf(request), containsPair('max', 10));
    });

    testWidgets('Fetch Coupons sends the typed page and size', (tester) async {
      await openUserPage(tester, 'coupons');
      await enterText(tester, 'coupons.page.textField', '2');
      await enterText(tester, 'coupons.max.textField', '5');

      final after = await stub.requestCount();
      await tapKey(tester, 'coupons.fetch');

      final request = await stub.waitForRequest('coupon/fetch', after: after);
      expect(filterOf(request), containsPair('page', 2));
      expect(filterOf(request), containsPair('max', 5));
    });
  });
}
