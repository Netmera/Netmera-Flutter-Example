///
/// Copyright (c) 2022 Inomera Research.
///

import 'package:netmera_flutter_sdk/NetmeraUser.dart';

class MyNetmeraUser extends NetmeraUser {
  late int _haircolor;
  int getHairColor() => _haircolor;

  setHairColor(int value) {
    _haircolor = value;
  }

  @override
  Map<String, Object?> toJson() {
    Map<String, Object?> map = super.toJson();
    map['peb'] = _haircolor;
    return map;
  }
}
