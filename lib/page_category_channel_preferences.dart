import 'package:flutter/material.dart';
import 'package:netmera_flutter_sdk/Netmera.dart';
import 'package:netmera_flutter_sdk/NetmeraCategoryPreference.dart';
import 'package:netmera_flutter_sdk/models/NetmeraCategoryChannel.dart';
import 'package:netmera_flutter_sdk/models/NetmeraCategoryPreferenceFilter.dart';
import 'package:netmera_flutter_example/utils/category_channel_utils.dart';

///
/// Copyright (c) 2026 Netmera Research.
///
class CategoryChannelPreferencesPage extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  final bool? categoryEnabled;
  final List<ChannelPreferenceEntry> channelPreferences;

  const CategoryChannelPreferencesPage({
    Key? key,
    required this.categoryId,
    required this.categoryName,
    required this.categoryEnabled,
    required this.channelPreferences,
  }) : super(key: key);

  @override
  State<CategoryChannelPreferencesPage> createState() =>
      _CategoryChannelPreferencesPageState();
}

class _ChannelRowState {
  final NetmeraCategoryChannel? channel;
  final bool? isEnabled;
  final RowSaveStatus status;

  const _ChannelRowState({
    required this.channel,
    required this.isEnabled,
    required this.status,
  });

  _ChannelRowState withStatus(RowSaveStatus newStatus) => _ChannelRowState(
    channel: channel,
    isEnabled: isEnabled,
    status: newStatus,
  );

  bool get switchValue {
    final status = this.status;
    return status is RowSaving ? status.enabled : (isEnabled ?? false);
  }

  bool get isInteractive => channel != null && status is! RowSaving;
}

