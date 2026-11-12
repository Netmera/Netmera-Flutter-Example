import 'package:flutter/material.dart';
import 'package:netmera_flutter_example/app/menu.dart';
import 'package:netmera_flutter_example/features/device/device_info_page.dart';
import 'package:netmera_flutter_example/features/events/events_page.dart';
import 'package:netmera_flutter_example/features/inbox/inbox_page.dart';
import 'package:netmera_flutter_example/features/location/location_page.dart';
import 'package:netmera_flutter_example/features/notification/notification_page.dart';
import 'package:netmera_flutter_example/features/user/coupons_page.dart';
import 'package:netmera_flutter_example/features/user/user_identify_page.dart';
import 'package:netmera_flutter_example/features/user/user_settings_page.dart';
import 'package:netmera_flutter_example/features/user/user_update_page.dart';
import 'package:netmera_flutter_example/page_category_channel_list.dart';
import 'package:netmera_flutter_example/page_user_category_preferences.dart';
import 'package:netmera_flutter_example/ui/feedback.dart';
import 'package:netmera_flutter_sdk/Netmera.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static final List<MenuEntry> entries = [
    MenuEntry.subMenu(
      id: 'core',
      title: 'Core',
      subtitle:
          'To manage SDK core configuration and initialization lifecycle.',
      entries: [
        MenuEntry.action(
          id: 'enableData',
          title: 'Enable Data',
          onTap: (_) {
            Netmera.startDataTransfer();
            showFeedback('Data transfer is enabled.');
          },
        ),
        MenuEntry.action(
          id: 'disableData',
          title: 'Disable Data',
          onTap: (_) {
            Netmera.stopDataTransfer();
            showFeedback('Data transfer is disabled.');
          },
        ),
        MenuEntry.action(
          id: 'kill',
          title: 'Kill Netmera',
          onTap: (_) {
            Netmera.kill();
            showFeedback('Netmera killed.');
          },
        ),
      ],
    ),
    MenuEntry.page(
      id: 'notification',
      title: 'Notification',
      subtitle:
          'To manage notification permissions and handle push notification delegation.',
      builder: (_) => const NotificationPage(),
    ),
    MenuEntry.subMenu(
      id: 'user',
      title: 'User',
      subtitle: 'To identify users and update user profile information.',
      entries: [
        MenuEntry.page(
          id: 'identify',
          title: 'User Identify',
          builder: (_) => const UserIdentifyPage(),
        ),
        MenuEntry.page(
          id: 'update',
          title: 'User Update',
          builder: (_) => const UserUpdatePage(),
        ),
        MenuEntry.page(
          id: 'settings',
          title: 'User Settings',
          builder: (_) => const UserSettingsPage(),
        ),
        MenuEntry.page(
          id: 'categoryPreferences',
          title: 'Category Preferences',
          builder: (_) => const UserCategoryPreferencesPage(),
        ),
        MenuEntry.page(
          id: 'channelPreferences',
          title: 'Channel Preferences',
          builder: (_) => const CategoryChannelListPage(),
        ),
        MenuEntry.page(
          id: 'coupons',
          title: 'Coupons',
          builder: (_) => const CouponsPage(),
        ),
      ],
    ),
    MenuEntry.page(
      id: 'events',
      title: 'Events',
      subtitle:
          'To send and track Netmera events triggered within the application.',
      builder: (_) => const EventsPage(),
    ),
    MenuEntry.action(
      id: 'inbox',
      title: 'Inbox',
      subtitle: 'To view and manage inbox messages with filtering options.',
      onTap: (context) => Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (_) => const InboxPage()),
      ),
    ),
    MenuEntry.page(
      id: 'location',
      title: 'Location',
      subtitle:
          'To manage location authorization status and location-based features.',
      builder: (_) => const LocationPage(),
    ),
    MenuEntry.page(
      id: 'deviceInfo',
      title: 'Device & Token Info',
      subtitle: 'NetmeraIdentifiers and Token.',
      builder: (_) => const DeviceInfoPage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Netmera Flutter Example')),
      body: MenuList(id: 'home', entries: entries),
    );
  }
}
