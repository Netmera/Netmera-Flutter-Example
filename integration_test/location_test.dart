import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:permission_handler/permission_handler.dart';

import 'support/app_driver.dart';
import 'support/stub_client.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final stub = StubClient();
  tearDownAll(stub.close);

  // The diagnostic would be sent at launch, before the test could reset the
  // stub, so every recorded event is checked.
  testWidgets(
    'A launch without location permission sends no location failure diagnostic',
    (tester) async {
      expect(
        await Permission.locationWhenInUse.isGranted,
        isFalse,
        reason: 'The app must not have location permission',
      );
      await launchApp(tester);
      await stub.waitForRequest('session/init');
      await pumpFor(tester, const Duration(seconds: 10));

      final diagnostics = (await stub.events()).where((event) {
        final attributes = eventAttributes(event);
        return attributes['ea'] == 'geofence' &&
            '${attributes['eb']}'.contains('Location request failed');
      });
      expect(diagnostics, isEmpty);
    },
  );
}
