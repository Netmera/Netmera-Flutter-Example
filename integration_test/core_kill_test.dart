import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support/app_driver.dart';
import 'support/stub_client.dart';

// Kill stops the SDK for the rest of the app process, so it has its own file
// (each file runs in a fresh app launch).
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final stub = StubClient();
  tearDownAll(stub.close);

  testWidgets('Kill Netmera: events are not sent afterwards', (tester) async {
    await launchApp(tester);
    // Killing before session/init finishes would race the SDK setup.
    await stub.waitForRequest('session/init');
    await openMenu(tester, ['home.menu.core', 'core.menu.kill']);

    final after = await stub.requestCount();
    await sendLoginEvent(tester);

    await stub.expectNoRequest('event/fire', after: after);
  });
}
