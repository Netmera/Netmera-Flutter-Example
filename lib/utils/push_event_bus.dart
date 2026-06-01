import 'dart:async';

class PushEvent {
  final String event;
  final Map<String, dynamic> data;
  const PushEvent({required this.event, required this.data});
}

final StreamController<PushEvent> _controller = StreamController.broadcast();

Stream<PushEvent> get pushEventStream => _controller.stream;

void emitPushEvent(String event, Map<String, dynamic> data) {
  _controller.add(PushEvent(event: event, data: data));
}
