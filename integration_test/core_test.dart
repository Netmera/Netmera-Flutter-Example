import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:netmera_flutter_sdk/Netmera.dart';

import 'support/app_driver.dart';
import 'support/stub_client.dart';

const _loginEvent = 'n:cl';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final stub = StubClient();
  tearDownAll(stub.close);
  setUp(stub.reset);

  testWidgets('Enable Data: events are sent', (tester) async {
    await launchApp(tester);
    await openMenu(tester, ['home.menu.core', 'core.menu.enableData']);

    final after = await stub.requestCount();
    await sendLoginEvent(tester);

    await stub.waitForEvent(_loginEvent, after: after);
  });

  testWidgets('Disable Data: events are not sent', (tester) async {
    addTearDown(Netmera.startDataTransfer);
    await launchApp(tester);
    await openMenu(tester, ['home.menu.core', 'core.menu.disableData']);

    final after = await stub.requestCount();
    await sendLoginEvent(tester);

    await stub.expectNoRequest('event/fire', after: after);
  });
}
