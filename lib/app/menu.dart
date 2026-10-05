import 'package:flutter/material.dart';
import 'package:netmera_flutter_example/ui/widgets/list_rows.dart';
import 'package:netmera_flutter_example/utils/navigation_utils.dart';

class MenuEntry {
  const MenuEntry.action({
    required this.id,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  MenuEntry.page({
    required this.id,
    required this.title,
    this.subtitle,
    required WidgetBuilder builder,
  }) : onTap = ((context) => pushPage(context, builder(context), title));

  MenuEntry.subMenu({
    required this.id,
    required this.title,
    this.subtitle,
    required List<MenuEntry> entries,
  }) : onTap = ((context) =>
           pushPage(context, MenuList(id: id, entries: entries), title));

  /// Used in widget keys (`<menu id>.menu.<entry id>`), so tests can rely on it.
  final String id;
  final String title;
  final String? subtitle;
  final void Function(BuildContext context) onTap;
}

class MenuList extends StatelessWidget {
  const MenuList({super.key, required this.id, required this.entries});

  final String id;
  final List<MenuEntry> entries;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return MenuRow(
          key: ValueKey('$id.menu.${entry.id}'),
          title: entry.title,
          subtitle: entry.subtitle,
          onTap: () => entry.onTap(context),
        );
      },
    );
  }
}
