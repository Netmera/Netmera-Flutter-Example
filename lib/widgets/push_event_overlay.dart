import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:netmera_flutter_example/utils/push_event_bus.dart';

class PushEventOverlay extends StatefulWidget {
  final Widget child;
  const PushEventOverlay({required this.child, super.key});

  @override
  State<PushEventOverlay> createState() => _PushEventOverlayState();
}

class _PushEventOverlayState extends State<PushEventOverlay> {
  final List<PushEvent> _events = [];
  bool _visible = false;
  late StreamSubscription<PushEvent> _sub;

  static const _encoder = JsonEncoder.withIndent('  ');

  @override
  void initState() {
    super.initState();
    _sub = pushEventStream.listen((event) {
      setState(() {
        _events.insert(0, event);
        _visible = true;
      });
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  void _close() => setState(() => _visible = false);

  void _clear() => setState(() {
        _events.clear();
        _visible = false;
      });

  String _format(Map<String, dynamic> data) {
    try {
      return _encoder.convert(_toJsonSafe(data));
    } catch (_) {
      return data.toString();
    }
  }

  dynamic _toJsonSafe(dynamic value) {
    if (value == null || value is bool || value is num || value is String) return value;
    if (value is List) return value.map(_toJsonSafe).toList();
    if (value is Map) return value.map((k, v) => MapEntry(k.toString(), _toJsonSafe(v)));
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_visible) _buildOverlay(context),
      ],
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final size = MediaQuery.of(context).size;

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _close,
        child: Container(
          color: Colors.black54,
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.all(16),
                constraints: BoxConstraints(maxHeight: size.height * 0.8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(primary),
                    Flexible(child: _buildEventList(primary)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color primary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: primary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Push Callbacks',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          TextButton(
            onPressed: _clear,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              minimumSize: Size.zero,
            ),
            child: const Text('Clear', style: TextStyle(color: Colors.white, fontSize: 13)),
          ),
          GestureDetector(
            onTap: _close,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventList(Color primary) {
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.all(12),
      itemCount: _events.length,
      separatorBuilder: (_, __) => const Divider(height: 16),
      itemBuilder: (context, i) {
        final e = _events[i];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              e.event,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: primary),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: SelectableText(
                _format(e.data),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.black87),
              ),
            ),
          ],
        );
      },
    );
  }
}
