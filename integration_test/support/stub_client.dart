import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Event attributes: Android nests them under `prms`, iOS keeps them on the
/// event itself.
Map<String, dynamic> eventAttributes(Map<String, dynamic> event) =>
    (event['prms'] as Map<String, dynamic>?) ?? event;

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

  /// Responses to paths containing [pathContains] get [status] and are held
  /// back for [delay].
  Future<void> stubStatus(
    String pathContains, {
    int status = HttpStatus.ok,
    Duration delay = Duration.zero,
  }) => _post('/__stub/responses', {
    'pathContains': pathContains,
    'status': status,
    'delayMs': delay.inMilliseconds,
  });

  /// Delivers an APNs [payload] to the iOS simulator the stub was started for.
  Future<void> pushToSimulator(Map<String, Object?> payload) =>
      _post('/__stub/push', payload);

  /// Removes stubbed responses but keeps the recorded requests.
  Future<void> clearResponses() async => _expectOk(
    await (await _http.deleteUrl(_uri('/__stub/responses'))).close(),
  );

  /// Number of requests recorded so far. Pass it to [waitForRequest] as
  /// `after` to ignore requests sent before the step under test.
  Future<int> requestCount() async => (await requests()).length;

  /// Waits for a request to [pathContains] that also matches [where].
  Future<RecordedRequest> waitForRequest(
    String pathContains, {
    int after = 0,
    bool Function(RecordedRequest request)? where,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final deadline = DateTime.now().add(timeout);
    var received = <RecordedRequest>[];
    while (DateTime.now().isBefore(deadline)) {
      received = await requests();
      for (final request in received.skip(after)) {
        if (request.path.contains(pathContains) &&
            (where?.call(request) ?? true)) {
          return request;
        }
      }
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
    throw TimeoutException(
      'No request to "$pathContains". Received: $received',
    );
  }

  /// Fails if a request to [pathContains] arrives within [window]; native
  /// suites use the same short negative window.
  Future<void> expectNoRequest(
    String pathContains, {
    required int after,
    Duration window = const Duration(seconds: 4),
  }) async {
    await Future<void>.delayed(window);
    final received = (await requests())
        .skip(after)
        .where((request) => request.path.contains(pathContains))
        .toList();
    if (received.isNotEmpty) {
      throw StateError('Unexpected request to "$pathContains": $received');
    }
  }

  /// Events of the `event/fire` requests recorded after [after]
  /// (`{"events": [{"code": ..., ...}]}`).
  Future<List<Map<String, dynamic>>> events({int after = 0}) async => [
    for (final request in (await requests()).skip(after))
      if (request.path.contains('event/fire'))
        for (final event
            in (request.jsonBody as Map<String, dynamic>)['events'] as List)
          event as Map<String, dynamic>,
  ];

  /// Fails if an event with [code] is fired within [window].
  Future<void> expectNoEvent(
    String code, {
    required int after,
    Duration window = const Duration(seconds: 4),
  }) async {
    await Future<void>.delayed(window);
    final fired = (await events(
      after: after,
    )).where((event) => event['code'] == code).toList();
    if (fired.isNotEmpty) {
      throw StateError('Unexpected event "$code": $fired');
    }
  }

  /// Waits for an event with [code] that also matches [where] and returns it.
  Future<Map<String, dynamic>> waitForEvent(
    String code, {
    int after = 0,
    bool Function(Map<String, dynamic> event)? where,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      for (final event in await events(after: after)) {
        if (event['code'] == code && (where?.call(event) ?? true)) return event;
      }
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
    final codes = (await events(after: after)).map((event) => event['code']);
    throw TimeoutException('No matching event "$code". Received: $codes');
  }

  void close() => _http.close(force: true);

  Future<void> _post(String path, Object json) async {
    final request = await _http.postUrl(_uri(path));
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode(json));
    await _expectOk(await request.close());
  }

  /// A failed stub action (e.g. `simctl push`) would otherwise surface only
  /// later as a missing request or notification.
  Future<void> _expectOk(HttpClientResponse response) async {
    final body = await utf8.decoder.bind(response).join();
    if (response.statusCode != HttpStatus.ok) {
      throw StateError('Stub server returned ${response.statusCode}: $body');
    }
  }
}
