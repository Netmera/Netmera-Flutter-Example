import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netmera_flutter_example/example_push_token.dart';
import 'package:netmera_flutter_example/ui/feedback.dart';
import 'package:netmera_flutter_example/ui/widgets/list_rows.dart';
import 'package:netmera_flutter_example/utils/category_channel_utils.dart';
import 'package:netmera_flutter_sdk/Netmera.dart';

class DeviceInfoPage extends StatefulWidget {
  const DeviceInfoPage({super.key});

  @override
  State<DeviceInfoPage> createState() => _DeviceInfoPageState();
}

class _DeviceInfoPageState extends State<DeviceInfoPage> {
  static const _encoder = JsonEncoder.withIndent('  ');

  String? _externalId;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    try {
      final externalId = await Netmera.getCurrentExternalId();
      if (!mounted) return;
      setState(() {
        _externalId = externalId;
      });
    } catch (error) {
      showFeedback(
        'Could not load device info: ${errorMessage(error)}',
        style: FeedbackStyle.error,
      );
    }
  }

  Future<void> _copy(String label, String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    showFeedback('$label copied');
  }

  Widget _jsonRow(String id, String title, Map<String, Object?> value) {
    final json = _encoder.convert(value);
    return MenuRow(
      key: ValueKey('deviceInfo.$id'),
      title: title,
      subtitle: json,
      onTap: () => _copy(title, json),
    );
  }

  @override
  Widget build(BuildContext context) {
    final token = ExamplePushToken.value;
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _jsonRow('identifiers', 'NetmeraIdentifiers', {
            'externalId': _externalId,
          }),
          _jsonRow('token', 'Token', {'token': token.isEmpty ? null : token}),
        ],
      ),
    );
  }
}
