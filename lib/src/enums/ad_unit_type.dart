enum AdUnitType {
  appOpen,
  interstitial,
  rewarded,
  rewardedInterstitial,
}

extension AdUnitTypeExtension on AdUnitType {
  String get value => name;
}
