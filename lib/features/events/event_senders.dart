import 'package:netmera_flutter_example/model/MyNetmeraEvent.dart';
import 'package:netmera_flutter_sdk/Netmera.dart';
import 'package:netmera_flutter_sdk/events/NetmeraEvent.dart';
import 'package:netmera_flutter_sdk/events/NetmeraEventLogin.dart';
import 'package:netmera_flutter_sdk/events/NetmeraEventRegister.dart';
import 'package:netmera_flutter_sdk/events/commerce/NetmeraEventCartView.dart';
import 'package:netmera_flutter_sdk/events/commerce/NetmeraEventPurchase.dart';
import 'package:netmera_flutter_sdk/events/commerce/NetmeraLineItem.dart';

abstract final class EventSenders {
  /// "Use Generic Method" on the Events page; kept for the app session.
  static bool useGenericMethod = false;

  static void send(NetmeraEvent event) {
    if (useGenericMethod) {
      final attributes = event.toJson()..remove('code');
      Netmera.sendGenericEvent(event.getCode(), attributes);
    } else {
      Netmera.sendEvent(event);
    }
  }

  static void cartView() {
    send(
      NetmeraEventCartView()
        ..setItemCount(3)
        ..setSubTotal(15.99),
    );
  }

  static void purchase() {
    final lineItem = NetmeraLineItem()
      ..setBrandId('brandId12')
      ..setBrandName('brandNameInomera')
      ..setCampaignId('campaignId1223')
      ..setCategoryIds(['categoryIds1', 'categoryIds2'])
      ..setCategoryNames(['categoryNames1', 'categoryNames2', 'categoryNames3'])
      ..setKeywords(['keyword1', 'keyword2', 'keyword3'])
      ..setCount(12)
      ..setId('Id123123')
      ..setPrice(130);

    send(
      NetmeraEventPurchase()
        ..setCoupon('INOMERACODE')
        ..setDiscount(10)
        ..setItemCount(2)
        ..setPaymentMethod('Credit Card')
        ..setSubTotal(260.89)
        ..setShippingCost(0.0)
        ..setLineItems([lineItem, lineItem]),
    );
  }

  static void login() => send(NetmeraEventLogin());

  static void register() => send(NetmeraEventRegister());

  static void custom() {
    send(
      TestEvent()
        ..setDateAttribute(DateTime.now())
        ..setNo(123),
    );
  }
}
