///
/// Copyright (c) 2022 Inomera Research.
///

import 'package:flutter/material.dart';
import 'package:netmera_flutter_sdk/Netmera.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _isPushEnabled = "";

  disablePopupPresentation() {
    Netmera.disablePopupPresentation();
  }

  enablePopupPresentation() {
    Netmera.enablePopupPresentation();
  }

  requestPermissionsForLocation() {
    Netmera.requestPermissionsForLocation();
  }

  requestPushNotificationAuthorization() {
    Netmera.requestPushNotificationAuthorization();
  }

  setNetmeraMaxActiveRegions() {
    Netmera.setNetmeraMaxActiveRegions(10);
  }

  turnOffSendingEventAndUserUpdate() {
    Netmera.turnOffSendingEventAndUserUpdate(false);
  }

  isPushEnabled() {
    Netmera.isPushEnabled().then((enabled) {
      setState(() {
        _isPushEnabled = enabled.toString();
      });
    });
  }

  areNotificationsEnabled() {
    Netmera.areNotificationsEnabled().then((enabled) {
      setState(() {
        _isPushEnabled = enabled.toString();
      });
    });
  }

  getCurrentExternalId() {
    Netmera.getCurrentExternalId().then((externalId) {
      setState(() {
        _isPushEnabled = externalId.toString();
      });
    });
  }

  enablePush() {
    Netmera.enablePush();
  }

  disablePush() {
    Netmera.disablePush();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(_isPushEnabled),
        ElevatedButton(
          child: const Text('Is Push Enabled'),
          onPressed: isPushEnabled,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              child: const Text('Enable Push'),
              onPressed: enablePush,
            ),
            ElevatedButton(
              child: const Text('Disable Push'),
              onPressed: disablePush,
            ),
          ],
        ),
        ElevatedButton(
          child: const Text('Are Notifications Enabled'),
          onPressed: areNotificationsEnabled,
        ),
        ElevatedButton(
          child: const Text('Request Push Notification Authorization'),
          onPressed: requestPushNotificationAuthorization,
        ),
        ElevatedButton(
          child: const Text('Disable Popup Presentation'),
          onPressed: disablePopupPresentation,
        ),
        ElevatedButton(child: const Text('Enable Popup Presentation'), onPressed: enablePopupPresentation),
        ElevatedButton(
          child: const Text('Request Permission For Location'),
          onPressed: requestPermissionsForLocation,
        ),
        ElevatedButton(
          child: const Text('Set Netmera Max Active Regions'),
          onPressed: setNetmeraMaxActiveRegions,
        ),
        ElevatedButton(
          child: const Text('Turn Off Sending Event And User Update'),
          onPressed: turnOffSendingEventAndUserUpdate,
        ),
        ElevatedButton(
          child: const Text('Current External Id'),
          onPressed: getCurrentExternalId,
        ),
      ],
    );
  }
}
