import 'package:flutter/material.dart';
import 'package:netmera_flutter_example/features/inbox/inbox_format.dart';
import 'package:netmera_flutter_example/ui/app_colors.dart';
import 'package:netmera_flutter_sdk/Netmera.dart';
import 'package:netmera_flutter_sdk/NetmeraPushInbox.dart';

class InboxChip {
  const InboxChip({required this.id, required this.label});

  /// "All", "Unread" or the category name; used in the test key.
  final String id;
  final String label;
}

class InboxChipBar extends StatelessWidget {
  const InboxChipBar({
    super.key,
    required this.chips,
    required this.selectedId,
    required this.onSelected,
    this.enabled = true,
  });

  final List<InboxChip> chips;
  final String selectedId;
  final ValueChanged<String> onSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final chip = chips[index];
          final selected = chip.id == selectedId;
          return ChoiceChip(
            key: ValueKey('inbox.list.chip.${chip.id}'),
            label: Text(chip.label),
            selected: selected,
            showCheckmark: false,
            onSelected: enabled ? (_) => onSelected(chip.id) : null,
            labelStyle: TextStyle(
              fontSize: 14,
              color: selected ? Colors.white : AppColors.label,
            ),
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.groupedBackground,
            side: BorderSide.none,
            shape: const StadiumBorder(),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          );
        },
      ),
    );
  }
}

class InboxMessageRow extends StatelessWidget {
  const InboxMessageRow({
    super.key,
    required this.message,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
  });

  final NetmeraPushInbox message;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final status = message.getInboxStatus();
    final unread = status == Netmera.PUSH_OBJECT_STATUS_UNREAD;
    final deleted = status == Netmera.PUSH_OBJECT_STATUS_DELETED;
    final body = messageBody(message);

    return Material(
      color: selected ? AppColors.selected : AppColors.surface,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Opacity(
          opacity: deleted ? 0.5 : 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 72),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: unread ? AppColors.primary : Colors.transparent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Expanded(
                              child: Text(
                                messageTitle(message),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.label,
                                  fontWeight: unread
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              formatInboxDate(
                                parseSendDate(message.getSendDate()),
                              ),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.mutedText,
                              ),
                            ),
                          ],
                        ),
                        if (body != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            body,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.mutedText,
                            ),
                          ),
                        ],
                        if (deleted) ...[
                          const SizedBox(height: 4),
                          const Text(
                            'Deleted',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.destructive,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SwipeBackground extends StatelessWidget {
  const SwipeBackground({
    super.key,
    required this.color,
    required this.icon,
    required this.alignment,
  });

  final Color color;
  final IconData icon;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Icon(icon, color: Colors.white),
    );
  }
}
