///
/// Copyright (c) 2022 Inomera Research.
///
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:netmera_flutter_example/page_event.dart';
import 'package:netmera_flutter_example/page_push_inbox.dart';
import 'package:netmera_flutter_example/page_settings.dart';
import 'package:netmera_flutter_example/page_user.dart';
import 'package:netmera_flutter_sdk/Netmera.dart';
import 'package:netmera_flutter_sdk/NetmeraPushBroadcastReceiver.dart';

import 'page_category.dart';

void main() {
  initBroadcastReceiver();
  runApp(const MyApp());
}

void _onPushRegister(Map<dynamic, dynamic> bundle) async {
  print("onPushRegister: $bundle");
}

void _onPushReceive(Map<dynamic, dynamic> bundle) async {
  print("onPushReceive: $bundle");
}

void _onPushDismiss(Map<dynamic, dynamic> bundle) async {
  print("onPushDismiss: $bundle");
}

void _onPushOpen(Map<dynamic, dynamic> bundle) async {
  print("onPushOpen: $bundle");
}

void _onPushButtonClicked(Map<dynamic, dynamic> bundle) async {
  print("onPushButtonClicked: $bundle");
}

void _onCarouselObjectSelected(Map<dynamic, dynamic> bundle) async {
  print("onCarouselObjectSelected: $bundle");
}

void initBroadcastReceiver() {
  NetmeraPushBroadcastReceiver receiver = NetmeraPushBroadcastReceiver();
  receiver.initialize(
      onPushRegister: _onPushRegister,
      onPushReceive: _onPushReceive,
      onPushDismiss: _onPushDismiss,
      onPushOpen: _onPushOpen,
      onPushButtonClicked: _onPushButtonClicked,
      onCarouselObjectSelected: _onCarouselObjectSelected);
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    Netmera.isPushEnabled().then((enabled) {
      print("Netmera: isPushEnabled = " + enabled.toString());
    });

    // Add this to enable popup presentation on app start.
    Netmera.enablePopupPresentation();

    if (Platform.isIOS) {
      Netmera.requestPushNotificationAuthorization();
      Netmera.setAppGroupName(
          "group.com.netmera.flutter"); // Set your app group name
    }

    String msg;
    Future.delayed(const Duration(milliseconds: 1000), () {
      Netmera.getCurrentExternalId().then((value) {
        msg = value == null
            ? "ExternalID was not set yet"
            : "ExternalId :: " + value;
        Fluttertoast.showToast(
            msg: msg,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 5,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(icon: Text("Event")),
                Tab(icon: Text("User")),
                Tab(icon: Text("Push\nInbox")),
                Tab(icon: Text("Settings")),
                Tab(icon: Text("Category")),
              ],
            ),
            title: const Text('Netmera Flutter Example'),
          ),
          body: const TabBarView(
            children: [
              EventPage(),
              UserPage(),
              PushInboxPage(),
              SettingsPage(),
              CategoryPage()
            ],
          ),
        ),
      ),
    );
  }
}
