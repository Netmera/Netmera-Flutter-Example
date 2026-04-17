import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:netmera_flutter_example/example_push_token.dart';
import 'package:netmera_flutter_sdk/Netmera.dart';

///
/// Copyright (c) 2026 Netmera Research.
///
class SettingsPage extends StatefulWidget {
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
    Netmera.requestPushNotificationAuthorization().then((isGranted) {
      String message = "Notification auth result: $isGranted";
      print(message);
      Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: isGranted ? Colors.green : Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    });
  }

  setNetmeraMaxActiveRegions() {
    Netmera.setNetmeraMaxActiveRegions(10);
  }

  startDataTransfer() {
    Netmera.startDataTransfer();
  }

  stopDataTransfer() {
    Netmera.stopDataTransfer();
  }

  kill() {
    Netmera.kill();
  }

  isPushEnabled() {
    Netmera.isPushEnabled().then((enabled) {
      setState(() {
        _isPushEnabled = enabled.toString();
      });
    });
  }

  checkNotificationPermission() {
    Netmera.checkNotificationPermission().then((status) {
      if (status != null) {
        setState(() {
          _isPushEnabled = status.name;
        });
      }
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

  toastPushToken() {
    Fluttertoast.showToast(
        msg: 'Pushtoken :: ${ExamplePushToken.value}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.blueGrey,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
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
            child: const Text('Check Notification Permission'),
            onPressed: checkNotificationPermission,
          ),
          ElevatedButton(
            child: const Text('Request Push Notification Authorization'),
            onPressed: requestPushNotificationAuthorization,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                child: const Text('Disable Popup Pres.'),
                onPressed: disablePopupPresentation,
              ),
              ElevatedButton(
                child: const Text('Enable Popup Pres.'),
                onPressed: enablePopupPresentation,
              ),
            ],
          ),
          ElevatedButton(
            child: const Text('Request Permission For Location'),
            onPressed: requestPermissionsForLocation,
          ),
          ElevatedButton(
            child: const Text('Set Netmera Max Active Regions'),
            onPressed: setNetmeraMaxActiveRegions,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                child: const Text('Start Data Transfer'),
                onPressed: startDataTransfer,
              ),
              ElevatedButton(
                child: const Text('Stop Data Transfer'),
                onPressed: stopDataTransfer,
              ),
            ],
          ),
          ElevatedButton(
            child: const Text('Current External Id'),
            onPressed: getCurrentExternalId,
          ),
          ElevatedButton(
            child: const Text('Kill Netmera'),
            onPressed: kill,
          ),
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Text('DEVICE TOKEN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SelectableText(ExamplePushToken.value.isEmpty ? '(empty)' : ExamplePushToken.value),
          ),
          ElevatedButton(
            child: const Text('Toast Push Token'),
            onPressed: toastPushToken,
          ),
        ],
      ),
    );
  }
}
