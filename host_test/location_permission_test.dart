@Timeout(Duration(minutes: 3))
library;

import 'package:flutter_test/flutter_test.dart';

import '../integration_test/support/stub_client.dart';
import 'support/app_device.dart';

const _locationAuthorization = 'n:la';
const _backgroundPermissionMissing = 'n:blp';
const _locationUpdate = 'n:lu';

/// Location authorization statuses the SDK reports in `n:la`.
const _denied = 2;
const _always = 3;
const _whenInUse = 4;

const Coordinate _istanbul = (latitude: 41.0082, longitude: 28.9784);

void main() {
  final device = AppDevice.fromEnvironment();
  final stub = StubClient();

  setUp(() async {
    await device.kill();
    await stub.reset();
    await device.installClean();
  });
  tearDown(device.resetLocation);
  tearDownAll(() async {
    await device.kill();
    stub.close();
  });

  Future<int?> launchAndWaitForAuthorization() async {
    final after = await stub.requestCount();
    await device.launch();
    final event = await stub.waitForEvent(_locationAuthorization, after: after);
    return eventAttributes(event)['fe'] as int?;
  }

  test('An Always permission is reported as Always', () async {
    await device.grantLocation(LocationPermission.always);

    expect(await launchAndWaitForAuthorization(), _always);
  });

  test('A When In Use permission is reported as When In Use', () async {
    await device.grantLocation(LocationPermission.whenInUse);

    expect(await launchAndWaitForAuthorization(), _whenInUse);
  });

  test(
    'A revoked permission is reported as Denied without the background permission event',
    () async {
      await device.grantLocation(LocationPermission.always);
      expect(await launchAndWaitForAuthorization(), _always);
      await device.kill();
      await device.revokeLocation();

      final after = await stub.requestCount();
      expect(await launchAndWaitForAuthorization(), _denied);
      await stub.expectNoEvent(_backgroundPermissionMissing, after: after);
    },
  );

  test('Location history sends location updates', () async {
    // Android checks location history only when geofences are configured.
    await stub.stubResponse('session/init', {
      'cfg': {
        'locHist': true,
        'geofs': [
          {
            'id': 'host-test',
            'lt': _istanbul.latitude,
            'lng': _istanbul.longitude,
            'r': 100,
          },
        ],
      },
    });
    await device.setLocation(_istanbul);
    final after = await stub.requestCount();
    if (device.isIos) {
      // iOS starts location updates when the permission changes while the
      // app runs.
      await device.launch();
      await stub.waitForRequest('session/init', after: after);
      await device.grantLocation(LocationPermission.always);
    } else {
      await device.grantLocation(LocationPermission.always);
      await device.launch();
    }

    await stub.waitForEvent(
      _locationUpdate,
      after: after,
      timeout: const Duration(seconds: 60),
    );
  });
}
