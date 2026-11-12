import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:netmera_flutter_example/main.dart' as app;

import 'support/stub_client.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final stub = StubClient();

  tearDownAll(stub.close);

  testWidgets('SDK sends session/init to the stub server at launch', (
    tester,
  ) async {
    app.main();
    await tester.pump(const Duration(seconds: 2));

    final request = await stub.waitForRequest('session/init');
    expect(request.method, 'POST');
  });
}
