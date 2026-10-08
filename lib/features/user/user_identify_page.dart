import 'package:flutter/material.dart';
import 'package:netmera_flutter_example/ui/app_theme.dart';
import 'package:netmera_flutter_example/ui/feedback.dart';
import 'package:netmera_flutter_sdk/Netmera.dart';
import 'package:netmera_flutter_sdk/NetmeraUser.dart';

class UserIdentifyPage extends StatefulWidget {
  const UserIdentifyPage({super.key});

  @override
  State<UserIdentifyPage> createState() => _UserIdentifyPageState();
}

class _UserIdentifyPageState extends State<UserIdentifyPage> {
  final _userId = TextEditingController();
  final _email = TextEditingController();
  final _msisdn = TextEditingController();
  final _whatsApp = TextEditingController();

  @override
  void dispose() {
    for (final controller in [_userId, _email, _msisdn, _whatsApp]) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Empty fields are left untouched; [deleteKeyword] clears the value.
  NetmeraUser _buildUser() {
    final user = NetmeraUser();
    void apply(
      TextEditingController controller,
      void Function(String?) set, {
      String deleteKeyword = 'null',
    }) {
      final text = controller.text.trim();
      if (text.isEmpty) return;
      set(text.toLowerCase() == deleteKeyword ? null : text);
    }

    apply(_userId, user.setUserId);
    apply(_email, user.setEmail);
    apply(_msisdn, user.setMsisdn, deleteKeyword: '0000');
    apply(_whatsApp, user.setWhatsAppNumber, deleteKeyword: '0000');
    return user;
  }

  void _identify() => Netmera.identifyUser(_buildUser());

  void _identifyWithCallback() {
    Netmera.identifyUser(
      _buildUser(),
      onSuccess: () =>
          showFeedback('User identify succeeded', style: FeedbackStyle.success),
      onFailure: (error) => showFeedback(
        'User identify failed with error: $error',
        style: FeedbackStyle.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Field(
          id: 'userId',
          hint: 'User ID (Type null to delete it)',
          controller: _userId,
        ),
        _Field(
          id: 'email',
          hint: 'Email (Type null to delete it)',
          controller: _email,
          keyboardType: TextInputType.emailAddress,
        ),
        _Field(
          id: 'msisdn',
          hint: 'MSISDN (Type 0000 to delete it)',
          controller: _msisdn,
          keyboardType: TextInputType.phone,
        ),
        _Field(
          id: 'whatsApp',
          hint: 'WhatsApp Number (Type 0000 to delete it)',
          controller: _whatsApp,
          keyboardType: TextInputType.phone,
          isLast: true,
        ),
        ElevatedButton(
          key: const ValueKey('userIdentify.submit'),
          onPressed: _identify,
          child: const Text('Identify User'),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          key: const ValueKey('userIdentify.submitWithCallback'),
          style: AppButtonStyles.callback,
          onPressed: _identifyWithCallback,
          child: const Text('Identify User With Callback'),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.id,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.isLast = false,
  });

  final String id;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        key: ValueKey('userIdentify.$id'),
        controller: controller,
        keyboardType: keyboardType,
        autocorrect: false,
        textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
        decoration: InputDecoration(hintText: hint),
      ),
    );
  }
}
