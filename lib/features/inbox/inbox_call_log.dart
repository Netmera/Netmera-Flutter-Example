/// Remembers the last SDK call for the inbox developer panel.
class InboxCallLog {
  String? _call;
  bool _ok = true;
  int? _elapsedMs;

  Future<T> run<T>(String call, Future<T> Function() action) async {
    final watch = Stopwatch()..start();
    try {
      final result = await action();
      _record(call, ok: true, elapsedMs: watch.elapsedMilliseconds);
      return result;
    } catch (_) {
      _record(call, ok: false, elapsedMs: watch.elapsedMilliseconds);
      rethrow;
    }
  }

  /// For bridge calls that never complete a future, e.g. handlePushObject.
  void recordFireAndForget(String call) => _record(call, ok: true);

  void _record(String call, {required bool ok, int? elapsedMs}) {
    _call = call;
    _ok = ok;
    _elapsedMs = elapsedMs;
  }

  String get lastCallLine {
    final call = _call;
    if (call == null) return 'Last call: —';
    final timing = _elapsedMs == null ? '' : ' · $_elapsedMs ms';
    return 'Last call: $call → ${_ok ? 'OK' : 'error'}$timing';
  }
}
