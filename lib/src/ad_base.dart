import 'package:admob_manager_flutter/src/enums/ad_unit_type.dart';

abstract class AdBase {
  final String adUnitId;

  /// This will be called for initialization when we don't have to wait for the initialization
  AdBase(this.adUnitId);

  AdUnitType get adUnitType;
  bool get isAdLoaded;

  void dispose();

  /// This will load ad, It will only load the ad if isAdLoaded is false
  Future<void> load();
  dynamic show();

  AdCallback? onAdLoaded;
  AdCallback? onAdShowed;
  AdCallback? onAdClicked;
  AdFailedCallback? onAdFailedToLoad;
  AdFailedCallback? onAdFailedToShow;
  AdCallback? onAdDismissed;
  AdEarnedReward? onEarnedReward;
}

typedef AdNetworkInitialized = void Function(bool isInitialized, Object? data);
typedef AdFailedCallback = void Function(
    AdUnitType adUnitType, Object? data, String errorMessage);
typedef AdCallback = void Function(AdUnitType adUnitType, Object? data);
typedef AdEarnedReward = void Function(
    AdUnitType adUnitType, String? rewardType, num? rewardAmount);
