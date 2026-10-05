import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netmera_flutter_example/example_push_token.dart';
import 'package:netmera_flutter_example/ui/feedback.dart';
import 'package:netmera_flutter_example/ui/widgets/list_rows.dart';
import 'package:netmera_flutter_example/ui/widgets/states.dart';
import 'package:netmera_flutter_example/utils/category_channel_utils.dart';
import 'package:netmera_flutter_sdk/Netmera.dart';

class DeviceInfoPage extends StatefulWidget {
  const DeviceInfoPage({super.key});

  @override
  State<DeviceInfoPage> createState() => _DeviceInfoPageState();
}

class _DeviceInfoPageState extends State<DeviceInfoPage> {
  String? _externalId;
  bool? _pushEnabled;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    try {
      final externalId = await Netmera.getCurrentExternalId();
      final pushEnabled = await Netmera.isPushEnabled();
      if (!mounted) return;
      setState(() {
        _externalId = externalId;
        _pushEnabled = pushEnabled;
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

  @override
  Widget build(BuildContext context) {
    final token = ExamplePushToken.value;
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SectionHeader('PUSH TOKEN'),
          MonoPanel(
            token.isEmpty ? '—' : token,
            key: const ValueKey('deviceInfo.token'),
          ),
          const SectionHeader('USER'),
          StatusRow(
            key: const ValueKey('deviceInfo.externalId'),
            title: 'External ID',
            value: _externalId ?? '—',
            onTap: _externalId == null
                ? null
                : () => _copy('External ID', _externalId!),
          ),
          StatusRow(
            key: const ValueKey('deviceInfo.pushEnabled'),
            title: 'Push Enabled',
            value: _pushEnabled?.toString() ?? '—',
            showDivider: false,
          ),
        ],
      ),
    );
  }
}
