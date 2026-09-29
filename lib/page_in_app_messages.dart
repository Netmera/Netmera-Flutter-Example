import 'package:flutter/material.dart';
import 'package:netmera_flutter_sdk/Netmera.dart';

///
/// Copyright (c) 2026 Netmera Research.
///
class InAppMessagesPage extends StatefulWidget {
  @override
  _InAppMessagesPageState createState() => _InAppMessagesPageState();
}

class _InAppMessagesPageState extends State<InAppMessagesPage> {
  static const _fullscreenWidgetUrl = 'https://ntm.netmera-web.com/container/androidsdk-widget-2_5.html';
  static const _popupWidgetUrl = 'https://ntm.netmera-web.com/container/androidsdk-widget-3_1.html';

  final TextEditingController _widgetUrlController = TextEditingController();
  bool _isPopupPresentationEnabled = true;

  @override
  void dispose() {
    _widgetUrlController.dispose();
    super.dispose();
  }

  disableOrEnablePopupPresentation() {
    if (_isPopupPresentationEnabled) {
      Netmera.disablePopupPresentation();
    } else {
      Netmera.enablePopupPresentation();
    }
    setState(() {
      _isPopupPresentationEnabled = !_isPopupPresentationEnabled;
    });
  }

  displayWidget(String defaultUrl) {
    final url = _widgetUrlController.text.trim();
    Netmera.displayWidgetContent(url.isEmpty ? defaultUrl : url);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            child: Text(_isPopupPresentationEnabled ? 'Disable Popup Pres.' : 'Enable Popup Pres.'),
            onPressed: disableOrEnablePopupPresentation,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _widgetUrlController,
              autocorrect: false,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Widget URL',
              ),
            ),
          ),
          ElevatedButton(
            child: const Text('Display Widget Fullscreen'),
            onPressed: () => displayWidget(_fullscreenWidgetUrl),
          ),
          ElevatedButton(
            child: const Text('Display Widget Popup'),
            onPressed: () => displayWidget(_popupWidgetUrl),
          ),
        ],
      ),
    );
  }
}