class _CategoryChannelPreferencesPageState
    extends State<CategoryChannelPreferencesPage> {
  bool? _categoryEnabled;
  RowSaveStatus _allChannelsStatus = idleStatus;
  List<_ChannelRowState> _channelRows = [];

  bool _isFetchingNow = false;
  bool _isWritingAllChannels = false;
  final Set<NetmeraCategoryChannel> _pendingWrites = {};
  final Map<NetmeraCategoryChannel, int> _writeGeneration = {};
  int _allChannelsGeneration = 0;

  @override
  void initState() {
    super.initState();
    _categoryEnabled = widget.categoryEnabled;
    _channelRows = widget.channelPreferences
        .map(
          (entry) => _ChannelRowState(
            channel: entry.channel,
            isEnabled: entry.optInStatus,
            status: idleStatus,
          ),
        )
        .toList();
  }

  Future<void> _reloadCategory() async {
    if (_isFetchingNow) {
      return;
    }
    _isFetchingNow = true;

    final generationAtIssue = Map<NetmeraCategoryChannel, int>.from(
      _writeGeneration,
    );
    final allChannelsGenerationAtIssue = _allChannelsGeneration;

    try {
      final filter = NetmeraCategoryPreferenceFilter()
        ..setCategoryIds([widget.categoryId]);
      final list = await Netmera.getUserCategoryPreferenceList(filter);

      NetmeraCategoryPreference? match;
      for (final item in list) {
        if (item.getCategoryId() == widget.categoryId) {
          match = item;
          break;
        }
      }
      if (match == null) {
        showErrorToast('Category ${widget.categoryId} was not in the response');
        return;
      }

      final fresh = dedupeChannelPreferences(match.getChannelPreferences())
          .map(
            (entry) => _ChannelRowState(
              channel: entry.channel,
              isEnabled: entry.optInStatus,
              status: idleStatus,
            ),
          )
          .toList();

      final merged = fresh.map((row) {
        final channel = row.channel;
        final isStale =
            channel != null &&
            (_pendingWrites.contains(channel) ||
                _writeGeneration[channel] != generationAtIssue[channel]);
        if (isStale) {
          return _channelRows.firstWhere(
            (current) => current.channel == channel,
            orElse: () => row,
          );
        }
        return row;
      }).toList();

      setState(() => _channelRows = merged);

      if (!_isWritingAllChannels &&
          _allChannelsGeneration == allChannelsGenerationAtIssue) {
        final matchedCategory = match;
        setState(() {
          _categoryEnabled = matchedCategory.getOptInStatus();
          _allChannelsStatus = idleStatus;
        });
      }
    } catch (error) {
      showErrorToast('Could not load preferences: ${errorMessage(error)}');
    } finally {
      _isFetchingNow = false;
    }
  }

  Future<void> _setAllChannels(bool enabled) async {
    if (_isWritingAllChannels) {
      return;
    }
    final previousValue = _categoryEnabled;

    _isWritingAllChannels = true;
    _allChannelsGeneration += 1;
    for (final channel in allCategoryChannels) {
      _writeGeneration[channel] = (_writeGeneration[channel] ?? 0) + 1;
    }
    setState(() => _allChannelsStatus = RowSaving(enabled));

    try {
      await Netmera.setUserCategoryPreference(widget.categoryId, enabled);
      _isWritingAllChannels = false;
      setState(() {
        _categoryEnabled = enabled;
        _allChannelsStatus = idleStatus;
        _channelRows = _channelRows
            .map(
              (row) =>
                  (row.channel != null && _pendingWrites.contains(row.channel))
                  ? row
                  : _ChannelRowState(
                      channel: row.channel,
                      isEnabled: enabled,
                      status: idleStatus,
                    ),
            )
            .toList();
      });
      showSuccessToast('Preference updated.');
    } catch (error) {
      _isWritingAllChannels = false;
      setState(() {
        _categoryEnabled = previousValue;
        _allChannelsStatus = RowFailed(errorMessage(error));
      });
      showErrorToast('Something went wrong: ${errorMessage(error)}');
    }
  }

  Future<void> _setChannelPreference(
    NetmeraCategoryChannel channel,
    bool enabled,
  ) async {
    final previousValue = _channelRows
        .firstWhere(
          (row) => row.channel == channel,
          orElse: () => _ChannelRowState(
            channel: channel,
            isEnabled: null,
            status: idleStatus,
          ),
        )
        .isEnabled;

    _pendingWrites.add(channel);
    _writeGeneration[channel] = (_writeGeneration[channel] ?? 0) + 1;
    setState(() {
      _channelRows = _channelRows
          .map(
            (row) => row.channel == channel
                ? row.withStatus(RowSaving(enabled))
                : row,
          )
          .toList();
    });

    try {
      await Netmera.setUserCategoryPreference(
        widget.categoryId,
        enabled,
        channel: channel,
      );
      _pendingWrites.remove(channel);
      setState(() {
        _channelRows = _channelRows
            .map(
              (row) => row.channel == channel
                  ? _ChannelRowState(
                      channel: channel,
                      isEnabled: enabled,
                      status: idleStatus,
                    )
                  : row,
            )
            .toList();
      });
      showSuccessToast('Preference updated.');
    } catch (error) {
      _pendingWrites.remove(channel);
      setState(() {
        _channelRows = _channelRows
            .map(
              (row) => row.channel == channel
                  ? _ChannelRowState(
                      channel: channel,
                      isEnabled: previousValue,
                      status: RowFailed(errorMessage(error)),
                    )
                  : row,
            )
            .toList();
      });
      showErrorToast('Something went wrong: ${errorMessage(error)}');
    }
  }

  bool get _allChannelsSwitchValue => _channelRows.isEmpty
      ? (_categoryEnabled ?? false)
      : _channelRows.any((row) => row.switchValue);

  ({String text, Color? color}) _allChannelsSubtitle() {
    final status = _allChannelsStatus;
    if (status is RowSaving) {
      return (text: 'Saving…', color: null);
    }
    if (status is RowFailed) {
      return (text: '⚠ Could not save — ${status.reason}', color: Colors.red);
    }
    return (
      text: _channelRows.isEmpty
          ? 'No channels returned for this category'
          : '${_channelRows.where((row) => row.switchValue).length} of ${_channelRows.length} channels on',
      color: null,
    );
  }

  ({String? text, Color? color}) _channelSubtitle(_ChannelRowState row) {
    final status = row.status;
    if (status is RowSaving) {
      return (text: 'Saving…', color: null);
    }
    if (status is RowFailed) {
      return (text: '⚠ Could not save — ${status.reason}', color: Colors.red);
    }
    if (row.channel == null) {
      return (
        text:
            'This app version does not support this channel, so it cannot be changed here.',
        color: null,
      );
    }
    if (row.isEnabled == null) {
      return (
        text: 'The server returned no value for this channel yet.',
        color: Colors.orange,
      );
    }
    return (text: null, color: null);
  }

  Widget _buildChannelRow(_ChannelRowState row) {
    final subtitle = _channelSubtitle(row);
    return SwitchListTile(
      title: Text(row.channel?.rawValue ?? 'UNKNOWN CHANNEL'),
      subtitle: subtitle.text != null
          ? Text(subtitle.text!, style: TextStyle(color: subtitle.color))
          : null,
      value: row.switchValue,
      onChanged: row.isInteractive
          ? (value) => _setChannelPreference(row.channel!, value)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final allChannelsStatus = _allChannelsStatus;
    final allChannelsSwitchValue = allChannelsStatus is RowSaving
        ? allChannelsStatus.enabled
        : _allChannelsSwitchValue;
    final allChannelsSubtitle = _allChannelsSubtitle();

    return RefreshIndicator(
      onRefresh: _reloadCategory,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '“${widget.categoryName}” · category id ${widget.categoryId}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('All channels'),
            subtitle: Text(
              allChannelsSubtitle.text,
              style: TextStyle(color: allChannelsSubtitle.color),
            ),
            value: allChannelsSwitchValue,
            onChanged: allChannelsStatus is RowSaving ? null : _setAllChannels,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Switching this off turns every channel of this category off in one go, and switching it on '
              'turns them all on. It follows the rows below, so it goes off by itself once the last channel '
              'is off.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
          if (_channelRows.isNotEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                'Channels of this category',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
            ),
          for (final row in _channelRows) ...[
            _buildChannelRow(row),
            const Divider(height: 1),
          ],
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              _channelRows.isEmpty
                  ? 'The server returned no channels for this category, so there is nothing to change one '
                        'by one. The switch above still applies to all channels.'
                  : 'Only the channels the server returned for this category are listed. Each switch '
                        'changes that one channel and leaves the others as they are.',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
