import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:netmera_flutter_example/features/events/event_senders.dart';

import 'support/app_driver.dart';
import 'support/stub_client.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final stub = StubClient();
  tearDownAll(stub.close);
  setUp(stub.reset);

  Future<Map<String, dynamic>> send(
    WidgetTester tester,
    String key,
    String code,
  ) async {
    final after = await stub.requestCount();
    await tapKey(tester, key);
    return stub.waitForEvent(code, after: after);
  }

  testWidgets('Standard events are sent with their codes', (tester) async {
    await launchApp(tester);
    await openMenu(tester, ['home.menu.events', 'events.menu.general']);
    await send(tester, 'general.menu.login', 'n:cl');
    await send(tester, 'general.menu.register', 'n:rg');

    await tester.pageBack();
    await openMenu(tester, ['events.menu.commerce']);
    final purchase = await send(tester, 'commerce.menu.purchase', 'n:ph');
    expect(eventAttributes(purchase)['ek'], 'INOMERACODE');
  });

  testWidgets('Use Generic Method: events are still sent', (tester) async {
    addTearDown(() => EventSenders.useGenericMethod = false);
    await launchApp(tester);
    await openMenu(tester, ['home.menu.events']);
    await tap(
      tester,
      find.descendant(
        of: find.byKey(const ValueKey('events.genericMethod')),
        matching: find.byType(Switch),
      ),
    );
    expect(EventSenders.useGenericMethod, isTrue);

    await openMenu(tester, ['events.menu.general']);
    await send(tester, 'general.menu.login', 'n:cl');
  });
}
