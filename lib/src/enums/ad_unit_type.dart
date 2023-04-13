import 'package:flutter/foundation.dart';

enum AdUnitType {
  appOpen,
  banner,
  interstitial,
  rewarded,
  native,
  rewardedInterstitial,
}

extension AdUnitTypeExtension on AdUnitType {
  String get value => describeEnum(this);
}
