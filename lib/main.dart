///
/// Copyright (c) 2022 Inomera Research.
///
import 'dart:io';
import 'dart:ui';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:netmera_flutter_example/page_coupon.dart';
import 'package:netmera_flutter_example/page_event.dart';
import 'package:netmera_flutter_example/page_push_inbox.dart';
import 'package:netmera_flutter_example/page_user.dart';
import 'package:netmera_flutter_sdk/Netmera.dart';
import 'package:netmera_flutter_sdk/NetmeraPushBroadcastReceiver.dart';
import 'package:flutter/services.dart';
import 'package:netmera_flutter_sdk/NotificationPermissionStatus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';

import 'page_category.dart';
import 'config.dart';
import 'page_mandatory_event.dart';

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
      _MyAppState._pushTokenString = tokenString;
    } else if (pushToken is String) {
      _MyAppState._pushTokenString = pushToken;
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

initFirebase() async {
  await Firebase.initializeApp();

  FirebaseMessaging.instance
      .getToken()
      .then((value) {
    print("Custom push token: " + value!);
    Netmera.onNetmeraNewToken(value);
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (Netmera.isNetmeraRemoteMessage(message.data)) {
      Netmera.onNetmeraFirebasePushMessageReceived(message.from, message.data);
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _MyAppState();
}

class _MyAppState extends State<HomePage> {
  String _apiKey = "";
  String _baseUrl = "";
  bool _isPushEnabled = true;
  bool _isPopUpPresentationEnabled = true;
  static String _pushTokenString = "";
  static const platform = MethodChannel('nm_flutter_example_channel');
  TextEditingController _controllerApiKey = TextEditingController();
  TextEditingController _controllerBaseUrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    initAppLinks();
    initFirebase();

    initBroadcastReceiver();

    // Add this to enable popup presentation on app start.
    Netmera.enablePopupPresentation();

    if (Platform.isIOS) {
      Netmera.requestPushNotificationAuthorization();
      Netmera.setAppGroupName(
          "group.com.netmera.flutter"); // Set your app group name
    }

    Netmera.isPushEnabled().then((value) {
      if (value != null) {
        setState(() {
          _isPushEnabled = value;
        });
      }
    });

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
            backgroundColor: const Color.fromARGB(255, 166, 186, 171),
            textColor: Colors.white,
            fontSize: 16.0);
      });
    });
  }

  onCancelPress() {
    Navigator.pop(context);
  }

  onSetPress() {
    if (_baseUrl != '' && _apiKey != '') {
      if (Platform.isAndroid) {
        Netmera.skipAppConfigAndSetBaseUrl(_baseUrl);
      } else {
        Netmera.setBaseUrl(_baseUrl);
      }
      Netmera.setApiKey(_apiKey);
      platform.invokeMethod('setApiKey', {"apiKey": _apiKey});
      platform.invokeMethod('setBaseUrl', {"baseUrl": _baseUrl});
    }

    onCancelPress();
  }

