import 'dart:convert';
import 'dart:io';

/// Stand-in for the Netmera backend during integration tests.
///
/// It runs on the host before the app starts, so the SDK's launch-time
/// requests (e.g. `session/init`) are not lost. Tests running inside the app
/// read what was received through the `/__stub/*` control endpoints.
///
/// Usage: dart run tool/stub_server.dart [port]
Future<void> main(List<String> args) async {
  final port = args.isEmpty ? 8089 : int.parse(args.first);
  final requests = <Map<String, Object?>>[];
  final responses = <String, String>{};

  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  stdout.writeln('Stub server listening on http://127.0.0.1:$port');

  await for (final request in server) {
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
        responses[stub['pathContains'] as String] = jsonEncode(stub['body']);
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
        response.write(stubbed ?? '{}');
      }
    } catch (error) {
      stderr.writeln('Stub server could not handle ${request.uri}: $error');
      response
        ..statusCode = HttpStatus.internalServerError
        ..write(jsonEncode({'error': '$error'}));
    }
    await response.close();
  }
}
