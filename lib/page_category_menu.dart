import 'package:flutter/material.dart';
import 'package:netmera_flutter_example/page_category.dart';
import 'package:netmera_flutter_example/page_category_channel_list.dart';
import 'package:netmera_flutter_example/page_user_category_preferences.dart';
import 'package:netmera_flutter_example/utils/navigation_utils.dart';

///
/// Copyright (c) 2026 Netmera Research.
///
class CategoryMenuPage extends StatelessWidget {
  const CategoryMenuPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttons = <Map<String, dynamic>>[
      {
        'label': 'Category Inbox',
        'page': CategoryPage(),
        'title': 'Category Inbox',
      },
      {
        'label': 'User Category Preferences',
        'page': UserCategoryPreferencesPage(),
        'title': 'User Category Preferences',
      },
      {
        'label': 'Category Channels',
        'page': CategoryChannelListPage(),
        'title': 'Category Channels',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: buttons.length,
      itemBuilder: (context, index) {
        final b = buttons[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () =>
                  pushPage(context, b['page'] as Widget, b['title'] as String),
              child: Text((b['label'] as String).toUpperCase()),
            ),
          ),
        );
      },
    );
  }
}
