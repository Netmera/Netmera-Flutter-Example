///
/// Copyright (c) 2022 Inomera Research.
///
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:huawei_push/huawei_push.dart' as hms;
import 'package:netmera_flutter_example/example_push_token.dart';
import 'package:netmera_flutter_example/page_dashboard.dart';
import 'package:netmera_flutter_sdk/Netmera.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:netmera_flutter_sdk/NetmeraPushLifecycleCallbacks.dart';
import 'package:netmera_flutter_sdk/NetmeraPushObject.dart';
import 'package:netmera_flutter_sdk/NetmeraInteractiveAction.dart';
import 'package:netmera_flutter_sdk/NetmeraCarouselObject.dart';
import 'package:netmera_flutter_example/utils/log_utils.dart';
import 'package:netmera_flutter_example/utils/push_event_bus.dart';
import 'package:netmera_flutter_example/widgets/push_event_overlay.dart';

// This method must be a top-level function
@pragma('vm:entry-point')
Future<void> _onPushReceiveBackgroundHandler(NetmeraPushObject push) async {
  debugPrint("onPushReceiveBackground: ${getPushObjectString(push)}");
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  if (Netmera.isNetmeraRemoteMessage(message.data)) {
    Netmera.onNetmeraFirebasePushMessageReceived(message.from, message.data);
  }
}

@pragma('vm:entry-point')
void backgroundMessageCallback(hms.RemoteMessage remoteMessage) async {
  Map<String, String> map = remoteMessage.dataOfMap ?? {};
  if (Netmera.isNetmeraRemoteMessage(map)) {
    Netmera.onNetmeraHuaweiPushMessageReceived(remoteMessage.from, map);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  NetmeraPushLifecycleCallbacks.setBackgroundMessageHandler(_onPushReceiveBackgroundHandler);
  runApp(const MyApp());
}

Future<void> initPushCallbacks() async {
  await NetmeraPushLifecycleCallbacks.initialize(
    onPushRegister: (String pushToken) async {
      debugPrint("onPushRegister: $pushToken");
      ExamplePushToken.value = pushToken;
      emitPushEvent('onPushRegister', {'pushToken': pushToken});
    },
    onPushReceive: (NetmeraPushObject push) async {
      debugPrint("onPushReceive: ${getPushObjectString(push)}");
      emitPushEvent('onPushReceive', mapPushObject(push));
    },
    onPushOpen: (NetmeraPushObject push) async {
      debugPrint("onPushOpen: ${getPushObjectString(push)}");
      emitPushEvent('onPushOpen', mapPushObject(push));
    },
    onPushDismiss: (NetmeraPushObject push) async {
      debugPrint("onPushDismiss: ${getPushObjectString(push)}");
      emitPushEvent('onPushDismiss', mapPushObject(push));
    },
    onPushButtonClicked:
        (NetmeraPushObject push, NetmeraInteractiveAction? action) async {
      debugPrint("onPushButtonClicked: ${getPushObjectString(push)}");
      debugPrint("clickedAction: id=${action?.getId()}, title=${action?.getActionTitle()}, act=${action?.getPushAction()?.actionType}");
      emitPushEvent('onPushButtonClicked', {
        'push': mapPushObject(push),
        'action': action == null
            ? null
            : {
                'id': action.getId(),
                'title': action.getActionTitle(),
                'actionType': action.getPushAction()?.actionType?.toString(),
              },
      });
    },
    onCarouselObjectSelected:
        (NetmeraPushObject push, NetmeraCarouselObject? item) async {
      debugPrint("onCarouselObjectSelected: ${getPushObjectString(push)}");
      debugPrint("carouselItem: id=${item?.id}, picturePath=${item?.picturePath}, action=${item?.action?.actionType}");
      emitPushEvent('onCarouselObjectSelected', {
        'push': mapPushObject(push),
        'carouselItem': item == null
            ? null
            : {
                'id': item.id,
                'picturePath': item.picturePath,
                'actionType': item.action?.actionType?.toString(),
              },
      });
    },
  );
}

Future<void> initFirebase() async {
  await Firebase.initializeApp();

  FirebaseMessaging.instance.getToken().then((token) {
    if (token == null) return;
    debugPrint("Custom push token: $token");
    Netmera.onNetmeraNewToken(token);
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (Netmera.isNetmeraRemoteMessage(message.data)) {
      Netmera.onNetmeraFirebasePushMessageReceived(message.from, message.data);
    }
  });
}

Future<void> initHMSPush() async {
  hms.Push.getTokenStream.listen((String token) {
    Netmera.onNetmeraNewToken(token);
  });

  hms.Push.onMessageReceivedStream.listen((hms.RemoteMessage remoteMessage) {
    Map<String, String> map = remoteMessage.dataOfMap ?? {};
    if (Netmera.isNetmeraRemoteMessage(map)) {
      Netmera.onNetmeraHuaweiPushMessageReceived(remoteMessage.from, map);
    }
  });

  bool backgroundMessageHandler = await hms.Push.registerBackgroundMessageHandler(backgroundMessageCallback);
  debugPrint("HMS backgroundMessageHandler registered: $backgroundMessageHandler");
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

    initPushCallbacks();

    Netmera.isPushEnabled().then((enabled) {
      debugPrint("Netmera: isPushEnabled = $enabled");
    });

    Netmera.enablePopupPresentation();

    void _onWidgetUrlTriggered(String url) {
      String message = "Widget URL handled by app: $url";
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
      builder: (context, child) => PushEventOverlay(child: child!),
      home: const DashboardPage(),
    );
  }
}
