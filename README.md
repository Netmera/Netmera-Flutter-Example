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
        jcenter()
        maven {url 'http://developer.huawei.com/repo/'}
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:4.1.3'
        classpath 'com.google.gms:google-services:4.3.5'
        classpath 'com.huawei.agconnect:agcp:1.4.2.300'
    }
}

allprojects {
    repositories {
        google()
        jcenter()
        maven { url 'https://maven.google.com'}
        maven {url 'http://developer.huawei.com/repo/'}
    }
}
```

4) In your app's build gradle file, add the following dependency.

```

 dependencies {
 
     implementation 'androidx.core:core:1.1.0'
     
 }
```

5) Add the following into the bottom of app's buid.gradle file

```
apply plugin: 'com.google.gms.google-services'
```

6) Create an application class as shown below.

- Your Application class must extends `FlutterApplication`.

``` 
    public class NMApp extends FlutterApplication {
    
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


7) Register Application class into manifest file.

```
 <application
        android:name=".NMApp"
        android:label="netmera_flutter_sdk_example"
        android:icon="@mipmap/ic_launcher">
        
        ...
        ..
        .
```



8) Inside dart class add the following

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

9) If you have custom Firebase Messaging integration, please see usage below.

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
```
10) If you have custom Huawei Messaging integration, please see usage below.

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

### Setup - iOS Part

1) Navigate to ios folder in your terminal and run the following command.

```
$ pod install
```

2) If you are using Swift, enter the following in your `Runner-Bridging-Header.h`.

```
#import "FNetmera.h"
#import "FNetmeraService.h"
#import "NetmeraFlutterSdkPlugin.h"
```

3) If you want to use Android alike message sending from iOS to dart please consider to shape your AppDelegate class as following.

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
            self.application(application, didReceiveRemoteNotification: notification as! [AnyHashable : Any])
        }

    //This function is needed for sending messages to the dart side.
    NetmeraFlutterSdkPlugin.setPluginRegistrantCallback(registerPlugins)

    FNetmera.logging(true) // Enable Netmera logging
    FNetmera.initNetmera("<YOUR-NETMERA-KEY>") //Initializing Netmera packages.
    FNetmera.setPushDelegate(self) //

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }


    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        FNetmeraService.handleWork(ON_PUSH_REGISTER, dict: ["pushToken": deviceToken])
    }

    override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        FNetmeraService.handleWork(ON_PUSH_RECEIVE, dict:["userInfo" : userInfo])
    }


    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler:
        @escaping () -> Void) {

        if response.actionIdentifier == UNNotificationDismissActionIdentifier {
            FNetmeraService.handleWork(ON_PUSH_DISMISS,dict:["userInfo" : response.notification.request.content.userInfo])
        }
        else if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            FNetmeraService.handleWork(ON_PUSH_OPEN, dict:["userInfo" : response.notification.request.content.userInfo])
        }
        completionHandler()
    }

    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([UNNotificationPresentationOptions.alert])
    }
}

```
For example if you trigger `FNetmeraService.handleWork(ON_PUSH_RECEIVE, dict:["userInfo" : userInfo])` from AppDelegate, in the dart part the following method will be triggered.
```
void _onPushReceive(Map<dynamic, dynamic> bundle) async {
  print("onPushReceive: $bundle");
}
```
Please take a look at `Setup-Android part 8`


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

  void sendPurchaseEvent() {
    NetmeraLineItem netmeraLineItem = NetmeraLineItem();
    netmeraLineItem.setBrandId("TestBrandID");
    netmeraLineItem.setBrandName("TestBrandName");
    netmeraLineItem.setCampaignId("TestCampaignID");
    netmeraLineItem.setCategoryIds(["TestCategoryID1", "TestCategoryID2"]);
    netmeraLineItem.setCategoryNames(
        ["TestCategoryName1", "TestCategoryName2", "TestCategoryName3"]);
    netmeraLineItem.setKeywords(["keyword1", "keyword2", "keyword3"]);
    netmeraLineItem.setCount(12);
    netmeraLineItem.setId("TestItemID");
    netmeraLineItem.setPrice(130);

    // CustomPurchaseEvent extends PurchaseEvent
    CustomPurchaseEvent purchaseEvent = CustomPurchaseEvent();
    // Set default attributes
    purchaseEvent.setCoupon("Test_Coupon");
    purchaseEvent.setDiscount(10);
    purchaseEvent.setItemCount(2);
    purchaseEvent.setPaymentMethod("Credit Card");
    purchaseEvent.setSubTotal(260.89);
    purchaseEvent.setShippingCost(0.0);
    purchaseEvent.setLineItems([netmeraLineItem, netmeraLineItem]);

    // Set custom attributes
    purchaseEvent.setInstallment("test installment");
    Netmera.sendEvent(purchaseEvent);
  }
  
  void sendTestEvent() {
    //Custom event
    TestEvent testEvent = TestEvent();
    testEvent.setNo(3); //Custom attribute
    Netmera.sendEvent(testEvent);
  }
