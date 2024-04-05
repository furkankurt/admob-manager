import 'package:admob_manager_flutter/admob_manager_flutter.dart';
import 'package:admob_manager_flutter/src/ad_base.dart';

class AdmobRewardedIntAd extends AdBase {
  final AdRequest _adRequest;
  final bool _immersiveModeEnabled;

  AdmobRewardedIntAd(
    super.adUnitId,
    this._adRequest,
    this._immersiveModeEnabled,
  );

  RewardedInterstitialAd? _rewardedIntAd;
  bool _isAdLoaded = false;

  @override
  AdUnitType get adUnitType => AdUnitType.rewardedInterstitial;

  @override
  bool get isAdLoaded => _isAdLoaded;

  @override
  void dispose() {
    _isAdLoaded = false;
    _rewardedIntAd?.dispose();
    _rewardedIntAd = null;
  }

  @override
  Future<void> load() async {
    if (_isAdLoaded) return;
    await RewardedInterstitialAd.load(
        adUnitId: adUnitId,
        request: _adRequest,
        rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
            onAdLoaded: (RewardedInterstitialAd ad) {
          _rewardedIntAd = ad;
          _isAdLoaded = true;
          onAdLoaded?.call(adUnitType, ad);
        }, onAdFailedToLoad: (LoadAdError error) {
          _rewardedIntAd = null;
          _isAdLoaded = false;
          onAdFailedToLoad?.call(adUnitType, error, error.toString());
        }));
  }

  @override
  dynamic show() {
    final ad = _rewardedIntAd;
    if (ad == null) return;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedInterstitialAd ad) {
        onAdShowed?.call(adUnitType, ad);
      },
      onAdDismissedFullScreenContent: (RewardedInterstitialAd ad) {
        onAdDismissed?.call(adUnitType, ad);

        ad.dispose();
        load();
      },
      onAdFailedToShowFullScreenContent:
          (RewardedInterstitialAd ad, AdError error) {
        onAdFailedToShow?.call(adUnitType, ad, error.toString());

        ad.dispose();
        load();
      },
    );

    ad.setImmersiveMode(_immersiveModeEnabled);
    ad.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      onEarnedReward?.call(adUnitType, reward.type, reward.amount);
    });
    _rewardedIntAd = null;
    _isAdLoaded = false;
  }
}
