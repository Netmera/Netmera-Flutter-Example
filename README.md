# Netmera Flutter Example

This project is the example application for [Netmera Flutter SDK](https://pub.dev/packages/netmera_flutter_sdk).

NETMERA is a Mobile Application Engagement Platform. We offer a series of development tools and app communication features to help your mobile business ignite and soar.

### Installation

##### For using this package as a library:

- Add this to your package's pubspec.yaml file

```
dependencies:
  netmera_flutter_sdk: ^3.x.x
```

- You can install packages from the command line with Flutter:

```
$ flutter pub get
```

For both native sides(Android & iOS) you don't have to include extra Netmera SDK libraries.

### Setup - Android Part

1) Create and register your app in [Firebase console](https://firebase.google.com/).

2) Download `google-services.json` file and place it into android/app/ folder.

3) In your project's build gradle file, add the following dependency.

```
buildscript {
    repositories {
        google()
        mavenCentral()
        maven {url 'https://developer.huawei.com/repo/'}
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:<YOUR_AGP_VERSION>'
        classpath 'com.google.gms:google-services:<YOUR_GMS_VERSION>'
        classpath 'com.huawei.agconnect:agcp:<YOUR_AGCP_VERSION>'
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven {url 'https://maven.google.com'}
        maven {url 'https://developer.huawei.com/repo/'}
    }
}
```

4) In your app's build gradle file, add the following dependency.

```

 dependencies {
 
     implementation 'androidx.core:core:1.7.0'
     
 }
```


5) Add the following into the top of app's build.gradle file

```
apply plugin: 'com.google.gms.google-services'
apply plugin: 'com.huawei.agconnect'
```

6) Create an application class as shown below.

- Your Application class must extends `Application`.

``` 
    public class NMApp extends Application {
    
        @Override
        public void onCreate() {
            super.onCreate();
            FNetmeraConfiguration fNetmeraConfiguration = new FNetmeraConfiguration.Builder()
                .firebaseSenderId(<YOUR GCM SENDER ID>)
                .huaweiSenderId(<YOUR HMS SENDER ID>)
                .apiKey(<YOUR NETMERA API KEY>)
                .logging(true) // This is for enabling Netmera logs.
                .build(this);
            FNetmera.initNetmera(fNetmeraConfiguration); 
        }
    }
```

### Setup - iOS Part

1) Add the following post_install block to the end of your Podfile.

```
post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name.include?('Swinject')
      target.build_configurations.each do |config|
        config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
      end
    end
  end
end
```

2) Navigate to ios folder in your terminal and run the following command.

```
$ pod install
```

3) Enable push notifications for your project

    1) If you have not generated a valid push notification certificate yet,
       generate one and then export by following the steps explained in [Configuring Push Notifications section of App Distribution Guide](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/establishing_a_certificate-based_connection_to_apns#2947597)
    2) Export the generated push certificate in .p12 format and upload to Netmera Dashboard.
    3) Enable Push Notifications capability for your application as explained in [Enable Push Notifications](https://developer.netmera.com/en/IOS/Quick-Start#enable-push-notifications) guide.
    4) Enable Remote notifications background mode for your application as explained in [Configuring Background Modes](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/pushing_background_updates_to_your_app#2980038) guide.

4) Add the `Netmera-Config.plist` file to your ios/Runner directory.

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>sdk_params</key>
        <dict>
            <key>api_key</key>
            <string>YOUR-API-KEY</string>
        </dict>
    </dict>
</plist>
```

- If you are using Netmera on-premises, you must add your server URL as the base_url key inside sdk_params.

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>sdk_params</key>
        <dict>
            ...
            <key>base_url</key>
            <string>YOUR-BASE-URL</string>
        </dict>
    </dict>
</plist>
```

5) In order to use iOS10 Media Push, follow the instructions in [Netmera Product Hub.](https://user.netmera.com/netmera-developer-guide/platforms/ios/new-ios-swift/push-notifications/media-push) Differently, you should add the pods to the top of the `Podfile` as below.

```
// For receiving Media Push, you must add Netmera pods to top of your Podfile.
pod 'NetmeraNotificationServiceExtension', "4.16.2"
pod "NetmeraNotificationContentExtension", "4.16.2"
```

6) In order to use the widget URL callback, add these lines into `AppDelegate.swift` file.

