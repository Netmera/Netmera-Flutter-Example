import 'dart:io';

const _appId = 'com.netmera.demo.flutter';

enum LocationPermission { whenInUse, always }

typedef Coordinate = ({double latitude, double longitude});

/// Controls the demo app from the host, the way XCUITest drives an app from
/// outside its process. These tests restart the app or change its permissions
/// before launch, which a test running inside the app cannot do.
///
/// `tool/run_integration_tests.sh` builds the app and passes the device id and
/// app path as dart-defines.
abstract class AppDevice {
  factory AppDevice.fromEnvironment() {
    const device = String.fromEnvironment('HOST_TEST_DEVICE');
    const app = String.fromEnvironment('HOST_TEST_APP');
    if (device.isEmpty || app.isEmpty) {
      throw StateError(
        'Run through tool/run_integration_tests.sh <device-id> host_test',
      );
    }
    return app.endsWith('.apk')
        ? _AndroidDevice(device, app)
        : _IosSimulator(device, app);
  }

  bool get isIos;

  /// Removes the app with its data and installs it again.
  Future<void> installClean();

  Future<void> grantPushPermission();

  /// Works before launch and, like a change in Settings, while the app runs.
  Future<void> grantLocation(LocationPermission permission);

  Future<void> revokeLocation();

  Future<void> setLocation(Coordinate location);

  /// Moves the device from [from] to [to] at driving speed. iOS region
  /// monitoring reacts to this, not reliably to a jump; on Android it sets
  /// [to], which callers repeat while GMS samples the location.
  Future<void> moveAlongRoute(Coordinate from, Coordinate to);

  /// Undoes what [setLocation] changed on the device.
  Future<void> resetLocation();

  Future<void> launch();

  Future<void> kill();

  Future<void> sendToBackground();

  /// Brings the running app back without restarting it.
  Future<void> bringToForeground();
}

class _AndroidDevice implements AppDevice {
  _AndroidDevice(this.serial, this.apk);

  final String serial;
  final String apk;

  @override
  bool get isIos => false;

  @override
  Future<void> installClean() async {
    await _adb(['uninstall', _appId], check: false);
    await _adb(['install', apk]);
  }

  @override
  Future<void> grantPushPermission() => _adb([
    'shell',
    'pm',
    'grant',
    _appId,
    'android.permission.POST_NOTIFICATIONS',
  ]);

  @override
  Future<void> grantLocation(LocationPermission permission) async {
    for (final name in _locationPermissions(permission)) {
      await _adb(['shell', 'pm', 'grant', _appId, name]);
    }
  }

  @override
  Future<void> revokeLocation() async {
    for (final name in _locationPermissions(LocationPermission.always)) {
      await _adb(['shell', 'pm', 'revoke', _appId, name]);
    }
  }

  static List<String> _locationPermissions(LocationPermission permission) => [
    'android.permission.ACCESS_FINE_LOCATION',
    'android.permission.ACCESS_COARSE_LOCATION',
    if (permission == LocationPermission.always)
      'android.permission.ACCESS_BACKGROUND_LOCATION',
  ];

  // A platform test provider, the same one android-demo's MockLocationProvider
  // uses; GMS picks it up.
  @override
  Future<void> setLocation(Coordinate location) async {
    if (!_testProviderAdded) {
      await _adb([
        'shell',
        'appops',
        'set',
        'com.android.shell',
        'android:mock_location',
        'allow',
      ]);
      await _location(['add-test-provider', 'gps'], check: false);
      await _location(['set-test-provider-enabled', 'gps', 'true']);
      _testProviderAdded = true;
    }
    await _location([
      'set-test-provider-location',
      'gps',
      '--location',
      '${location.latitude},${location.longitude}',
      '--accuracy',
      '5',
    ]);
  }

  @override
  Future<void> moveAlongRoute(Coordinate from, Coordinate to) =>
      setLocation(to);

  var _testProviderAdded = false;

  @override
  Future<void> resetLocation() async {
    _testProviderAdded = false;
    await _location(['remove-test-provider', 'gps'], check: false);
    await _adb([
      'shell',
      'appops',
      'set',
      'com.android.shell',
      'android:mock_location',
      'default',
    ]);
  }

  Future<void> _location(List<String> args, {bool check = true}) =>
      _adb(['shell', 'cmd', 'location', 'providers', ...args], check: check);

  @override
  Future<void> launch() => _adb([
    'shell',
    'monkey',
    '-p',
    _appId,
    '-c',
    'android.intent.category.LAUNCHER',
    '1',
  ]);

  @override
  Future<void> kill() => _adb(['shell', 'am', 'force-stop', _appId]);

  @override
  Future<void> sendToBackground() =>
      _adb(['shell', 'input', 'keyevent', 'KEYCODE_HOME']);

  // The launcher intent resumes the existing singleTask activity.
  @override
  Future<void> bringToForeground() => launch();

  // The adb the script set up `adb reverse` with; another adb version would
  // restart the server and drop the mapping.
  Future<void> _adb(List<String> args, {bool check = true}) => _run(
    const String.fromEnvironment('HOST_TEST_ADB', defaultValue: 'adb'),
    ['-s', serial, ...args],
    check: check,
  );
}

class _IosSimulator implements AppDevice {
  _IosSimulator(this.udid, this.app);

  final String udid;
  final String app;

  @override
  bool get isIos => true;

  @override
  Future<void> installClean() async {
    await _simctl(['uninstall', udid, _appId], check: false);
    await _simctl(['install', udid, app]);
  }

  @override
  Future<void> grantPushPermission() => throw UnsupportedError(
    'simctl privacy cannot grant notification permission',
  );

  @override
  Future<void> grantLocation(LocationPermission permission) => _simctl([
    'privacy',
    udid,
    'grant',
    permission == LocationPermission.always ? 'location-always' : 'location',
    _appId,
  ]);

  @override
  Future<void> revokeLocation() =>
      _simctl(['privacy', udid, 'revoke', 'location-always', _appId]);

  @override
  Future<void> setLocation(Coordinate location) => _simctl([
    'location',
    udid,
    'set',
    '${location.latitude},${location.longitude}',
  ]);

  @override
  Future<void> moveAlongRoute(Coordinate from, Coordinate to) => _simctl([
    'location',
    udid,
    'start',
    '--speed=150',
    '${from.latitude},${from.longitude}',
    '${to.latitude},${to.longitude}',
  ]);

  @override
  Future<void> resetLocation() => _simctl(['location', udid, 'clear']);

  @override
  Future<void> launch() => _simctl(['launch', udid, _appId]);

  @override
  Future<void> kill() => _simctl(['terminate', udid, _appId], check: false);

  @override
  Future<void> sendToBackground() =>
      _simctl(['launch', udid, 'com.apple.Preferences']);

  // Without --terminate-running-process, simctl only activates a running app.
  @override
  Future<void> bringToForeground() => launch();

  Future<void> _simctl(List<String> args, {bool check = true}) =>
      _run('xcrun', ['simctl', ...args], check: check);
}

Future<void> _run(
  String executable,
  List<String> args, {
  required bool check,
}) async {
  final result = await Process.run(executable, args);
  if (check && result.exitCode != 0) {
    throw ProcessException(
      executable,
      args,
      '${result.stdout}${result.stderr}',
      result.exitCode,
    );
  }
}
