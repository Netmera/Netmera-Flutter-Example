import 'package:flutter/material.dart';
import 'package:netmera_flutter_example/ui/app_theme.dart';
import 'package:netmera_flutter_example/ui/feedback.dart';
import 'package:netmera_flutter_example/ui/widgets/list_rows.dart';
import 'package:netmera_flutter_sdk/Netmera.dart';

class InAppMessagesPage extends StatefulWidget {
  const InAppMessagesPage({super.key});

  @override
  State<InAppMessagesPage> createState() => _InAppMessagesPageState();
}

class _InAppMessagesPageState extends State<InAppMessagesPage> {
  static const _fullScreenWidgetUrl =
      'https://ntm.netmera-web.com/container/androidsdk-widget-2_5.html';
  static const _popupWidgetUrl =
      'https://ntm.netmera-web.com/container/androidsdk-widget-3_1.html';

  // The SDK has no getter for this, so the last value set is kept for the
  // app session (popups are enabled by default).
  static bool _popupEnabled = true;

  final _widgetUrlController = TextEditingController();

  @override
  void dispose() {
    _widgetUrlController.dispose();
    super.dispose();
  }

  void _setPopupEnabled(bool enabled) {
    enabled
        ? Netmera.enablePopupPresentation()
        : Netmera.disablePopupPresentation();
    setState(() => _popupEnabled = enabled);
    showFeedback(enabled ? 'Popup enabled' : 'Popup disabled');
  }

  void _displayWidget(String defaultUrl) {
    final url = _widgetUrlController.text.trim();
    Netmera.displayWidgetContent(url.isEmpty ? defaultUrl : url);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        SwitchRow(
          key: const ValueKey('inApp.popupToggle'),
          title: 'Enable/Disable Popup',
          value: _popupEnabled,
          onChanged: _setPopupEnabled,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                key: const ValueKey('inApp.widgetUrl'),
                controller: _widgetUrlController,
                autocorrect: false,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Widget URL (optional)',
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'If empty, default URLs are used.',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
        const InsetDivider(),
        MenuRow(
          key: const ValueKey('inApp.displayWidgetFullScreen'),
          title: 'Display Widget via SDK (Full Screen)',
          onTap: () => _displayWidget(_fullScreenWidgetUrl),
        ),
        MenuRow(
          key: const ValueKey('inApp.displayWidgetPopup'),
          title: 'Display Widget via SDK (Popup)',
          onTap: () => _displayWidget(_popupWidgetUrl),
        ),
      ],
    );
  }
}
