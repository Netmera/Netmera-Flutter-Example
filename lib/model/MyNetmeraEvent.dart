///
/// Copyright (c) 2022 Inomera Research.
///

import 'package:netmera_flutter_sdk/events/commerce/NetmeraEventPurchase.dart';
import 'package:netmera_flutter_sdk/events/media/NetmeraEventContentRate.dart';

class TestEvent extends NetmeraEventContentRate {
  @override
  getCode() => "prc";

  late int _no;

  setNo(int no) {
    _no = no;
  }

  int getNo() => _no;

  @override
  Map<String, Object?> toJson() {
    Map<String, Object?> map = super.toJson();
    map['ec'] = _no;
    return map;
  }
}

class CustomPurchaseEvent extends NetmeraEventPurchase{

  @override
  getCode() => "jrs";

  late String _installment;

  setInstallment(String installment) {
    _installment = installment;
  }

  String getInstallment() => _installment;

  @override
  Map<String, Object?> toJson() {
    Map<String, Object?> map = super.toJson();
    map['ea'] = _installment;
    return map;
  }
}
