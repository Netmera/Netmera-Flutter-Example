import 'package:netmera_flutter_sdk/NetmeraProfileAttribute.dart';
import 'package:netmera_flutter_sdk/NetmeraUserProfile.dart';

///
/// Copyright (c) 2026 Netmera Research.
///

class MyNetmeraUserProfile extends NetmeraUserProfile {
  final NetmeraProfileAttributeCollection<int> luckyNumbers = NetmeraProfileAttributeCollection<int>();
  final NetmeraProfileAttribute<bool> isLuckyNumbersEnabled = NetmeraProfileAttribute<bool>();
  final NetmeraProfileAttribute<String> lastLoginPlatform = NetmeraProfileAttribute<String>();

  @override
  Map<String, dynamic> getChangesPayload() {
    final payload = super.getChangesPayload();
    if (luckyNumbers.hasPendingChanges) payload['is'] = luckyNumbers.getOperations();
    if (isLuckyNumbersEnabled.hasPendingChanges) payload['qr'] = isLuckyNumbersEnabled.getOperations();
    if (lastLoginPlatform.hasPendingChanges) payload['ya'] = lastLoginPlatform.getOperations();
    return payload;
  }
}
