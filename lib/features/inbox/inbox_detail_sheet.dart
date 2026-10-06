import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:netmera_flutter_example/features/inbox/inbox_format.dart';
import 'package:netmera_flutter_example/ui/app_colors.dart';
import 'package:netmera_flutter_example/ui/widgets/states.dart';
import 'package:netmera_flutter_sdk/Netmera.dart';
import 'package:netmera_flutter_sdk/NetmeraInteractiveAction.dart';
import 'package:netmera_flutter_sdk/NetmeraPushInbox.dart';

Future<void> showInboxDetailSheet(
  BuildContext context, {
  required NetmeraPushInbox message,
  required bool showSdkFields,
  required VoidCallback onOpen,
  required ValueChanged<NetmeraInteractiveAction> onAction,
  required VoidCallback onMarkUnread,
  required VoidCallback onDelete,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.surface,
    builder: (sheetContext) => _InboxDetailSheet(
      message: message,
      showSdkFields: showSdkFields,
      onOpen: onOpen,
      onAction: onAction,
      onMarkUnread: () {
        Navigator.pop(sheetContext);
        onMarkUnread();
      },
      onDelete: () {
        Navigator.pop(sheetContext);
        onDelete();
      },
    ),
  );
}

class _InboxDetailSheet extends StatelessWidget {
  const _InboxDetailSheet({
    required this.message,
    required this.showSdkFields,
    required this.onOpen,
    required this.onAction,
    required this.onMarkUnread,
    required this.onDelete,
  });

  final NetmeraPushInbox message;
  final bool showSdkFields;
  final VoidCallback onOpen;
  final ValueChanged<NetmeraInteractiveAction> onAction;
  final VoidCallback onMarkUnread;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final status = message.getInboxStatus();
    final body = messageBody(message);
    final meta = [
      formatInboxDate(parseSendDate(message.getSendDate())),
      ?message.getCategory(),
      inboxStatusLabel(status),
    ].where((part) => part.isNotEmpty).join(' · ');

    return DraggableScrollableSheet(
      key: const ValueKey('inbox.detail'),
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (context, scrollController) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        children: [
          Text(
            messageTitle(message),
            key: const ValueKey('inbox.detail.title'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            meta,
            style: const TextStyle(fontSize: 13, color: AppColors.mutedText),
          ),
          if (body != null) ...[
            const SizedBox(height: 16),
            Text(body, style: const TextStyle(fontSize: 16)),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            key: const ValueKey('inbox.detail.open'),
            onPressed: message.getPushAction() == null ? null : onOpen,
            child: const Text('Open'),
          ),
          for (final action in message.getInteractiveActions() ?? const [])
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: OutlinedButton(
                onPressed: () => onAction(action),
                child: Text(
                  action.getActionTitle() ?? action.getId() ?? 'Action',
                ),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (status == Netmera.PUSH_OBJECT_STATUS_READ)
                TextButton(
                  key: const ValueKey('inbox.detail.markUnread'),
                  onPressed: onMarkUnread,
                  child: const Text('Mark as unread'),
                ),
              const Spacer(),
              if (status != Netmera.PUSH_OBJECT_STATUS_DELETED)
                TextButton(
                  key: const ValueKey('inbox.detail.delete'),
                  onPressed: onDelete,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.destructive,
                  ),
                  child: const Text('Delete'),
                ),
            ],
          ),
          if (showSdkFields) ...[
            const SizedBox(height: 16),
            const Text(
              'SDK fields',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.mutedText,
              ),
            ),
            const SizedBox(height: 4),
            MonoPanel(
              _sdkFields(message),
              key: const ValueKey('inbox.detail.sdkFields'),
            ),
          ],
        ],
      ),
    );
  }

  static String _sdkFields(NetmeraPushInbox message) {
    String value(Object? field) {
      if (field == null) return '–';
      if (field is Map || field is List) return jsonEncode(field);
      return '$field';
    }

    return [
      'Push ID: ${value(message.getPushId())}',
      'Instance ID: ${value(message.getPushInstanceId())}',
      'Push type: ${value(message.getPushType())}',
      'Status: ${inboxStatusLabel(message.getInboxStatus())}',
      'Category: ${value(message.getCategory())}',
      'Categories: ${value(message.getCategories())}',
      'Subtitle: ${value(message.getSubtitle())}',
      'Sent: ${value(message.getSendDate())}',
      'Expires: ${value(message.getPopUpExpirationTime())}',
      'External ID: ${value(message.getExternalId())}',
      'Deeplink: ${value(message.getDeepLink())}',
      'Web URL: ${value(message.getWebPage())}',
      'Media: ${value(message.getMediaAttachmentUrl())}',
      'Action: ${value(message.getPushAction())}',
      'Interactive actions: ${value(message.getInteractiveActions()?.map((a) => a.toJson()).toList())}',
      'Carousel: ${value(message.getCarousel())}',
      'Custom JSON: ${value(message.getCustomJson())}',
    ].join('\n');
  }
}
