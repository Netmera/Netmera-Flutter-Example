import 'dart:io';

import 'package:flutter/material.dart';
import 'package:netmera_flutter_example/ui/app_colors.dart';
import 'package:netmera_flutter_example/ui/feedback.dart';
import 'package:netmera_flutter_example/ui/widgets/list_rows.dart';
import 'package:netmera_flutter_sdk/Netmera.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  static const maxActiveRegions = 10;

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage>
    with WidgetsBindingObserver {
  String? _status;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // The system permission dialog pauses the app, so the status is re-read
  // when it closes.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    final always = await Permission.locationAlways.status;
    final whenInUse = await Permission.locationWhenInUse.status;
    if (!mounted) return;
    setState(() => _status = _describe(always, whenInUse));
  }

  static String _describe(PermissionStatus always, PermissionStatus whenInUse) {
    if (always.isGranted) return 'Always';
    if (whenInUse.isGranted) return 'When In Use';
    if (whenInUse.isRestricted) return 'Restricted';
    // On iOS `denied` means the user has not been asked yet; Android has no
    // such state.
    if (whenInUse.isDenied && Platform.isIOS) return 'Not determined';
    return 'Denied';
  }

  void _setMaxActiveRegions() {
    Netmera.setNetmeraMaxActiveRegions(LocationPage.maxActiveRegions);
    showFeedback('Max active regions set to ${LocationPage.maxActiveRegions}.');
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        StatusRow(
          key: const ValueKey('location.permissionStatus'),
          title: 'Location permission',
          value: _status ?? '—',
          valueColor: AppColors.mutedText,
        ),
        const MenuRow(
          key: ValueKey('location.requestLocationAuthorization'),
          title: 'Request Location Authorization',
          onTap: Netmera.requestPermissionsForLocation,
        ),
        MenuRow(
          key: const ValueKey('location.setMaxActiveRegion'),
          title: 'Set Max Active Region (${LocationPage.maxActiveRegions})',
          onTap: _setMaxActiveRegions,
        ),
      ],
    );
  }
}
