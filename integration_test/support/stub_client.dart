import 'dart:async';
import 'dart:convert';
import 'dart:io';

class RecordedRequest {
  RecordedRequest.fromJson(Map<String, dynamic> json)
    : method = json['method'] as String,
      path = json['path'] as String,
      query = json['query'] as String,
      headers = Map<String, String>.from(json['headers'] as Map),
      body = json['body'] as String;

  final String method;
  final String path;
  final String query;
  final Map<String, String> headers;
  final String body;

  Object? get jsonBody => body.isEmpty ? null : jsonDecode(body);

  @override
  String toString() => '$method $path';
}

/// Talks to `tool/stub_server.dart`, which runs on the host. On Android it is
/// reached through `adb reverse`; the iOS simulator shares the host loopback.
class StubClient {
  StubClient({this.port = 8089});

  final int port;
  final HttpClient _http = HttpClient();

  Uri _uri(String path) => Uri.parse('http://127.0.0.1:$port$path');

  Future<List<RecordedRequest>> requests() async {
    final request = await _http.getUrl(_uri('/__stub/requests'));
    final response = await request.close();
    final body = await utf8.decoder.bind(response).join();
    return (jsonDecode(body) as List)
        .map((item) => RecordedRequest.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> reset() => _post('/__stub/reset', {});

  /// Responses to paths containing [pathContains] return [body] instead of `{}`.
  Future<void> stubResponse(String pathContains, Object body) =>
      _post('/__stub/responses', {'pathContains': pathContains, 'body': body});

  /// Number of requests recorded so far. Pass it to [waitForRequest] as
  /// `after` to ignore requests sent before the step under test.
  Future<int> requestCount() async => (await requests()).length;

  Future<RecordedRequest> waitForRequest(
    String pathContains, {
    int after = 0,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final deadline = DateTime.now().add(timeout);
    var received = <RecordedRequest>[];
    while (DateTime.now().isBefore(deadline)) {
      received = await requests();
      for (final request in received.skip(after)) {
        if (request.path.contains(pathContains)) return request;
      }
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
    throw TimeoutException(
      'No request to "$pathContains". Received: $received',
    );
  }

  void close() => _http.close(force: true);

  Future<void> _post(String path, Object json) async {
    final request = await _http.postUrl(_uri(path));
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode(json));
    await (await request.close()).drain<void>();
  }
}
