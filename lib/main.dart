///
/// Copyright (c) 2022 Inomera Research.
///
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:huawei_push/huawei_push.dart' as HMS;
import 'package:netmera_flutter_example/example_push_token.dart';
import 'package:netmera_flutter_example/page_dashboard.dart';
import 'package:netmera_flutter_sdk/Netmera.dart';
import 'package:netmera_flutter_sdk/NetmeraPushBroadcastReceiver.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';

// This method must be a top-level function
@pragma('vm:entry-point')
void _onPushReceiveBackgroundHandler(Map<dynamic, dynamic> bundle) async {
  print("onPushReceiveBackground: $bundle");
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  if (Netmera.isNetmeraRemoteMessage(message.data)) {
    Netmera.onNetmeraFirebasePushMessageReceived(message.from, message.data);
  }
}

@pragma('vm:entry-point')
void backgroundMessageCallback(HMS.RemoteMessage remoteMessage) async {
  Map<String, String> map = remoteMessage.dataOfMap ?? {};
  if (Netmera.isNetmeraRemoteMessage(map)) {
    Netmera.onNetmeraHuaweiPushMessageReceived(remoteMessage.from, map);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  NetmeraPushBroadcastReceiver.onPushReceiveBackground(
      _onPushReceiveBackgroundHandler);
  runApp(const MyApp());
}

void initBroadcastReceiver() {
  void _onPushRegister(Map<dynamic, dynamic> bundle) async {
    print("onPushRegister: $bundle");
    var pushToken = bundle['pushToken'];
    if (pushToken is List<int>) {
      String tokenString = pushToken.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
      ExamplePushToken.value = tokenString;
    } else if (pushToken is String) {
      ExamplePushToken.value = pushToken;
    } else {
      print("Unexpected push token format: ${pushToken.runtimeType}");
    }
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

  NetmeraPushBroadcastReceiver().initialize(
    onPushRegister: _onPushRegister,
    onPushReceive: _onPushReceive,
    onPushDismiss: _onPushDismiss,
    onPushOpen: _onPushOpen,
    onPushButtonClicked: _onPushButtonClicked,
    onCarouselObjectSelected: _onCarouselObjectSelected,
  );
}

Future<void> initFirebase() async {
  await Firebase.initializeApp();

  FirebaseMessaging.instance.getToken().then((value) {
    print("Custom push token: " + value!);
    Netmera.onNetmeraNewToken(value);
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (Netmera.isNetmeraRemoteMessage(message.data)) {
      Netmera.onNetmeraFirebasePushMessageReceived(message.from, message.data);
    }
  });
}

Future<void> initHMSPush() async {
  HMS.Push.getTokenStream.listen((String token) {
    Netmera.onNetmeraNewToken(token);
  });

  HMS.Push.onMessageReceivedStream.listen((HMS.RemoteMessage remoteMessage) {
    Map<String, String> map = remoteMessage.dataOfMap ?? {};
    if (Netmera.isNetmeraRemoteMessage(map)) {
      Netmera.onNetmeraHuaweiPushMessageReceived(remoteMessage.from, map);
    }
  });

  bool backgroundMessageHandler = await HMS.Push.registerBackgroundMessageHandler(backgroundMessageCallback);
  print("HMS backgroundMessageHandler registered: $backgroundMessageHandler");
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

    initAppLinks();
    initFirebase();

    if (Platform.isAndroid) {
      initHMSPush();
    }

    initBroadcastReceiver();

    Netmera.isPushEnabled().then((enabled) {
      print("Netmera: isPushEnabled = " + enabled.toString());
    });

    Netmera.enablePopupPresentation();

    void _onWidgetUrlTriggered(String url) {
      String message = "Widget URL handle by app: " + url;
      Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
    }

    Netmera.onWidgetUrlTriggered(_onWidgetUrlTriggered);

    String msg;
    Future.delayed(const Duration(milliseconds: 1000), () {
      Netmera.getCurrentExternalId().then((value) {
        msg = value == null ? "ExternalID was not set yet" : "ExternalId :: $value";
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

  Future<void> initAppLinks() async {
    try {
      final appLinks = AppLinks();
      final uri = await appLinks.getInitialLink();
      if (uri != null) {
        Fluttertoast.showToast(
            msg: 'Initial url is: $uri',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0);
      }

      appLinks.uriLinkStream.listen((uri) {
        Fluttertoast.showToast(
            msg: 'Deeplink url is: $uri',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0);
      });
    } catch (error) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)),
      home: const DashboardPage(),
    );
  }
}
