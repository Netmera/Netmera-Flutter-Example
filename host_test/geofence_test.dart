@Timeout(Duration(minutes: 6))
library;

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import '../integration_test/support/stub_client.dart';
import 'support/app_device.dart';

const _locationAuthorization = 'n:la';
const _monitoringDiagnostic = 'n:log';
const _geofenceTransition = 'n:gu';
const _entered = 0;
const _exited = 1;

const Coordinate _inside = (latitude: 41.0082, longitude: 28.9784);
// ~2 km north, outside the 150 m region.
const Coordinate _outside = (latitude: 41.0262, longitude: 28.9784);

// Android reports an enter only after the 20 s DWELL loitering delay.
const _transitionTimeout = Duration(minutes: 2);

Map<String, Object> _geofences(int count) => {
  'cfg': {
    'geofs': [
      for (var i = 0; i < count; i++)
        {
          'id': 'host-test-$i',
          'lt': _inside.latitude,
          'lng': _inside.longitude,
          'r': 150,
        },
    ],
  },
};

void main() {
  final device = AppDevice.fromEnvironment();
  final stub = StubClient();
  // The iOS SDK reports geofence monitoring as an n:log diagnostic; the
  // Android SDK only logs it locally.
  final skipOnAndroid = device.isIos
      ? null
      : 'The Android SDK does not report geofence monitoring';

  setUp(() async {
    await device.kill();
    await stub.reset();
    await device.installClean();
    // Without a known location the SDK reports the failed location request,
    // which is a geofence diagnostic too.
    await device.setLocation(_outside);
  });
  tearDown(device.resetLocation);
  tearDownAll(() async {
    await device.kill();
    stub.close();
  });

  bool monitoringStarted(Map<String, dynamic> event) {
    final attributes = eventAttributes(event);
    return attributes['ea'] == 'geofence' &&
        '${attributes['eb']}'.startsWith('Geofence monitoring started.');
  }

  // Monitoring needs location permission, so it is granted before launch.
  Future<void> launchWithLocationAlways() async {
    await device.grantLocation(LocationPermission.always);
    await device.launch();
  }

  test('Configured geofences are reported as monitored', () async {
    await stub.stubResponse('session/init', _geofences(2));
    await launchWithLocationAlways();

    final started = eventAttributes(
      await stub.waitForEvent(_monitoringDiagnostic, where: monitoringStarted),
    );
    expect(started['eb'], contains('configured=2'));
    expect(started['eb'], contains('monitoring=2'));
    expect(started['eb'], contains('controllerRegion=false'));
  }, skip: skipOnAndroid);

  test('No geofences send no monitoring diagnostic', () async {
    await launchWithLocationAlways();
    // Starts the window after the launch-time location report.
    await stub.waitForEvent(_locationAuthorization);

    await Future<void>.delayed(const Duration(seconds: 4));
    final diagnostics = (await stub.events()).where(
      (event) => eventAttributes(event)['ea'] == 'geofence',
    );
    expect(diagnostics, isEmpty);
  }, skip: skipOnAndroid);

  group('Geofence transitions', () {
    const regionId = 'host-test-0';

    setUp(() async {
      await stub.stubResponse('session/init', _geofences(1));
      await launchWithLocationAlways();
    });

    // iOS moves along a route; GMS samples the location only every few
    // seconds, so Android sets it again while waiting.
    Future<void> cross(Coordinate from, Coordinate to, int type) async {
      final after = await stub.requestCount();
      await device.moveAlongRoute(from, to);
      final keepMoving = device.isIos
          ? null
          : Timer.periodic(
              const Duration(seconds: 1),
              (_) => device.setLocation(to),
            );
      try {
        await stub.waitForEvent(
          _geofenceTransition,
          after: after,
          where: (event) =>
              eventAttributes(event)['fy'] == type &&
              eventAttributes(event)['ea'] == regionId,
          timeout: _transitionTimeout,
        );
      } finally {
        keepMoving?.cancel();
      }
    }

    test('Entering a region sends an enter event', () async {
      await cross(_outside, _inside, _entered);
    });

    test('Leaving a region sends an exit event', () async {
      // The SDK drops an exit without an earlier enter.
      await cross(_outside, _inside, _entered);

      await cross(_inside, _outside, _exited);
    });
  });
}
