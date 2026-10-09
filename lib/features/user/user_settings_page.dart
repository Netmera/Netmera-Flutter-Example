import 'package:flutter/material.dart';
import 'package:netmera_flutter_example/ui/feedback.dart';
import 'package:netmera_flutter_example/ui/widgets/list_rows.dart';
import 'package:netmera_flutter_example/utils/category_channel_utils.dart';
import 'package:netmera_flutter_sdk/Netmera.dart';

class _Channel {
  const _Channel(this.id, this.name, this.get, this.set);

  final String id;
  final String name;
  final Future<bool> Function() get;
  final Future<void> Function(bool) set;
}

const _channels = [
  _Channel(
    'email',
    'Email',
    Netmera.getEmailPermission,
    Netmera.setEmailPermission,
  ),
  _Channel('sms', 'SMS', Netmera.getSmsPermission, Netmera.setSmsPermission),
  _Channel(
    'whatsApp',
    'WhatsApp',
    Netmera.getWhatsAppPermission,
    Netmera.setWhatsAppPermission,
  ),
];

class UserSettingsPage extends StatefulWidget {
  const UserSettingsPage({super.key});

  @override
  State<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  final Map<String, bool?> _permissions = {};
  String? _externalId;

  @override
  void initState() {
    super.initState();
    for (final channel in _channels) {
      channel.get().then((allowed) {
        // A tap that happened while this read was in flight wins.
        if (!mounted || _permissions.containsKey(channel.id)) return;
        setState(() => _permissions[channel.id] = allowed);
      }, onError: (_) {});
    }
    Netmera.getCurrentExternalId().then((id) {
      if (mounted) setState(() => _externalId = id);
    }, onError: (_) {});
  }

  void _setPermission(_Channel channel, bool allowed) {
    final previous = _permissions[channel.id];
    if (previous == allowed) return;
    setState(() => _permissions[channel.id] = allowed);
    // Not awaited: the Android bridge never completes these futures.
    channel.set(allowed).catchError((Object error) {
      if (!mounted) return;
      setState(() => _permissions[channel.id] = previous);
      showFeedback(
        '${channel.name} permission failed: ${errorMessage(error)}',
        style: FeedbackStyle.error,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SectionHeader('USER'),
        MenuRow(
          key: const ValueKey('userSettings.externalId'),
          title: 'Current External Id : ${_externalId ?? 'Not Set'}',
        ),
        for (final channel in _channels) ...[
          SectionHeader('${channel.name.toUpperCase()} PERMISSION'),
          MenuRow(
            key: ValueKey('userSettings.${channel.id}.allow'),
            title: 'Allow ${channel.name} Permission',
            onTap: () => _setPermission(channel, true),
          ),
          MenuRow(
            key: ValueKey('userSettings.${channel.id}.disallow'),
            title: 'Disallow ${channel.name} Permission',
            onTap: () => _setPermission(channel, false),
          ),
          MenuRow(
            key: ValueKey('userSettings.${channel.id}.status'),
            title:
                '${channel.name} Permission Status : '
                '${_permissions[channel.id]?.toString() ?? 'NaN'}',
          ),
        ],
      ],
    );
  }
}
