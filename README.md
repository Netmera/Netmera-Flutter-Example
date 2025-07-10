# Netmera Flutter Example

NETMERA is a Mobile Application Engagement Platform. We offer a series of development tools and app communication features to help your mobile business ignite and soar.

### Installation

##### For using this package as a library:

- Add this to your package's pubspec.yaml file

```
dependencies:
  netmera_flutter_sdk: ^x.x.x
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

1) Navigate to ios folder in your terminal and run the following command.

```
$ pod install
```

2) Download `GoogleService-Info.plist` file from Firebase and place it into ios/ folder.

3) Enable push notifications for your project

    1) If you have not generated a valid push notification certificate yet,
       generate one and then export by following the steps explained in [Configuring Push Notifications section of App Distribution Guide](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/establishing_a_certificate-based_connection_to_apns#2947597)
    2) Export the generated push certificate in .p12 format and upload to Netmera Dashboard.
    3) Enable Push Notifications capability for your application as explained in [Enable Push Notifications](https://developer.netmera.com/en/IOS/Quick-Start#enable-push-notifications) guide.
    4) Enable Remote notifications background mode for your application as explained in [Configuring Background Modes](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/pushing_background_updates_to_your_app#2980038) guide.



4) If you are using Swift, enter the following in your `Runner-Bridging-Header.h`.

```
#import "FNetmera.h"
#import "FNetmeraService.h"
#import "NetmeraFlutterSdkPlugin.h"
```

5) If you want to use Android alike message sending from iOS to dart please consider to shape your AppDelegate class as following.

```
import UIKit
import Flutter

//This function is needed for sending messages to the dart side. (Setting the callback function)
func registerPlugins(registry: FlutterPluginRegistry) {
    GeneratedPluginRegistrant.register(with: registry)
};

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate,UNUserNotificationCenterDelegate,NetmeraPushDelegate {

    override func application(_ application: UIApplication,
                didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

        if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self
    } else {
        // Fallback on earlier versions
    };

        //For triggering onPushReceive when app is killed and push clicked by user
        let notification = launchOptions?[.remoteNotification]
        if notification != nil {
            FNetmeraService.handleWork(ON_PUSH_RECEIVE, dict:["userInfo" : notification])
        }

    //This function is needed for sending messages to the dart side.
    NetmeraFlutterSdkPlugin.setPluginRegistrantCallback(registerPlugins)

    FNetmera.logging(true) // Enable Netmera logging
    FNetmera.initNetmera("<YOUR-NETMERA-KEY>") //Initializing Netmera packages.
    FNetmera.setPushDelegate(self)
    Netmera.setAppGroupName("group.com.netmera.flutter") // Your app group name

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }


    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        FNetmeraService.handleWork(ON_PUSH_REGISTER, dict: ["pushToken": deviceToken])
    }

    override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        FNetmeraService.handleWork(ON_PUSH_RECEIVE, dict:["userInfo" : userInfo])
    }

    @available(iOS 10.0, *)
    override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([UNNotificationPresentationOptions.alert])
        
        if UIApplication.shared.applicationState == .active {
            FNetmeraService.handleWork(ON_PUSH_RECEIVE, dict:["userInfo" : notification.request.content.userInfo])
        } else {
            FNetmeraService.handleWork(ON_PUSH_RECEIVE_BACKGROUND, dict:["userInfo" : notification.request.content.userInfo])
        }
    }
}

```
For example if you trigger `FNetmeraService.handleWork(ON_PUSH_RECEIVE, dict:["userInfo" : userInfo])` from AppDelegate, in the dart part the following method will be triggered.
```
void _onPushReceive(Map<dynamic, dynamic> bundle) async {
  print("onPushReceive: $bundle");
}
```

6) In order to use iOS10 Media Push, follow the instructions in [Netmera Product Hub.](https://developer.netmera.com/en/IOS/Push-Notifications#using-ios10-media-push) Differently, you should add the pods to the top of the `Podfile` as below.

```
// For receiving Media Push, you must add Netmera pods to top of your Podfile.
pod "Netmera", "3.24.9"
pod "Netmera/NotificationServiceExtension", "3.24.9"
pod "Netmera/NotificationContentExtension", "3.24.9"
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

void initBroadcastReceiver() {
  NetmeraPushBroadcastReceiver receiver = new NetmeraPushBroadcastReceiver();
  receiver.initialize(
    onPushRegister: _onPushRegister,
    onPushReceive: _onPushReceive,
    onPushDismiss: _onPushDismiss,
    onPushOpen: _onPushOpen,
    onPushButtonClicked: _onPushButtonClicked,
    onCarouselObjectSelected: _onCarouselObjectSelected
  );
}
```

2) If you have custom Firebase Messaging integration, please see usage below.

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

3) If you have custom Huawei Messaging integration, please see usage below.

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

void backgroundMessageCallback(RemoteMessage remoteMessage) async {
  Map<String, String> map = remoteMessage.dataOfMap ?? new Map();
  if (Netmera.isNetmeraRemoteMessage(map)) {
    Netmera.onNetmeraHuaweiPushMessageReceived(remoteMessage.from, map);
  }
}
```


### Calling Dart methods

##### Update User Example

```
updateUser() {
    NetmeraUser user = new NetmeraUser();
    user.setUserId(userController.text);
    user.setName(nameController.text);
    user.setSurname(surnameController.text);
    user.setEmail(emailController.text);
    user.setMsisdn(msisdnController.text);
    user.setGender(int.parse(_selectedGender));
    Netmera.updateUser(user);
  }
```

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
 Netmera.requestPushNotificationAuthorization();
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

Please explore example project for detailed information.