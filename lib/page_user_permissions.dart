import 'package:flutter/material.dart';
import 'package:netmera_flutter_sdk/Netmera.dart';

///
/// Copyright (c) 2026 Netmera Research.
///

class UserPermissionsPage extends StatefulWidget {
  @override
  _UserPermissionsPageState createState() => _UserPermissionsPageState();
}

class _UserPermissionsPageState extends State<UserPermissionsPage> {
  bool _emailPermission = false;
  bool _smsPermission = false;
  bool _whatsAppPermission = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchPermissions();
  }

  void _fetchPermissions() async {
    try {
      final emailAllowed = await Netmera.getEmailPermission();
      final smsAllowed = await Netmera.getSmsPermission();
      final whatsAppAllowed = await Netmera.getWhatsAppPermission();
      setState(() {
        _emailPermission = emailAllowed;
        _smsPermission = smsAllowed;
        _whatsAppPermission = whatsAppAllowed;
        _loading = false;
      });
    } catch (e) {
      print("Error fetching permissions: $e");
      setState(() => _loading = false);
    }
  }

  void _setEmailPermission(bool value) async {
    final oldValue = _emailPermission;
    setState(() => _emailPermission = value);
    try {
      await Netmera.setEmailPermission(value);
    } catch (e) {
      print("Error setting email permission: $e");
      setState(() => _emailPermission = oldValue);
    }
  }

  void _setSmsPermission(bool value) async {
    final oldValue = _smsPermission;
    setState(() => _smsPermission = value);
    try {
      await Netmera.setSmsPermission(value);
    } catch (e) {
      print("Error setting sms permission: $e");
      setState(() => _smsPermission = oldValue);
    }
  }

  void _setWhatsAppPermission(bool value) async {
    final oldValue = _whatsAppPermission;
    setState(() => _whatsAppPermission = value);
    try {
      await Netmera.setWhatsAppPermission(value);
    } catch (e) {
      print("Error setting whatsapp permission: $e");
      setState(() => _whatsAppPermission = oldValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView(
      children: [
        SwitchListTile(
          title: const Text("Email Permission"),
          value: _emailPermission,
          onChanged: (value) => _setEmailPermission(value),
        ),
        SwitchListTile(
          title: const Text("SMS Permission"),
          value: _smsPermission,
          onChanged: (value) => _setSmsPermission(value),
        ),
        SwitchListTile(
          title: const Text("WhatsApp Permission"),
          value: _whatsAppPermission,
          onChanged: (value) => _setWhatsAppPermission(value),
        ),
      ],
    );
  }
}
