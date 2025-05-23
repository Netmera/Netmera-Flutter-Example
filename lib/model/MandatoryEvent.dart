import 'package:netmera_flutter_sdk/events/NetmeraEvent.dart';

class MandatoryEvent extends NetmeraEvent{

    final String _EVENT_CODE = "xzzoe";

    final List<bool> _booelenattrMandatorytrueArray;
    final double _doubleattrMandatorytrue;
    final int _longattrMandatorytrue;
    final DateTime _timestampMandatorytrue;
    final String _nameMandatorytrue;
    List<DateTime>? _dateAttrMandatoryfalseArray;
    List<String>? _surnameMandatoryfalseArray;
    int? _ageMandotoryfalse;

    MandatoryEvent({
        required List<bool> booelenattrMandatorytrueArray,
        required double doubleattrMandatorytrue,
        required int longattrMandatorytrue,
        required DateTime timestampMandatorytrue,
        required String nameMandatorytrue,
    }) : _booelenattrMandatorytrueArray = booelenattrMandatorytrueArray,
         _doubleattrMandatorytrue = doubleattrMandatorytrue,
         _longattrMandatorytrue = longattrMandatorytrue,
         _timestampMandatorytrue = timestampMandatorytrue,
         _nameMandatorytrue = nameMandatorytrue;

    void setDateAttrMandatoryfalseArray(List<DateTime> dateAttrMandatoryfalseArray) {
        _dateAttrMandatoryfalseArray = dateAttrMandatoryfalseArray;
    }
    void setSurnameMandatoryfalseArray(List<String> surnameMandatoryfalseArray) {
        _surnameMandatoryfalseArray = surnameMandatoryfalseArray;
    }
    void setAgeMandotoryfalse(int ageMandotoryfalse) {
        _ageMandotoryfalse = ageMandotoryfalse;
    }

    @override
    String getCode() {
        return _EVENT_CODE;
    }

    @override
    Map<String, dynamic> toJson() {
        return {
            ...super.toJson(),
            'fg': _booelenattrMandatorytrueArray,
            'fi': _dateAttrMandatoryfalseArray,
            'el': _doubleattrMandatorytrue,
            'fq': _longattrMandatorytrue,
            'gb': _timestampMandatorytrue,
            'ea': _nameMandatorytrue,
            'eb': _surnameMandatoryfalseArray,
            'ec': _ageMandotoryfalse,
        };
    }
}