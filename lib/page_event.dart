///
/// Copyright (c) 2022 Inomera Research.
///

import 'package:flutter/material.dart';

import 'package:netmera_flutter_sdk/Netmera.dart';
import 'package:netmera_flutter_sdk/events/NetmeraEventLogin.dart';
import 'package:netmera_flutter_sdk/events/NetmeraEventRegister.dart';
import 'package:netmera_flutter_sdk/events/commerce/NetmeraEventCartView.dart';
import 'package:netmera_flutter_sdk/events/commerce/NetmeraEventPurchase.dart';
import 'package:netmera_flutter_sdk/events/commerce/NetmeraLineItem.dart';

import 'package:netmera_flutter_example/model/MyNetmeraEvent.dart';

class EventPage extends StatefulWidget {
  const EventPage({Key? key}) : super(key: key);

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  emptyAction() {}

  void sendLoginEvent() {
    NetmeraEventLogin loginEvent = NetmeraEventLogin();
    loginEvent.setUserId("TestUserId");
    Netmera.sendEvent(loginEvent);
  }

  void sendRegisterEvent() {
    NetmeraEventRegister registerEvent = NetmeraEventRegister();
    Netmera.sendEvent(registerEvent);
  }

  void sendViewCartEvent() {
    NetmeraEventCartView cartViewEvent = NetmeraEventCartView();
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

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          child: const Text('Login Event'),
          onPressed: sendLoginEvent,
        ),
        ElevatedButton(
          child: const Text('Register Event'),
          onPressed: sendRegisterEvent,
        ),
        ElevatedButton(
          child: const Text('View Cart Event'),
          onPressed: sendViewCartEvent,
        ),
        ElevatedButton(
          child: const Text('Purchase Event'),
          onPressed: sendPurchaseEvent,
        ),
        ElevatedButton(
          child: const Text('Custom Test Event'),
          onPressed: sendTestEvent,
        ),
      ],
    );
  }
}
