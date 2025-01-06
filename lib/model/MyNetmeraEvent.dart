///
/// Copyright (c) 2022 Inomera Research.
///

import 'package:netmera_flutter_sdk/events/NetmeraEvent.dart';
import 'package:netmera_flutter_sdk/events/commerce/NetmeraEventPurchase.dart';

class NetmeraEventContentRate extends NetmeraEvent {
  final String _EVENT_CODE = "jjnam";
  
  late int _no;

  setNo(int no) {
    _no = no;
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = super.toJson();
    map['ec'] = _no;
    return map;
  }

  @override
  String getCode() {
    return _EVENT_CODE;
  }
}

class CustomPurchaseEvent extends NetmeraEventPurchase {
  final String _EVENT_CODE = "qwthb";

  @override
  String getCode() {
    return _EVENT_CODE;
  }

  late String _installment;

  setInstallment(String installment) {
    _installment = installment;
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = super.toJson();
    map['ea'] = _installment;
    return map;
  }
}