onSetLongPress() {
    if (_baseUrl == 'b' && _apiKey == 'b') {
      setState(() {
        _baseUrl = Config.NETMERA_UAT_BASE_URL;
        _controllerBaseUrl.text = Config.NETMERA_UAT_BASE_URL;
        _apiKey = Config.NETMERA_UAT_API_KEY;
        _controllerApiKey.text = Config.NETMERA_UAT_API_KEY;
      });
    } else if (_baseUrl == 'c' && _apiKey == 'c') {
      setState(() {
        _baseUrl = Config.NETMERA_TEST_BASE_URL;
        _controllerBaseUrl.text = Config.NETMERA_TEST_BASE_URL;
        _apiKey = Config.NETMERA_TEST_API_KEY;
        _controllerApiKey.text = Config.NETMERA_TEST_API_KEY;
      });
    } else if (_baseUrl == 'd' && _apiKey == 'd') {
      setState(() {
        _baseUrl = Config.NETMERA_PROD_BASE_URL;
        _controllerBaseUrl.text = Config.NETMERA_PROD_BASE_URL;
        _apiKey = Config.NETMERA_PROD_API_KEY;
        _controllerApiKey.text = Config.NETMERA_PROD_API_KEY;
      });
    }
  }

  setProperties() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: SizedBox(
                  height: 140,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextField(
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: "BaseUrl"),
                          onChanged: (text) {
                            setState(() {
                              _baseUrl = text;
                            });
                          },
                          controller: _controllerBaseUrl,
                        ),
                        TextField(
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: "API Key"),
                          onChanged: (text) {
                            setState(() {
                              _apiKey = text;
                            });
                          },
                          controller: _controllerApiKey,
                        ),
                      ])),
              actions: [
                TextButton(
                  onPressed: onCancelPress,
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.blue, // Set your desired text color here
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onSetPress,
                  onLongPress: onSetLongPress,
                  child: const Text(
                    'SET',
                    style: TextStyle(
                      color:
                          Colors.deepPurple, // Set your desired text color here
                    ),
                  ),
                ),
              ],
            ));
  }

  enableData() {
    Netmera.startDataTransfer();
  }

  disableData() {
    Netmera.stopDataTransfer();
  }

  enableLocationAndGeofence() {
    Netmera.requestPermissionsForLocation();
  }

  checkNotificationPermission() {
    Netmera.checkNotificationPermission().then((status) {
      String statusString;

      switch (status) {
        case NotificationPermissionStatus.notDetermined:
          statusString = "NOT DETERMINED";
          break;
        case NotificationPermissionStatus.blocked:
          statusString = "BLOCKED";
          break;
        case NotificationPermissionStatus.denied:
          statusString = "DENIED";
          break;
        case NotificationPermissionStatus.granted:
          statusString = "GRANTED";
          break;
        case null:
          statusString = "UNDEFINED";
          break;
      }

      Fluttertoast.showToast(
            msg: statusString,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: const Color.fromARGB(255, 166, 186, 171),
            textColor: Colors.white,
            fontSize: 16.0);
    });
  }

  requestPushNotificationAuthorization() {
    Netmera.requestPushNotificationAuthorization();
  }

  navigateToCoupons() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const CouponPage()));
  }

  currentExternalId() {
    Netmera.getCurrentExternalId().then((externalId) {
      Fluttertoast.showToast(
          msg: 'Current External Id: $externalId',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: const Color.fromARGB(255, 166, 186, 171),
          textColor: Colors.white,
          fontSize: 16.0);
    });
  }

  navigateToEvents() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const EventPage()));
  }

  navigateToUser() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const UserPage()));
  }

  navigateToPushInbox() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const PushInboxPage()));
  }

  navigateToCategory() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const CategoryPage()));
  }

  kill() {
    Netmera.kill();
  }

  navigateToMandatoryEvent() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const MandatoryEventPage()));
  }

  isPushEnabled() {
    Netmera.isPushEnabled().then((enabled) {
      Fluttertoast.showToast(
          msg: 'Is Push Enabled: $enabled',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: const Color.fromARGB(255, 166, 186, 171),
          textColor: Colors.white,
          fontSize: 16.0);
    });
  }

  enableOrDisablePush() {
    if (_isPushEnabled) {
      Netmera.disablePush();
      setState(() {
        _isPushEnabled = false;
      });
    } else {
      Netmera.enablePush();
      setState(() {
        _isPushEnabled = true;
      });
    }
  }

  disableOrEnablePopUpPresentation() {
    if (_isPopUpPresentationEnabled) {
      Netmera.disablePopupPresentation();
      setState(() {
        _isPopUpPresentationEnabled = false;
      });
    } else {
      Netmera.enablePopupPresentation();
      setState(() {
        _isPopUpPresentationEnabled = true;
      });
    }
  }

  setNetmeraMaxActiveRegion() {
    Netmera.setNetmeraMaxActiveRegions(10);
  }

  toastPushTest() {
    Fluttertoast.showToast(
        msg: 'Pushtoken :: $_pushTokenString',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: const Color.fromARGB(255, 166, 186, 171),
        textColor: Colors.white,
        fontSize: 16.0);
  }

  turnOffSendingEventAndUserUpdate() {
    Netmera.turnOffSendingEventAndUserUpdate(false);
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
            backgroundColor: const Color.fromARGB(255, 166, 186, 171),
            textColor: Colors.white,
            fontSize: 16.0);
      }

      appLinks.uriLinkStream.listen((uri) {
        if (uri != null) {
          Fluttertoast.showToast(
              msg: 'Deeplink url is: $uri',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              backgroundColor: const Color.fromARGB(255, 166, 186, 171),
              textColor: Colors.white,
              fontSize: 16.0);
        }
      });
    } catch (error) {}
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          body: SafeArea(
              child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Flutter Example',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 13),
                ),
                onPressed: setProperties,
                child: const Text('SET PROPERTIES'),
              ),
            ],
          ),
          Expanded(
              child: SingleChildScrollView(
                  child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    button('ENABLE DATA', enableData),
                    button('DISABLE DATA', disableData),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 8),
                child: button('ENABLE LOCATION & GEOFENCE', enableLocationAndGeofence),
              ),
              Container(
                margin: const EdgeInsets.only(top: 8),
                child: button('CHECK NOTIFICATION PERMISSION',
                    checkNotificationPermission),
              ),
              Container(
                margin: const EdgeInsets.only(top: 8),
                child: button('REQUEST PUSH NOTIFICATION AUTHORIZATION',
                    requestPushNotificationAuthorization),
              ),
              Container(
                margin: const EdgeInsets.only(top: 8),
                child: button('COUPONS', navigateToCoupons),
              ),
              Container(
                margin: const EdgeInsets.only(top: 8),
                child: button('CURRENT EXTERNAL ID', currentExternalId),
              ),
              Container(
                margin: const EdgeInsets.only(top: 8),
                child: button('EVENTS', navigateToEvents),
              ),
              Container(
                margin: const EdgeInsets.only(top: 8),
                child: button('MANDATORY EVENT', navigateToMandatoryEvent),
              ),
              Container(
                margin: const EdgeInsets.only(top: 8),
                child: button('USER', navigateToUser),
              ),
              Container(
                margin: const EdgeInsets.only(top: 8),
                child: button('PUSH INBOX', navigateToPushInbox),
              ),
              Container(
                margin: const EdgeInsets.only(top: 8),
                child: button('CATEGORY', navigateToCategory),
              ),
              Container(
                margin: const EdgeInsets.only(top: 8),
                child: button('IS PUSH ENABLED', isPushEnabled),
              ),
              Container(
                margin: const EdgeInsets.only(top: 8),
                child: button(_isPushEnabled ? 'DISABLE PUSH' : 'ENABLE PUSH',
                    enableOrDisablePush),
              ),
              Container(
                  margin: const EdgeInsets.only(top: 8),
                  child: button(
                      _isPopUpPresentationEnabled
                      ? 'DISABLE PRESENTATION STATE'
                      : 'ENABLE PRESENTATION STATE',
                      disableOrEnablePopUpPresentation),
              ),
              Container(
                margin: const EdgeInsets.only(top: 8),
                child: button('SET NETMERA MAX ACTIVE REGION',
                    setNetmeraMaxActiveRegion),
              ),
              Container(
                margin: const EdgeInsets.only(top: 8),
                child: button('TOAST PUSH TOKEN', toastPushTest),
              ),
              Container(
                margin: const EdgeInsets.only(top: 8),
                child: button('TURN OFF SENDING EVENT AND USER UPDATE',
                    turnOffSendingEventAndUserUpdate),
              ),
              Container(
                margin: const EdgeInsets.only(top: 8),
                child: button('KILL NETMERA',
                    kill),
              ),
              Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 16),
                  child: Column(children: [
                    const Text('DEVICE TOKEN',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      child: Text(_pushTokenString),
                    ),
                  ])),
            ],
          )))
        ]),
      ))),
    );
  }
}

ElevatedButton button(String text, VoidCallback onPressed) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
    ),
    child: Text(
      text,
      style: const TextStyle(color: Colors.white),
    ),
  );
}
