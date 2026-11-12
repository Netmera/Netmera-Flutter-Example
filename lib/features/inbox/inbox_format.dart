import 'package:netmera_flutter_sdk/Netmera.dart';
import 'package:netmera_flutter_sdk/NetmeraPushInbox.dart';

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// `read|unread|deleted` subset for a status bitmask, as the native demos log it.
String inboxStatusName(int status) {
  if (status == Netmera.PUSH_OBJECT_STATUS_ALL) return 'all';
  return [
    if (status & Netmera.PUSH_OBJECT_STATUS_READ != 0) 'read',
    if (status & Netmera.PUSH_OBJECT_STATUS_UNREAD != 0) 'unread',
    if (status & Netmera.PUSH_OBJECT_STATUS_DELETED != 0) 'deleted',
  ].join('|');
}

String inboxStatusLabel(int? status) => switch (status) {
  Netmera.PUSH_OBJECT_STATUS_UNREAD => 'Unread',
  Netmera.PUSH_OBJECT_STATUS_DELETED => 'Deleted',
  _ => 'Read',
};

/// The bridge sends `sendDate` as `yyyy-MM-dd HH:mm:ss` in device local time.
DateTime? parseSendDate(String? value) =>
    value == null ? null : DateTime.tryParse(value.replaceFirst(' ', 'T'));

String formatInboxDate(DateTime? date, {DateTime? now}) {
  if (date == null) return '';
  final today = now ?? DateTime.now();
  final day = DateTime(date.year, date.month, date.day);
  final daysAgo = DateTime(
    today.year,
    today.month,
    today.day,
  ).difference(day).inDays;
  if (daysAgo == 0) {
    return '${_twoDigits(date.hour)}:${_twoDigits(date.minute)}';
  }
  if (daysAgo == 1) return 'Yesterday';
  final short = '${date.day} ${_months[date.month - 1]}';
  return date.year == today.year ? short : '$short ${date.year}';
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');

bool _isBlank(String? value) => value == null || value.trim().isEmpty;

String messageTitle(NetmeraPushInbox message) {
  if (!_isBlank(message.getTitle())) return message.getTitle()!;
  if (!_isBlank(message.getBody())) return message.getBody()!;
  return '(No content)';
}

/// The body is shown under the title only when both exist; otherwise the
/// title row already shows it.
String? messageBody(NetmeraPushInbox message) =>
    _isBlank(message.getTitle()) || _isBlank(message.getBody())
    ? null
    : message.getBody();
