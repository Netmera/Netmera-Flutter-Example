@Timeout(Duration(minutes: 3))
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../integration_test/support/stub_client.dart';
import 'support/app_device.dart';

const _sessionInit = 'session/init';

/// Fields every device fills; operator and region depend on the SIM.
const _deviceInfoKeys = ['mdl', 'osV', 'mnf', 'lang', 'appV'];

/// Time for the SDK to handle the session/init response before the app dies.
const _settle = Duration(seconds: 3);

void main() {
  final device = AppDevice.fromEnvironment();
  final stub = StubClient();

  setUp(() async {
    await device.kill();
    await stub.reset();
    await device.installClean();
  });
  tearDownAll(() async {
    await device.kill();
    stub.close();
  });

  Map<String, dynamic> bodyOf(RecordedRequest request) =>
      request.jsonBody as Map<String, dynamic>;

  Map<String, dynamic> idsOf(Map<String, dynamic> body) =>
      body['ids'] as Map<String, dynamic>? ?? {};

  void expectFullDeviceInfo(Map<String, dynamic> body) {
    final info = body['info'] as Map<String, dynamic>? ?? {};
    final missing = _deviceInfoKeys.where(
      (key) => '${info[key] ?? ''}'.isEmpty,
    );
    expect(missing, isEmpty, reason: 'session/init info: $info');
  }

  Future<Map<String, dynamic>> launchAndWaitForSessionInit() async {
    final after = await stub.requestCount();
    await device.launch();
    return bodyOf(await stub.waitForRequest(_sessionInit, after: after));
  }

  /// A request queued by the failed launch may be re-sent after the relaunch;
  /// it keeps its session id, so only the new session's init is returned.
  Future<Map<String, dynamic>> relaunchAndWaitForNewSessionInit(
    String failedSid,
  ) async {
    final after = await stub.requestCount();
    await device.launch();
    return bodyOf(
      await stub.waitForRequest(
        _sessionInit,
        after: after,
        where: (request) => idsOf(bodyOf(request))['sid'] != failedSid,
        timeout: const Duration(seconds: 30),
      ),
    );
  }

  test(
    'A relaunch without changes sends empty info with the same iid',
    () async {
      final first = await launchAndWaitForSessionInit();
      expectFullDeviceInfo(first);
      final iid = idsOf(first)['iid'] as String?;
      expect(iid, isNotEmpty);
      await Future<void>.delayed(_settle);
      await device.kill();

      final second = await launchAndWaitForSessionInit();
      expect(second['info'], isEmpty);
      expect(idsOf(second)['iid'], iid);
    },
  );

  for (final status in [
    HttpStatus.badRequest,
    HttpStatus.internalServerError,
  ]) {
    test(
      'A session/init failing with $status sends full info on the next launch',
      () async {
        await stub.stubStatus(_sessionInit, status: status);
        final failed = await launchAndWaitForSessionInit();
        expectFullDeviceInfo(failed);
        await Future<void>.delayed(_settle);
        await device.kill();
        await stub.clearResponses();

        expectFullDeviceInfo(
          await relaunchAndWaitForNewSessionInit(idsOf(failed)['sid']),
        );
      },
    );
  }

  test(
    'A kill before the session/init response sends full info on the next launch',
    () async {
      await stub.stubStatus(_sessionInit, delay: const Duration(seconds: 15));
      final unanswered = await launchAndWaitForSessionInit();
      expectFullDeviceInfo(unanswered);
      await device.kill();
      await stub.clearResponses();

      expectFullDeviceInfo(
        await relaunchAndWaitForNewSessionInit(idsOf(unanswered)['sid']),
      );
    },
  );
}
