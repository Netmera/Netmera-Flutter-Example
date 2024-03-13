///
/// Copyright (c) 2022 Inomera Research.
///
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:netmera_flutter_example/page_coupon.dart';
import 'package:netmera_flutter_example/page_event.dart';
import 'package:netmera_flutter_example/page_push_inbox.dart';
import 'package:netmera_flutter_example/page_user.dart';
import 'package:netmera_flutter_sdk/Netmera.dart';
import 'package:netmera_flutter_sdk/NetmeraPushBroadcastReceiver.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:flutter/services.dart';

import 'page_category.dart';

// This method must be a top-level function
@pragma('vm:entry-point')
void _onPushReceiveBackgroundHandler(Map<dynamic, dynamic> bundle) async {
  print("onPushReceiveBackground: $bundle");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // This method must be called before the runApp and the provided handler must be a top-level function.
  await FlutterConfig.loadEnvVariables();

  NetmeraPushBroadcastReceiver.onPushReceiveBackground(
      _onPushReceiveBackgroundHandler);
  runApp(const MyApp());
}

void initBroadcastReceiver() {
  void _onPushRegister(Map<dynamic, dynamic> bundle) async {
    print("onPushRegister: $bundle");
    _MyAppState._pushTokenString = bundle['pushToken'];
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
            backgroundColor: Colors.red,
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
        Netmera.setBaseUrl(_baseUrl);
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
        _baseUrl = FlutterConfig.get('NETMERA_PREPROD_BASE_URL');
        _controllerBaseUrl.text = FlutterConfig.get('NETMERA_PREPROD_BASE_URL');
        _apiKey = FlutterConfig.get('NETMERA_PREPROD_API_KEY');
        _controllerApiKey.text = FlutterConfig.get('NETMERA_PREPROD_API_KEY');
      });
    } else if (_baseUrl == 'c' && _apiKey == 'c') {
      setState(() {
        _baseUrl = FlutterConfig.get('NETMERA_TEST_BASE_URL');
        _controllerBaseUrl.text = FlutterConfig.get('NETMERA_TEST_BASE_URL');
        _apiKey = FlutterConfig.get('NETMERA_TEST_API_KEY');
        _controllerApiKey.text = FlutterConfig.get('NETMERA_TEST_API_KEY');
      });
    } else if (_baseUrl == 'd' && _apiKey == 'd') {
      setState(() {
        _baseUrl = FlutterConfig.get('NETMERA_PROD_BASE_URL');
        _controllerBaseUrl.text = FlutterConfig.get('NETMERA_PROD_BASE_URL');
        _apiKey = FlutterConfig.get('NETMERA_PROD_API_KEY');
        _controllerApiKey.text = FlutterConfig.get('NETMERA_PROD_API_KEY');
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
          backgroundColor: Colors.red,
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

  isPushEnabled() {
    Netmera.isPushEnabled().then((enabled) {
      Fluttertoast.showToast(
          msg: 'Is Push Enabled: $enabled',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
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
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  turnOffSendingEventAndUserUpdate() {
    Netmera.turnOffSendingEventAndUserUpdate(false);
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
                    ElevatedButton(
                      onPressed: enableData,
                      child: const Text('ENABLE DATA'),
                    ),
                    ElevatedButton(
                      onPressed: disableData,
                      child: const Text('DISABLE DATA'),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 8),
                child: ElevatedButton(
                  onPressed: enableLocationAndGeofence,
                  child: const Text('ENABLE LOCATION & GEOFENCE'),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 8),
                child: ElevatedButton(
                  onPressed: requestPushNotificationAuthorization,
                  child: const Text('REQUEST PUSH NOTIFICATION AUTHORIZATION'),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 8),
                child: ElevatedButton(
                  onPressed: navigateToCoupons,
                  child: const Text('COUPONS'),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 8),
                child: ElevatedButton(
                  onPressed: currentExternalId,
                  child: const Text('CURRENT EXTERNAL ID'),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 8),
                child: ElevatedButton(
                  onPressed: navigateToEvents,
                  child: const Text('EVENTS'),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 8),
                child: ElevatedButton(
                  onPressed: navigateToUser,
                  child: const Text('USER'),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 8),
                child: ElevatedButton(
                  onPressed: navigateToPushInbox,
                  child: const Text('PUSH INBOX'),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 8),
                child: ElevatedButton(
                  onPressed: navigateToCategory,
                  child: const Text('CATEGORY'),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 8),
                child: ElevatedButton(
                  onPressed: isPushEnabled,
                  child: const Text('IS PUSH ENABLED'),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 8),
                child: ElevatedButton(
                    onPressed: enableOrDisablePush,
                    child:
                        Text(_isPushEnabled ? 'DISABLE PUSH' : 'ENABLE PUSH')),
              ),
              Container(
                  margin: const EdgeInsets.only(top: 8),
                  child: ElevatedButton(
                    onPressed: disableOrEnablePopUpPresentation,
                    child: Text(_isPopUpPresentationEnabled
                        ? 'DISABLE PRESENTATION STATE'
                        : 'ENABLE PRESENTATION STATE'),
                  )),
              Container(
                margin: const EdgeInsets.only(top: 8),
                child: ElevatedButton(
                  onPressed: setNetmeraMaxActiveRegion,
                  child: const Text('SET NETMERA MAX ACTIVE REGION'),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 8),
                child: ElevatedButton(
                  onPressed: toastPushTest,
                  child: const Text('TOAST PUSH TOKEN'),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 8),
                child: ElevatedButton(
                  onPressed: turnOffSendingEventAndUserUpdate,
                  child: const Text('TURN OFF SENDING EVENT AND USER UPDATE'),
                ),
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
