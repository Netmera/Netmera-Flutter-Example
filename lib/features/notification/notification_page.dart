import 'package:flutter/material.dart';
import 'package:netmera_flutter_example/page_in_app_messages.dart';
import 'package:netmera_flutter_example/ui/app_colors.dart';
import 'package:netmera_flutter_example/ui/feedback.dart';
import 'package:netmera_flutter_example/ui/widgets/list_rows.dart';
import 'package:netmera_flutter_example/utils/category_channel_utils.dart';
import 'package:netmera_flutter_example/utils/navigation_utils.dart';
import 'package:netmera_flutter_sdk/Netmera.dart';
import 'package:netmera_flutter_sdk/NotificationPermissionStatus.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  NotificationPermissionStatus? _permission;
  bool _pushEnabled = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    try {
      final permission = await Netmera.checkNotificationPermission();
      final pushEnabled = await Netmera.isPushEnabled();
      if (!mounted) return;
      setState(() {
        _permission = permission;
        _pushEnabled = pushEnabled ?? false;
      });
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _requestAuthorization() async {
    try {
      final granted = await Netmera.requestPushNotificationAuthorization();
      showFeedback(
        'Notification authorization ${granted ? 'granted' : 'denied'}',
        style: granted ? FeedbackStyle.success : FeedbackStyle.error,
      );
    } catch (error) {
      _showError(error);
    }
    await _refresh();
  }

  void _showError(Object error) => showFeedback(
    'Something went wrong: ${errorMessage(error)}',
    style: FeedbackStyle.error,
  );

  void _setPushEnabled(bool enabled) {
    // The Android bridge never completes these futures, so they are not awaited.
    enabled ? Netmera.enablePush() : Netmera.disablePush();
    setState(() => _pushEnabled = enabled);
  }

  @override
  Widget build(BuildContext context) {
    final permission = _permission;
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        MenuRow(
          key: const ValueKey('notification.register'),
          title: 'Register Push',
          subtitle: 'Asks for notification permission through Netmera.',
          onTap: _requestAuthorization,
        ),
        StatusRow(
          key: const ValueKey('notification.permission'),
          title: 'Check Push Permission Type',
          subtitle: 'Shows the current push authorization type.',
          value: permission?.name ?? '—',
          valueColor: permission == NotificationPermissionStatus.granted
              ? AppColors.success
              : AppColors.destructive,
          onTap: _refresh,
        ),
        SwitchRow(
          key: const ValueKey('notification.pushReceiving'),
          title: 'Push Receiving Status',
          value: _pushEnabled,
          onChanged: _setPushEnabled,
        ),
        MenuRow(
          key: const ValueKey('notification.inAppMessages'),
          title: 'In-App Messages',
          subtitle:
              'Display in-app widget messages and toggle popup presentation.',
          onTap: () =>
              pushPage(context, InAppMessagesPage(), 'In-App Messages'),
        ),
      ],
    );
  }
}
