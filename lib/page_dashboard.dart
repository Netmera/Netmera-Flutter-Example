import 'package:flutter/material.dart';
import 'package:netmera_flutter_example/page_category.dart';
import 'package:netmera_flutter_example/page_coupon.dart';
import 'package:netmera_flutter_example/page_event.dart';
import 'package:netmera_flutter_example/page_mandatory_event.dart';
import 'package:netmera_flutter_example/page_profile.dart';
import 'package:netmera_flutter_example/page_push_inbox.dart';
import 'package:netmera_flutter_example/page_settings.dart';
import 'package:netmera_flutter_example/page_user.dart';
import 'package:netmera_flutter_example/page_user_permissions.dart';

///
/// Copyright (c) 2026 Netmera Research.
///
class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  void _navigateTo(BuildContext context, Widget page, String title) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(title)),
          body: page,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttons = <Map<String, dynamic>>[
      {'label': 'Event', 'page': EventPage(), 'title': 'Event'},
      {'label': 'Mandatory Event', 'page': MandatoryEventPage(), 'title': 'Mandatory Event'},
      {'label': 'User', 'page': UserPage(), 'title': 'User'},
      {'label': 'Profile', 'page': ProfilePage(), 'title': 'User Profile'},
      {'label': 'Push Inbox', 'page': PushInboxPage(), 'title': 'Push Inbox'},
      {'label': 'Settings', 'page': SettingsPage(), 'title': 'Settings'},
      {'label': 'Category', 'page': CategoryPage(), 'title': 'Category'},
      {'label': 'Permissions', 'page': UserPermissionsPage(), 'title': 'Permissions'},
      {'label': 'Coupons', 'page': CouponPage(), 'title': 'Coupons'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Netmera Flutter Example'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: buttons.length,
        itemBuilder: (context, index) {
          final b = buttons[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _navigateTo(context, b['page'] as Widget, b['title'] as String),
                child: Text((b['label'] as String).toUpperCase()),
              ),
            ),
          );
        },
      ),
    );
  }
}
