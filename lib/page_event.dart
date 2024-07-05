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

import 'main.dart';

class EventPage extends StatefulWidget {
  const EventPage({Key? key}) : super(key: key);

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  TextEditingController revenueController = TextEditingController();

  void sendLoginEvent() {
    NetmeraEventLogin loginEvent = NetmeraEventLogin();
    loginEvent.setUserId("TestUserId");
    if (revenueController.text != '') {
      var revenue = double.parse(revenueController.text);
      loginEvent.setRevenue(revenue);
    }
    Netmera.sendEvent(loginEvent);
  }

  void sendRegisterEvent() {
    NetmeraEventRegister registerEvent = NetmeraEventRegister();
    if (revenueController.text != '') {
      var revenue = double.parse(revenueController.text);
      registerEvent.setRevenue(revenue);
    }
    Netmera.sendEvent(registerEvent);
  }

  void sendViewCartEvent() {
    NetmeraEventCartView cartViewEvent = NetmeraEventCartView();
    cartViewEvent.setItemCount(3);
    cartViewEvent.setSubTotal(15.99);
    if (revenueController.text != '') {
      var revenue = double.parse(revenueController.text);
      cartViewEvent.setRevenue(revenue);
    }
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
    if (revenueController.text != '') {
      var revenue = double.parse(revenueController.text);
      purchaseEvent.setRevenue(revenue);
    }
    Netmera.sendEvent(purchaseEvent);
  }

  void sendTestEvent() {
    //Custom event
    NetmeraEventContentRate testEvent = NetmeraEventContentRate();
    testEvent.setNo(3); //Custom attribute
    if (revenueController.text != '') {
      var revenue = double.parse(revenueController.text);
      testEvent.setRevenue(revenue);
    }
    Netmera.sendEvent(testEvent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Events"),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 50.0, right: 50.0, bottom: 20),
              child: TextField(
                controller: revenueController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Revenue'),
              ),
            ),
            button('Login Event', sendLoginEvent),
            button('Register Event', sendRegisterEvent),
            button('View Cart Event', sendViewCartEvent),
            button('Purchase Event', sendPurchaseEvent),
            button('Custom Test Event', sendTestEvent),
          ],
        )
    );
  }
}
