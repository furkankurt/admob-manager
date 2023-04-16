import 'package:flutter/foundation.dart';

enum AdUnitType {
  appOpen,
  interstitial,
  rewarded,
  rewardedInterstitial,
}

extension AdUnitTypeExtension on AdUnitType {
  String get value => describeEnum(this);
}
