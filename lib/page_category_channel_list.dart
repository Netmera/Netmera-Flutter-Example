import 'package:flutter/material.dart';
import 'package:netmera_flutter_example/page_channel_categories.dart';
import 'package:netmera_flutter_example/utils/category_channel_utils.dart';
import 'package:netmera_flutter_example/utils/navigation_utils.dart';

///
/// Copyright (c) 2026 Netmera Research.
///
class CategoryChannelListPage extends StatelessWidget {
  const CategoryChannelListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: allCategoryChannels.length + 2,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '${allCategoryChannels.length} channels supported by this app',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          );
        }
        if (index == allCategoryChannels.length + 1) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Pick a channel to see the user's categories on it and switch them on or off. The server can "
              "also have channels this app does not support yet; those show up on a category's own channel "
              'list and cannot be changed from the app.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          );
        }
        final channel = allCategoryChannels[index - 1];
        return ListTile(
          title: Text(channel.rawValue),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => pushPage(
            context,
            ChannelCategoriesPage(channel: channel),
            channel.rawValue,
          ),
        );
      },
    );
  }
}