```
import NetmeraNotification
import netmera_flutter_sdk

...
  override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    ...
    FNetmera.setPushDelegate(self)
    ..
  }
...

extension AppDelegate: NetmeraPushDelegate {
    func urlOpeningDecision(for url: URL, push: NetmeraBasePush) -> PushDelegateDecision {
        return .appHandles
    }
    
    func openURL(_ url: URL, for push: NetmeraBasePush) {
        FNetmera.openURL(url: url, forPushObject: push)
    }
}
```

### Setup - Dart Part

1) Inside dart class add the following

```
void main() {
  initBroadcastReceiver();
  runApp(MyApp());
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

  NetmeraPushBroadcastReceiver().initialize(
    onPushRegister: _onPushRegister,
    onPushReceive: _onPushReceive,
    onPushDismiss: _onPushDismiss,
    onPushOpen: _onPushOpen,
    onPushButtonClicked: _onPushButtonClicked,
    onCarouselObjectSelected: _onCarouselObjectSelected,
  );
}
```

2) You need a background handler to be able to listen incoming push notifications when the application is in the background or terminated state. You can add this handler as follows. When received, an isolate is spawned (Android only, iOS does not require a separate isolate) allowing you to handle messages even when your application is not running.

    Note: Since the handler runs in its own isolate outside your applications context, it is not possible to update application state or execute any UI impacting logic. You can, however, perform logic such as HTTP requests, perform IO operations etc.

```
// This method must be a top-level function
@pragma('vm:entry-point')
void _onPushReceiveBackgroundHandler(Map<dynamic, dynamic> bundle) async {
  print("onPushReceiveBackground: $bundle");
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // This method must be called before the runApp and the provided handler must be a top-level function.
  NetmeraPushBroadcastReceiver.onPushReceiveBackground(_onPushReceiveBackgroundHandler);
  runApp(MyApp());
}
```

3) If you have custom Firebase Messaging integration, please see usage below.

1- Add the following line to your `AndroidManifest.xml` file inside the `application` tag to remove Netmera's default FCM service

```
<service
    android:name="com.netmera.nmfcm.NMFirebaseService"
    tools:node="remove" />
```

2- Update `FirebaseMessaging` methods like below

```
FirebaseMessaging messaging = FirebaseMessaging.instance;

messaging.getToken(vapidKey: <YOUR_KEY>).then((value) {
  Netmera.onNetmeraNewToken(value);
});

FirebaseMessaging.onMessage.listen((RemoteMessage message) {
     if (Netmera.isNetmeraRemoteMessage(message.data)) {
         Netmera.onNetmeraFirebasePushMessageReceived(message.from, message.data);
     }
});   

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  if (Netmera.isNetmeraRemoteMessage(message.data)) {
      Netmera.onNetmeraFirebasePushMessageReceived(message.from, message.data);
  }
}

```

- If you build your project with `flutter run --release`, please add `@pragma('vm:entry-point')` annotation to your `_firebaseMessagingBackgroundHandler` method as in the following code block.

```
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage remoteMessage) async {
// handle message
}
```

4) If you have custom Huawei Messaging integration, please see usage below.

1- Add the following line to your `AndroidManifest.xml` file inside the `application` tag to remove Netmera's default HMS service

```
<service
   android:name="com.netmera.nmhms.NMHuaweiService"
   tools:node="remove" />
```

2- Update `HuaweiPushKit` methods like below

```
Push.getTokenStream.listen((String token) {
  Netmera.onNetmeraNewToken(token);
});

Push.onMessageReceivedStream.listen((RemoteMessage remoteMessage) {
  Map<String, String> map = remoteMessage.dataOfMap ?? new Map();
  if (Netmera.isNetmeraRemoteMessage(map)) {
    Netmera.onNetmeraHuaweiPushMessageReceived(remoteMessage.from, map);
  }
});
```

### Calling Dart methods

##### Sending Event Examples

