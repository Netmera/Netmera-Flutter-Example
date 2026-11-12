import 'package:flutter/material.dart';
import 'package:netmera_flutter_example/app/menu.dart';
import 'package:netmera_flutter_example/features/events/event_senders.dart';
import 'package:netmera_flutter_example/features/events/mandatory_event_page.dart';
import 'package:netmera_flutter_example/ui/feedback.dart';
import 'package:netmera_flutter_example/ui/widgets/list_rows.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  static final List<MenuEntry> entries = [
    MenuEntry.subMenu(
      id: 'commerce',
      title: 'Commerce Event Test',
      entries: [
        _event('cartView', 'CartViewEvent', EventSenders.cartView),
        _event('purchase', 'PurchaseEvent', EventSenders.purchase),
      ],
    ),
    MenuEntry.subMenu(
      id: 'general',
      title: 'General Event Test',
      entries: [
        _event('login', 'LoginEvent', EventSenders.login),
        _event('register', 'RegisterEvent', EventSenders.register),
        _event('custom', 'TestEvent', EventSenders.custom),
      ],
    ),
    MenuEntry.page(
      id: 'mandatory',
      title: 'Mandatory Event',
      builder: (_) => const MandatoryEventPage(),
    ),
  ];

  static MenuEntry _event(String id, String title, void Function() send) {
    return MenuEntry.action(
      id: id,
      title: title,
      onTap: (_) {
        send();
        showFeedback('$title sent.');
      },
    );
  }

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        SwitchRow(
          key: const ValueKey('events.genericMethod'),
          title: 'Use Generic Method',
          value: EventSenders.useGenericMethod,
          onChanged: (enabled) =>
              setState(() => EventSenders.useGenericMethod = enabled),
        ),
        for (final entry in EventsPage.entries)
          MenuRow(
            key: ValueKey('events.menu.${entry.id}'),
            title: entry.title,
            onTap: () => entry.onTap(context),
          ),
      ],
    );
  }
}