```
##### Netmera Inbox Examples

```
 String _currentStatus = Netmera.PUSH_OBJECT_STATUS_ALL.toString();
  String _count = "0";
  List<NetmeraPushInbox> _pushInboxList = List.empty(growable: true);

  List<DropdownMenuItem<String>> getInboxList() {
    List<DropdownMenuItem<String>> items = List.empty(growable: true);
    items.add(DropdownMenuItem(value: Netmera.PUSH_OBJECT_STATUS_ALL.toString(), child: const Text("ALL")));
    items.add(DropdownMenuItem(value: Netmera.PUSH_OBJECT_STATUS_READ.toString(), child: const Text("READ")));
    items.add(DropdownMenuItem(value: Netmera.PUSH_OBJECT_STATUS_UNREAD.toString(), child: const Text("UNREAD")));
    items.add(DropdownMenuItem(value: Netmera.PUSH_OBJECT_STATUS_DELETED.toString(), child: const Text("DELETED")));
    return items;
  }

  onInboxStatusChanged(String status) {
    setState(() {
      _currentStatus = status;
    });
  }

  String getStatusText(int status) {
    switch (status) {
      case Netmera.PUSH_OBJECT_STATUS_ALL:
        return "ALL";
      case Netmera.PUSH_OBJECT_STATUS_READ:
        return "READ";
      case Netmera.PUSH_OBJECT_STATUS_UNREAD:
        return "UNREAD";
      case Netmera.PUSH_OBJECT_STATUS_DELETED:
        return "DELETED";
    }
    return "";
  }

  fillInboxList(list) {
    setState(() {
      _pushInboxList = list;
    });
  }

  // Click Functions
  emptyAction() {}

  getInboxFilter() {
    NetmeraInboxFilter inboxFilter = NetmeraInboxFilter();
    inboxFilter.setPageSize(2);
    inboxFilter.setStatus(int.parse(_currentStatus));
    inboxFilter.setIncludeExpiredObjects(true);
    inboxFilter.setCategories(null);
    return inboxFilter;
  }

  fetchInbox() async {
    Netmera.fetchInbox(getInboxFilter()).then((list) {
      fillInboxList(list);
    }).catchError((error) {
      debugPrint(error);
    });
  }

  fetchNextPage() async {
    Netmera.fetchNextPage().then((list) {
      fillInboxList(list);
    }).catchError((error) {
      debugPrint(error);
    });
  }

  countForStatus() async {
    Netmera.countForStatus(int.parse(_currentStatus)).then((val) {
      setState(() {
        if (val != -1) {
          _count = val.toString();
        }
      });
    });
  }

  handlePushObject() async {
    if (_pushInboxList.isNotEmpty) {
      Netmera.handlePushObject(_pushInboxList[0].getPushId()!);
    }
  }

  handleInteractiveAction() async {
    if (_pushInboxList.isNotEmpty) {
      for (var element in _pushInboxList) {
        if (element.getInteractiveActions() != null && element.getInteractiveActions()!.isNotEmpty) {
          Netmera.handleInteractiveAction(element.getInteractiveActions()![0]);
          return;
        }
      }
    }
  }

  inboxUpdateStatus() {
    List<String> selectedPushList = List.empty(growable: true);
    if (_pushInboxList.length > 1) {
      selectedPushList.add(_pushInboxList[0].getPushId()!);
      selectedPushList.add(_pushInboxList[1].getPushId()!);
    }
    int status = Netmera.PUSH_OBJECT_STATUS_UNREAD;
    Netmera.inboxUpdateStatus(selectedPushList, status).then((netmeraError) {
      if (netmeraError != null) {
        debugPrint(netmeraError);
      }
    }).catchError((error) {
      debugPrint(error);
    });
  }

  updateAll() async {
    if (_pushInboxList.isNotEmpty) {
      var updateStatus = int.parse(_currentStatus);
      if (updateStatus == Netmera.PUSH_OBJECT_STATUS_ALL) {
        debugPrint("Please select different status than all!!");
        return;
      }

      Netmera.updateAll(updateStatus).then((netmeraError) {
        fetchInbox();
      }).catchError((error) {
        debugPrint(error);
      });
    }
  }

  inboxCountForStatus() async {
    NMInboxStatusCountFilter filter = NMInboxStatusCountFilter();
    filter.setStatus(int.parse(_currentStatus));
    filter.setIncludeExpired(true);
    Netmera.getInboxCountForStatus(filter).then((map) {
      String countStatusText = "ALL: " +
          map[Netmera.PUSH_OBJECT_STATUS_ALL.toString()].toString() +
          ", " +
          "READ: " +
          map[Netmera.PUSH_OBJECT_STATUS_READ.toString()].toString() +
          ", " +
          "UNREAD: " +
          map[Netmera.PUSH_OBJECT_STATUS_UNREAD.toString()].toString() +
          ", " +
          "DELETED: " +
          map[Netmera.PUSH_OBJECT_STATUS_DELETED.toString()].toString();
      setState(() {
        _count = countStatusText;
      });
    }).catchError((error) {
      debugPrint(error);
    });
  }