You can send your events as follows. For more examples, please see the [example project](https://github.com/Netmera/Netmera-Flutter-Example/blob/master/lib/page_event.dart).

```
  void sendLoginEvent() {
    NetmeraEventLogin loginEvent = new NetmeraEventLogin();
    Netmera.sendEvent(loginEvent);
  }

  void sendRegisterEvent() {
    NetmeraEventRegister registerEvent = new NetmeraEventRegister();
    Netmera.sendEvent(registerEvent);
  }

  void sendViewCartEvent() {
    NetmeraEventCartView cartViewEvent = new NetmeraEventCartView();
    cartViewEvent.setItemCount(3);
    cartViewEvent.setSubTotal(15.99);
    Netmera.sendEvent(cartViewEvent);
  }
```

##### Push Notification Permissions

If you don't request notification permission at runtime, you can request it by calling the `requestPushNotificationAuthorization()` method.
Note: Notification runtime permissions are required on Android 13 (API 33) or higher.
Therefore, before calling the method, make sure your project targets an API of 33 and above.

```
Netmera.requestPushNotificationAuthorization().then((isAllowed) {
  ...
});
```

You can call the `checkNotificationPermission()` method if you need to know the status of permissions.

```
 Netmera.checkNotificationPermission().then((status) {
      // NotificationPermissionStatus.notDetermined
      // NotificationPermissionStatus.blocked
      // NotificationPermissionStatus.denied
      // NotificationPermissionStatus.granted
 });
```

##### Widget URL Callback

In order to use the widget URL callback, use `onWidgetUrlTriggered` method as follows.

```
 void _onWidgetUrlTriggered(String url) {
   String message = "Widget URL handle by app: " + url;
   print(message);
 }

 Netmera.onWidgetUrlTriggered(_onWidgetUrlTriggered);
```


##### Netmera Inbox Examples

You can fetch the Netmera inbox as following. For more detailed usage, please see the [example project](https://github.com/Netmera/Netmera-Flutter-Example/blob/master/lib/page_push_inbox.dart).

```
  getInboxFilter() {
    NetmeraInboxFilter inboxFilter = NetmeraInboxFilter();
    inboxFilter.setPageSize(2);
    inboxFilter.setStatus(Netmera.PUSH_OBJECT_STATUS_UNREAD);
    inboxFilter.setIncludeExpiredObjects(true);
    inboxFilter.setCategories(null);
    return inboxFilter;
  }

  fetchInbox() async {
    Netmera.fetchInbox(getInboxFilter()).then((list) {
      debugPrint(list);
    }).catchError((error) {
      debugPrint(error);
    });
  }
```

##### Netmera Inbox Category Examples

You can fetch the Netmera category as following. For more detailed usage, please see the [example project](https://github.com/Netmera/Netmera-Flutter-Example/blob/master/lib/page_category.dart).

```
  getCategoryFilter() {
    NetmeraCategoryFilter categoryFilter = NetmeraCategoryFilter();
    categoryFilter.setPageSize(2);
    categoryFilter.setStatus(Netmera.PUSH_OBJECT_STATUS_UNREAD);
    categoryFilter.setIncludeExpiredObjects(true);
    return categoryFilter;
  }

  fetchCategory() async {
    Netmera.fetchCategory(getCategoryFilter()).then((list) {
      debugPrint(list);
    }).catchError((error) {
      debugPrint(error);
    });
  }
```

##### Netmera Getting ExternalId (if exists before)

```
    Netmera.getCurrentExternalId()
```

##### Netmera Popup Presentation
To enable popup presentation, you need to call the `enablePopupPresentation()` method on the page where you want to display the popup.
Note: To show popup on the app start or everywhere in the app, please add this to `initState()` method on your `main.dart` file.
```
 Netmera.enablePopupPresentation();
```

##### Data Start-Stop Transfer

###### Stop Data Transfer Method
The stopDataTransfer() method is a useful feature that can help users to temporarily pause all requests sent by the SDK to the backend.
This can be useful if, for example, the user needs to temporarily halt data transfers due to network issues or other reasons.
Once the issue has been resolved, the user can then restart the data transfer using the startDataTransfer() method.
```
 Netmera.stopDataTransfer();
```

###### Start Data Transfer Method
The startDataTransfer() method is a complementary feature to the stopDataTransfer() method, which allows users to restart any stopped requests.
This can be useful when the user has temporarily paused data transfers and is now ready to resume the transfer. Once the user calls the
startDataTransfer() method, the SDK will attempt to resend any requests that were previously stopped.
```
 Netmera.startDataTransfer();
```

Please explore this example project for detailed information.
