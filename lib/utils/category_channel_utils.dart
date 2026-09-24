import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:netmera_flutter_sdk/models/NetmeraCategoryChannel.dart';
import 'package:netmera_flutter_sdk/models/NetmeraCategoryChannelPreference.dart';

const List<NetmeraCategoryChannel> allCategoryChannels =
    NetmeraCategoryChannel.values;

class ChannelPreferenceEntry {
  final NetmeraCategoryChannel? channel;
  final bool? optInStatus;

  const ChannelPreferenceEntry({
    required this.channel,
    required this.optInStatus,
  });
}

/// Dedupes by channel; entries with an unrecognized/missing channel are all kept.
List<ChannelPreferenceEntry> dedupeChannelPreferences(
  List<NetmeraCategoryChannelPreference>? preferences,
) {
  final seenChannels = <NetmeraCategoryChannel>{};
  final result = <ChannelPreferenceEntry>[];
  for (final preference in preferences ?? const []) {
    final channel = preference.getChannel();
    if (channel != null) {
      if (seenChannels.contains(channel)) {
        continue;
      }
      seenChannels.add(channel);
    }
    result.add(
      ChannelPreferenceEntry(
        channel: channel,
        optInStatus: preference.getOptInStatus(),
      ),
    );
  }
  return result;
}

sealed class RowSaveStatus {
  const RowSaveStatus();
}

class RowIdle extends RowSaveStatus {
  const RowIdle();
}

class RowSaving extends RowSaveStatus {
  final bool enabled;
  const RowSaving(this.enabled);
}

class RowFailed extends RowSaveStatus {
  final String reason;
  const RowFailed(this.reason);
}

const RowSaveStatus idleStatus = RowIdle();

String errorMessage(Object error) => error is PlatformException
    ? (error.message ?? error.code)
    : error.toString();

void showSuccessToast(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.CENTER,
    timeInSecForIosWeb: 1,
  );
}

void showErrorToast(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.CENTER,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.red,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}
