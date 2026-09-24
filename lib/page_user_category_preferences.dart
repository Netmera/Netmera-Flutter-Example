import 'package:flutter/material.dart';
import 'package:netmera_flutter_sdk/Netmera.dart';
import 'package:netmera_flutter_sdk/models/NetmeraCategoryPreferenceFilter.dart';
import 'package:netmera_flutter_example/page_category_channel_preferences.dart';
import 'package:netmera_flutter_example/utils/category_channel_utils.dart';
import 'package:netmera_flutter_example/utils/navigation_utils.dart';

///
/// Copyright (c) 2026 Netmera Research.
///
class UserCategoryPreferencesPage extends StatefulWidget {
  const UserCategoryPreferencesPage({Key? key}) : super(key: key);

  @override
  State<UserCategoryPreferencesPage> createState() =>
      _UserCategoryPreferencesPageState();
}

class _UserCategoryRow {
  final int id;
  final String name;
  final bool? enabled;
  final List<ChannelPreferenceEntry> channelPreferences;

  const _UserCategoryRow({
    required this.id,
    required this.name,
    required this.enabled,
    required this.channelPreferences,
  });

  String get channelSummary => channelPreferences.isEmpty
      ? 'no channels returned'
      : '${channelPreferences.where((p) => p.optInStatus == true).length} of '
            '${channelPreferences.length} channels on';
}

class _UserCategoryPreferencesPageState
    extends State<UserCategoryPreferencesPage> {
  List<_UserCategoryRow> _rows = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() => _loading = true);
    try {
      final list = await Netmera.getUserCategoryPreferenceList();
      final seenIds = <int>{};
      final rows = <_UserCategoryRow>[];
      for (final preference in list) {
        final id = preference.getCategoryId();
        if (id == null || seenIds.contains(id)) {
          continue;
        }
        seenIds.add(id);
        final name = preference.getCategoryName();
        rows.add(
          _UserCategoryRow(
            id: id,
            name: (name != null && name.trim().isNotEmpty) ? name : '(no name)',
            enabled: preference.getOptInStatus(),
            channelPreferences: dedupeChannelPreferences(
              preference.getChannelPreferences(),
            ),
          ),
        );
      }
      setState(() => _rows = rows);
    } catch (error) {
      setState(() => _rows = []);
      showErrorToast('Could not load preferences: ${errorMessage(error)}');
    } finally {
      setState(() => _loading = false);
    }
  }

  // Re-fetches with a categoryIds filter for just the tapped row, so the console/toast
  // shows the filter actually narrowing the result down instead of returning everything.
  Future<void> _verifyCategoryFilter(_UserCategoryRow row) async {
    try {
      final filter = NetmeraCategoryPreferenceFilter()
        ..setCategoryIds([row.id]);
      final filtered = await Netmera.getUserCategoryPreferenceList(filter);
      debugPrint(
        'Filtered fetch (categoryIds: [${row.id}]) returned: $filtered',
      );
      showSuccessToast(
        'Filter check — categoryIds:[${row.id}] → ${filtered.length} result(s)',
      );
    } catch (error) {
      showErrorToast('Filter check failed: ${errorMessage(error)}');
    }
  }

  Future<void> _openCategory(_UserCategoryRow row) async {
    _verifyCategoryFilter(row);
    await pushPage(
      context,
      CategoryChannelPreferencesPage(
        categoryId: row.id,
        categoryName: row.name,
        categoryEnabled: row.enabled,
        channelPreferences: row.channelPreferences,
      ),
      row.name,
    );
    _fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _rows.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return RefreshIndicator(
      onRefresh: _fetchCategories,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '${_rows.length} categories of this user',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          ),
          if (_rows.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No categories returned. Pull to refresh to try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ),
          for (final row in _rows) ...[
            ListTile(
              title: Text('${row.name}  ·  id ${row.id}'),
              subtitle: Text(row.channelSummary),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openCategory(row),
            ),
            const Divider(height: 1),
          ],
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Tap a category to see which channels it is on and switch them on or off.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
