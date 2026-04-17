import 'package:flutter/material.dart';
import 'package:netmera_flutter_sdk/Netmera.dart';
import 'package:netmera_flutter_sdk/events/NetmeraEventLogin.dart';
import 'package:netmera_flutter_sdk/events/NetmeraEventRegister.dart';
import 'package:netmera_flutter_sdk/events/commerce/NetmeraEventCartView.dart';
import 'package:netmera_flutter_sdk/events/commerce/NetmeraEventPurchase.dart';
import 'package:netmera_flutter_sdk/events/commerce/NetmeraLineItem.dart';

import 'model/MyNetmeraEvent.dart';

///
/// Copyright (c) 2026 Netmera Research.
///
class EventPage extends StatefulWidget {
  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  TextEditingController revenueController = TextEditingController();

  void sendLoginEvent() {
    NetmeraEventLogin loginEvent = NetmeraEventLogin();
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

  void purchaseEvent() {
    NetmeraLineItem netmeraLineItem = NetmeraLineItem();
    netmeraLineItem.setBrandId("brandId12");
    netmeraLineItem.setBrandName("brandNameInomera");
    netmeraLineItem.setCampaignId("campaignId1223");
    netmeraLineItem.setCategoryIds(["categoryIds1", "categoryIds2"]);
    netmeraLineItem.setCategoryNames(["categoryNames1", "categoryNames2", "categoryNames3"]);
    netmeraLineItem.setKeywords(["keyword1", "keyword2", "keyword3"]);
    netmeraLineItem.setCount(12);
    netmeraLineItem.setId("Id123123");
    netmeraLineItem.setPrice(130);

    NetmeraEventPurchase purchaseEvent = NetmeraEventPurchase();
    purchaseEvent.setCoupon("INOMERACODE");
    purchaseEvent.setDiscount(10);
    purchaseEvent.setItemCount(2);
    purchaseEvent.setPaymentMethod("Credit Card");
    purchaseEvent.setSubTotal(260.89);
    purchaseEvent.setShippingCost(0.0);
    purchaseEvent.setLineItems([netmeraLineItem, netmeraLineItem]);
    if (revenueController.text != '') {
      var revenue = double.parse(revenueController.text);
      purchaseEvent.setRevenue(revenue);
    }
    Netmera.sendEvent(purchaseEvent);
  }

  void sendTestEvent() {
    TestEvent testEvent = TestEvent();
    testEvent.setDateAttribute(DateTime.now());
    testEvent.setNo(123);
    if (revenueController.text != '') {
      var revenue = double.parse(revenueController.text);
      testEvent.setRevenue(revenue);
    }
    Netmera.sendEvent(testEvent);
  }

  void sendGenericEvent() {
    Netmera.sendGenericEvent('srpxy', {
      'productId': '123',
      'amount': 99.99,
      'timestamp': DateTime.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
          onPressed: purchaseEvent,
        ),
        ElevatedButton(
          child: const Text('Custom Test Event'),
          onPressed: sendTestEvent,
        ),
        ElevatedButton(
          child: const Text('Generic Event'),
          onPressed: sendGenericEvent,
        ),
      ],
    );
  }
}
