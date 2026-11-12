import 'dart:convert';
import 'dart:io';

/// Stand-in for the Netmera backend during integration tests.
///
/// It runs on the host before the app starts, so the SDK's launch-time
/// requests (e.g. `session/init`) are not lost. Tests read what was received
/// and set responses through the `/__stub/*` control endpoints.
///
/// On iOS it also delivers pushes to the simulator through `simctl push`,
/// which tests running inside the app cannot call.
///
/// Usage: dart run tool/stub_server.dart [port] [simulator-udid]
Future<void> main(List<String> args) async {
  final port = args.isEmpty ? 8089 : int.parse(args.first);
  final simulator = args.length > 1 ? args[1] : null;
  final requests = <Map<String, Object?>>[];
  final responses = <String, _StubResponse>{};

  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  stdout.writeln('Stub server listening on http://127.0.0.1:$port');

  // Requests are handled concurrently, so a delayed response holds back only
  // its own request.
  server.listen((request) async {
    final response = request.response..headers.contentType = ContentType.json;
    try {
      final bytes = await request.fold<List<int>>(
        [],
        (all, chunk) => all..addAll(chunk),
      );
      final body = utf8.decode(bytes, allowMalformed: true);
      final path = request.uri.path;

      if (path == '/__stub/requests' && request.method == 'GET') {
        response.write(jsonEncode(requests));
      } else if (path == '/__stub/reset' && request.method == 'POST') {
        requests.clear();
        responses.clear();
        response.write('{}');
      } else if (path == '/__stub/responses' && request.method == 'POST') {
        final stub = jsonDecode(body) as Map<String, dynamic>;
        responses[stub['pathContains'] as String] = _StubResponse(
          body: stub.containsKey('body') ? jsonEncode(stub['body']) : '{}',
          status: stub['status'] as int? ?? HttpStatus.ok,
          delay: Duration(milliseconds: stub['delayMs'] as int? ?? 0),
        );
        response.write('{}');
      } else if (path == '/__stub/responses' && request.method == 'DELETE') {
        responses.clear();
        response.write('{}');
      } else if (path == '/__stub/push' && request.method == 'POST') {
        if (simulator == null) {
          throw StateError('Pushes are delivered only to an iOS simulator');
        }
        await _pushToSimulator(simulator, body);
        response.write('{}');
      } else {
        final headers = <String, String>{};
        request.headers.forEach(
          (name, values) => headers[name] = values.join(','),
        );
        requests.add({
          'method': request.method,
          'path': path,
          'query': request.uri.query,
          'headers': headers,
          'body': body,
        });
        final stubbed = responses.entries
            .where((entry) => path.contains(entry.key))
            .map((entry) => entry.value)
            .lastOrNull;
        if (stubbed != null) {
          await Future<void>.delayed(stubbed.delay);
          response.statusCode = stubbed.status;
        }
        response.write(stubbed?.body ?? '{}');
      }
    } catch (error) {
      stderr.writeln('Stub server could not handle ${request.uri}: $error');
      response
        ..statusCode = HttpStatus.internalServerError
        ..write(jsonEncode({'error': '$error'}));
    }
    try {
      await response.close();
    } on IOException {
      // The app was killed while its response was held back.
    }
  });
}

Future<void> _pushToSimulator(String udid, String payload) async {
  final directory = await Directory.systemTemp.createTemp('stub_push');
  try {
    final file = File('${directory.path}/push.apns')
      ..writeAsStringSync(payload);
    final result = await Process.run('xcrun', [
      'simctl',
      'push',
      udid,
      'com.netmera.demo.flutter',
      file.path,
    ]);
    if (result.exitCode != 0) throw StateError('${result.stderr}');
  } finally {
    await directory.delete(recursive: true);
  }
}

class _StubResponse {
  const _StubResponse({
    required this.body,
    required this.status,
    required this.delay,
  });

  final String body;
  final int status;
  final Duration delay;
}