```

##### Netmera Inbox Category Examples

```
 String _currentStatus = Netmera.PUSH_OBJECT_STATUS_ALL.toString();
  List<dynamic> _categoryList = List.empty(growable: true);

  List<DropdownMenuItem<String>> getCategoryStatusList() {
    List<DropdownMenuItem<String>> items = List.empty(growable: true);
    items.add(DropdownMenuItem(value: Netmera.PUSH_OBJECT_STATUS_ALL.toString(), child: const Text("ALL")));
    items.add(DropdownMenuItem(value: Netmera.PUSH_OBJECT_STATUS_READ.toString(), child: const Text("READ")));
    items.add(DropdownMenuItem(value: Netmera.PUSH_OBJECT_STATUS_UNREAD.toString(), child: const Text("UNREAD")));
    items.add(DropdownMenuItem(value: Netmera.PUSH_OBJECT_STATUS_DELETED.toString(), child: const Text("DELETED")));
    return items;
  }

  onCategoryStatusChanged(String status) {
    setState(() {
      _currentStatus = status;
    });
  }

  String getStatusText(int status) {
    switch (status) {
      case Netmera.PUSH_OBJECT_STATUS_ALL:
        return "ALL";
      case Netmera.PUSH_OBJECT_STATUS_READ:
        return "READ";
      case Netmera.PUSH_OBJECT_STATUS_UNREAD:
        return "UNREAD";
      case Netmera.PUSH_OBJECT_STATUS_DELETED:
        return "DELETED";
    }
    return "";
  }

  // Click Functions
  emptyAction() {}

  getCategoryFilter() {
    NetmeraCategoryFilter categoryFilter = NetmeraCategoryFilter();
    categoryFilter.setPageSize(2);
    categoryFilter.setStatus(int.parse(_currentStatus));
    categoryFilter.setIncludeExpiredObjects(true);
    return categoryFilter;
  }

  fetchCategory() async {
    Netmera.fetchCategory(getCategoryFilter()).then((list) {
      fillCategoryList(list);
    }).catchError((error) {
      debugPrint(error);
    });
  }

  fetchNextCategoryPage() async {
    Netmera.fetchNextCategory().then((list) {
      fillCategoryList(list);
    }).catchError((error) {
      debugPrint(error);
    });
  }

  fillCategoryList(list) {
    setState(() {
      _categoryList = list;
    });
  }

  handleLastMessage() async {
    if (_categoryList.isNotEmpty) {
      Netmera.handleLastMessage(_categoryList[0]);
    }
  }

  updateStatusCategories() async {
    if (_categoryList.isNotEmpty) {
      List<String> selectedCategories = List.empty(growable: true);
      if (_categoryList.length == 1) {
        selectedCategories.add(_categoryList[0].getCategoryName()!);
      } else if (_categoryList.length > 1) {
        selectedCategories.add(_categoryList[0].getCategoryName()!);
        selectedCategories.add(_categoryList[1].getCategoryName()!);
      }

      Netmera.updateStatusByCategories(Netmera.PUSH_OBJECT_STATUS_READ, selectedCategories).then((netmeraError) {
        fetchCategory();
      }).catchError((error) {
        debugPrint(error);
      });
    }
  }

  getUserCategoryPreferenceList() async {
    Netmera.getUserCategoryPreferenceList().then((list) {
      fillCategoryList(list);
    }).catchError((error) {
      debugPrint(error);
    });
  }

  setUserCategoryPreference(NetmeraCategoryPreference item) async {
    Netmera.setUserCategoryPreference(item.getCategoryId()!, !item.getOptInStatus()!).then((value) {
      debugPrint("Successfully set user category preference list");
    }).catchError((error) {
      debugPrint(error);
    });
  }
```

##### Netmera Getting ExternalId (if exists before)

```
    Netmera.getCurrentExternalId()
```


For detailed information please explore example folder in the Netmera sdk library.



