import 'package:netmera_flutter_sdk/events/NetmeraEvent.dart';
import 'package:netmera_flutter_sdk/events/commerce/NetmeraEventPurchase.dart';

///
/// Copyright (c) 2026 Netmera Research.
///

/// Custom event class (SDK example).
class TestEvent extends NetmeraEvent {

    final String _EVENT_CODE = "prc";

    DateTime? _dateAttribute;
    int? _no;


    void setDateAttribute(DateTime dateAttribute) {
        _dateAttribute = dateAttribute;
    }
    void setNo(int no) {
        _no = no;
    }

    @override
    String getCode() {
        return _EVENT_CODE;
    }

    @override
    Map<String, dynamic> toJson() {
        return {
            ...super.toJson(),
            'fi': _dateAttribute,
            'ec': _no,
        };
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
