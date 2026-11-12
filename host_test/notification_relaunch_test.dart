@Timeout(Duration(minutes: 3))
library;

import 'package:flutter_test/flutter_test.dart';

import '../integration_test/support/stub_client.dart';
import 'support/app_device.dart';

const _pushEnable = 'push/enable';
const _pushDisable = 'push/disable';

/// Covers the launch traffic and the late push requests the native suites
/// wait for.
const _window = Duration(seconds: 8);

void main() {
  final device = AppDevice.fromEnvironment();
  final stub = StubClient();
  final skipOnIos = device.isIos
      ? 'Push permission cannot be granted from the host on iOS'
      : null;

  setUp(() async {
    await device.kill();
    await stub.reset();
    await device.installClean();
    await device.grantPushPermission();
  });
  tearDownAll(() async {
    await device.kill();
    stub.close();
  });

  Future<int> countAfter(int after, String path) async =>
      (await stub.requests())
          .skip(after)
          .where((request) => request.path.contains(path))
          .length;

  Future<void> launchWithPushEnabled() async {
    await device.launch();
    await stub.waitForRequest(_pushEnable);
    await Future<void>.delayed(_window);
    await device.kill();
  }

  test(
    'A relaunch and a background stay without changes send no push request',
    () async {
      await launchWithPushEnabled();

      final after = await stub.requestCount();
      await device.launch();
      await stub.waitForRequest('session/init', after: after);
      await Future<void>.delayed(_window);
      await device.sendToBackground();
      await Future<void>.delayed(const Duration(seconds: 3));
      await device.bringToForeground();
      await Future<void>.delayed(_window);

      expect(await countAfter(after, _pushEnable), 0);
      expect(await countAfter(after, _pushDisable), 0);
    },
    skip: skipOnIos,
  );
}
