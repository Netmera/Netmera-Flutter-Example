import 'package:flutter/material.dart';
import 'package:netmera_flutter_example/app/menu.dart';
import 'package:netmera_flutter_example/features/device/device_info_page.dart';
import 'package:netmera_flutter_example/features/inbox/inbox_page.dart';
import 'package:netmera_flutter_example/features/notification/notification_page.dart';
import 'package:netmera_flutter_example/page_category_channel_list.dart';
import 'package:netmera_flutter_example/page_coupon.dart';
import 'package:netmera_flutter_example/page_event.dart';
import 'package:netmera_flutter_example/page_mandatory_event.dart';
import 'package:netmera_flutter_example/page_profile.dart';
import 'package:netmera_flutter_example/page_user.dart';
import 'package:netmera_flutter_example/page_user_category_preferences.dart';
import 'package:netmera_flutter_example/page_user_permissions.dart';
import 'package:netmera_flutter_example/ui/feedback.dart';
import 'package:netmera_flutter_sdk/Netmera.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const maxActiveRegions = 10;

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
          builder: (_) => UserPage(),
        ),
        MenuEntry.page(
          id: 'update',
          title: 'User Update',
          builder: (_) => ProfilePage(),
        ),
        MenuEntry.page(
          id: 'settings',
          title: 'User Settings',
          builder: (_) => UserPermissionsPage(),
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
          builder: (_) => CouponPage(),
        ),
      ],
    ),
    MenuEntry.subMenu(
      id: 'events',
      title: 'Events',
      subtitle:
          'To send and track Netmera events triggered within the application.',
      entries: [
        MenuEntry.page(
          id: 'standard',
          title: 'Standard Events',
          builder: (_) => EventPage(),
        ),
        MenuEntry.page(
          id: 'mandatory',
          title: 'Mandatory Event',
          builder: (_) => MandatoryEventPage(),
        ),
      ],
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
    MenuEntry.subMenu(
      id: 'location',
      title: 'Location',
      subtitle:
          'To manage location authorization status and location-based features.',
      entries: [
        MenuEntry.action(
          id: 'requestPermission',
          title: 'Enable Location & Geofence',
          onTap: (_) => Netmera.requestPermissionsForLocation(),
        ),
        MenuEntry.action(
          id: 'maxActiveRegions',
          title: 'Set Max Active Regions ($maxActiveRegions)',
          onTap: (_) {
            Netmera.setNetmeraMaxActiveRegions(maxActiveRegions);
            showFeedback('Max active regions set to $maxActiveRegions.');
          },
        ),
      ],
    ),
    MenuEntry.page(
      id: 'deviceInfo',
      title: 'Device & Token Info',
      subtitle: 'Push token, external id and push status.',
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
