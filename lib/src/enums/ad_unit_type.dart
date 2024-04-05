enum AdUnitType {
  appOpen,
  banner,
  interstitial,
  rewarded,
  native,
  rewardedInterstitial,
}

extension AdUnitTypeExtension on AdUnitType {
  String get value => name;
}
