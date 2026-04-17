import 'package:flutter/material.dart';
import 'package:netmera_flutter_sdk/Netmera.dart';
import 'package:netmera_flutter_sdk/NetmeraUser.dart';

///
/// Copyright (c) 2026 Netmera Research.
///
class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final TextEditingController userController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController msisdnController = TextEditingController();
  final TextEditingController wpNumberController = TextEditingController();

  String? _valueFromInput(String text) {
    final t = text.trim();
    if (t.toLowerCase() == 'null') return null;
    return t;
  }

  bool _hasInput(String text) => text.trim().isNotEmpty;

  void _applyUserInputs(NetmeraUser user) {
    if (_hasInput(userController.text)) user.setUserId(_valueFromInput(userController.text));
    if (_hasInput(emailController.text)) user.setEmail(_valueFromInput(emailController.text));
    if (_hasInput(msisdnController.text)) user.setMsisdn(_valueFromInput(msisdnController.text));
    if (_hasInput(wpNumberController.text)) user.setWhatsAppNumber(_valueFromInput(wpNumberController.text));
  }

  void identifyUserWithCallback() {
    NetmeraUser user = NetmeraUser();
    _applyUserInputs(user);

    Netmera.identifyUser(user,
        onSuccess: () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User identified successfully!')));
          }
        },
        onFailure: (error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Identify user failed: $error')));
          }
        });
  }

  void identifyUserFireAndForget() {
    NetmeraUser user = NetmeraUser();
    _applyUserInputs(user);
    Netmera.identifyUser(user);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 50.0, right: 50.0),
            child: TextField(
              controller: userController,
              decoration: const InputDecoration(
                labelText: 'User ID (Optional)',
                hintText: 'Leave empty: not set; type "null": sets null',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 50.0, right: 50.0),
            child: TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email (Optional)',
                hintText: 'Leave empty: not set; type "null": sets null',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 50.0, right: 50.0),
            child: TextField(
              controller: msisdnController,
              decoration: const InputDecoration(
                labelText: 'Msisdn (Optional)',
                hintText: 'Leave empty: not set; type "null": sets null',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 50.0, right: 50.0),
            child: TextField(
              controller: wpNumberController,
              decoration: const InputDecoration(
                labelText: 'WhatsApp Number (Optional)',
                hintText: 'Leave empty: not set; type "null": sets null',
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 30),
            child: ElevatedButton(
              onPressed: identifyUserWithCallback,
              child: const Text('Identify User'),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 30),
            child: ElevatedButton(
              onPressed: identifyUserFireAndForget,
              child: const Text('Identify User (no callback)'),
            ),
          ),
        ],
      ),
    );
  }
}
