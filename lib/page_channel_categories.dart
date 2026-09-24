import 'package:flutter/material.dart';
import 'package:netmera_flutter_sdk/Netmera.dart';
import 'package:netmera_flutter_sdk/models/NetmeraCategoryChannel.dart';
import 'package:netmera_flutter_sdk/models/NetmeraCategoryChannelPreference.dart';
import 'package:netmera_flutter_sdk/models/NetmeraCategoryPreferenceFilter.dart';
import 'package:netmera_flutter_example/utils/category_channel_utils.dart';

///
/// Copyright (c) 2026 Netmera Research.
///
class ChannelCategoriesPage extends StatefulWidget {
  final NetmeraCategoryChannel channel;

  const ChannelCategoriesPage({Key? key, required this.channel})
    : super(key: key);

  @override
  State<ChannelCategoriesPage> createState() => _ChannelCategoriesPageState();
}

class _ChannelCategoryRow {
  final int categoryId;
  final String name;
  final bool? isEnabled;
  final RowSaveStatus status;

  const _ChannelCategoryRow({
    required this.categoryId,
    required this.name,
    required this.isEnabled,
    required this.status,
  });

  _ChannelCategoryRow withStatus(RowSaveStatus newStatus) =>
      _ChannelCategoryRow(
        categoryId: categoryId,
        name: name,
        isEnabled: isEnabled,
        status: newStatus,
      );

  bool get switchValue {
    final status = this.status;
    return status is RowSaving ? status.enabled : (isEnabled ?? false);
  }
}

class _ChannelCategoriesPageState extends State<ChannelCategoriesPage> {
  List<_ChannelCategoryRow> _rows = [];
  bool _isFetching = false;

  bool _isFetchingNow = false;
  final Set<int> _pendingWrites = {};
  final Map<int, int> _writeGeneration = {};

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    if (_isFetchingNow) {
      return;
    }
    _isFetchingNow = true;
    setState(() => _isFetching = true);

    final generationAtIssue = Map<int, int>.from(_writeGeneration);

    try {
      final filter = NetmeraCategoryPreferenceFilter()
        ..setChannels([widget.channel]);
      final list = await Netmera.getUserCategoryPreferenceList(filter);

      final seenIds = <int>{};
      final fresh = <_ChannelCategoryRow>[];
      for (final preference in list) {
        final id = preference.getCategoryId();
        if (id == null || seenIds.contains(id)) {
          continue;
        }
        seenIds.add(id);

        NetmeraCategoryChannelPreference? entry;
        for (final channelPreference
            in preference.getChannelPreferences() ?? const []) {
          if (channelPreference.getChannel() == widget.channel) {
            entry = channelPreference;
            break;
          }
        }

        final name = preference.getCategoryName();
        fresh.add(
          _ChannelCategoryRow(
            categoryId: id,
            name: (name != null && name.trim().isNotEmpty) ? name : 'id $id',
            isEnabled: entry?.getOptInStatus(),
            status: idleStatus,
          ),
        );
      }

      final merged = fresh.map((row) {
        final isStale =
            _pendingWrites.contains(row.categoryId) ||
            _writeGeneration[row.categoryId] !=
                generationAtIssue[row.categoryId];
        if (isStale) {
          return _rows.firstWhere(
            (current) => current.categoryId == row.categoryId,
            orElse: () => row,
          );
        }
        return row;
      }).toList();

      setState(() => _rows = merged);
    } catch (error) {
      showErrorToast('Could not load preferences: ${errorMessage(error)}');
    } finally {
      _isFetchingNow = false;
      setState(() => _isFetching = false);
    }
  }

  Future<void> _setPreference(int categoryId, bool enabled) async {
    final previousValue = _rows
        .firstWhere(
          (row) => row.categoryId == categoryId,
          orElse: () => _ChannelCategoryRow(
            categoryId: categoryId,
            name: '',
            isEnabled: null,
            status: idleStatus,
          ),
        )
        .isEnabled;

    _pendingWrites.add(categoryId);
    _writeGeneration[categoryId] = (_writeGeneration[categoryId] ?? 0) + 1;
    setState(() {
      _rows = _rows
          .map(
            (row) => row.categoryId == categoryId
                ? row.withStatus(RowSaving(enabled))
                : row,
          )
          .toList();
    });

    try {
      await Netmera.setUserCategoryPreference(
        categoryId,
        enabled,
        channel: widget.channel,
      );
      _pendingWrites.remove(categoryId);
      setState(() {
        _rows = _rows
            .map(
              (row) => row.categoryId == categoryId
                  ? _ChannelCategoryRow(
                      categoryId: categoryId,
                      name: row.name,
                      isEnabled: enabled,
                      status: idleStatus,
                    )
                  : row,
            )
            .toList();
      });
      showSuccessToast('Preference updated.');
    } catch (error) {
      _pendingWrites.remove(categoryId);
      setState(() {
        _rows = _rows
            .map(
              (row) => row.categoryId == categoryId
                  ? _ChannelCategoryRow(
                      categoryId: categoryId,
                      name: row.name,
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

  ({String text, Color? color}) _rowSubtitle(_ChannelCategoryRow row) {
    final status = row.status;
    if (status is RowSaving) {
      return (text: 'Saving…', color: null);
    }
    if (status is RowFailed) {
      return (text: '⚠ Could not save — ${status.reason}', color: Colors.red);
    }
    if (row.isEnabled == null) {
      return (
        text:
            'id ${row.categoryId} · the server returned no value for this channel yet',
        color: Colors.orange,
      );
    }
    return (text: 'id ${row.categoryId}', color: null);
  }

  Widget _buildRow(_ChannelCategoryRow row) {
    final subtitle = _rowSubtitle(row);
    return SwitchListTile(
      title: Text(row.name),
      subtitle: Text(subtitle.text, style: TextStyle(color: subtitle.color)),
      value: row.switchValue,
      onChanged: row.status is RowSaving
          ? null
          : (value) => _setPreference(row.categoryId, value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _fetchCategories,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '${_rows.length} categories on ${widget.channel.rawValue}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          ),
          if (_rows.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: _isFetching
                    ? const CircularProgressIndicator()
                    : Text(
                        'No categories returned for ${widget.channel.rawValue}. Pull to refresh to try again.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.black54),
                      ),
              ),
            ),
          for (final row in _rows) ...[
            _buildRow(row),
            const Divider(height: 1),
          ],
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Each switch changes the category on ${widget.channel.rawValue} only — its other channels '
              'stay as they are.',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
