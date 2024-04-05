import 'package:admob_manager_flutter/src/ad_base.dart';
import 'package:admob_manager_flutter/src/enums/ad_unit_type.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdmobRewardedAd extends AdBase {
  final AdRequest _adRequest;
  final bool _immersiveModeEnabled;

  AdmobRewardedAd(
    super.adUnitId,
    this._adRequest,
    this._immersiveModeEnabled,
  );

  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;

  @override
  AdUnitType get adUnitType => AdUnitType.rewarded;

  @override
  bool get isAdLoaded => _isAdLoaded;

  @override
  void dispose() {
    _isAdLoaded = false;
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }

  @override
  Future<void> load() async {
    if (_isAdLoaded) return;
    await RewardedAd.load(
        adUnitId: adUnitId,
        request: _adRequest,
        rewardedAdLoadCallback:
            RewardedAdLoadCallback(onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          _isAdLoaded = true;
          onAdLoaded?.call(adUnitType, ad);
        }, onAdFailedToLoad: (LoadAdError error) {
          _rewardedAd = null;
          _isAdLoaded = false;
          onAdFailedToLoad?.call(adUnitType, error, error.toString());
        }));
  }

  @override
  dynamic show() {
    final ad = _rewardedAd;
    if (ad == null) return;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) {
        onAdShowed?.call(adUnitType, ad);
      },
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        onAdDismissed?.call(adUnitType, ad);

        ad.dispose();
        load();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        onAdFailedToShow?.call(adUnitType, ad, error.toString());

        ad.dispose();
        load();
      },
    );

    ad.setImmersiveMode(_immersiveModeEnabled);
    ad.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      onEarnedReward?.call(adUnitType, reward.type, reward.amount);
    });
    _rewardedAd = null;
    _isAdLoaded = false;
  }
}
