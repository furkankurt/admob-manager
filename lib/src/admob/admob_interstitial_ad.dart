import 'package:admob_manager_flutter/src/ad_base.dart';
import 'package:admob_manager_flutter/src/enums/ad_unit_type.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdmobInterstitialAd extends AdBase {
  final AdRequest _adRequest;
  final bool _immersiveModeEnabled;

  AdmobInterstitialAd(
    super.adUnitId,
    this._adRequest,
    this._immersiveModeEnabled,
  );

  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;

  @override
  AdUnitType get adUnitType => AdUnitType.interstitial;

  @override
  bool get isAdLoaded => _isAdLoaded;

  @override
  void dispose() {
    _isAdLoaded = false;
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }

  @override
  Future<void> load() async {
    if (_isAdLoaded) return;

    await InterstitialAd.load(
        adUnitId: adUnitId,
        request: _adRequest,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
            _isAdLoaded = true;
            onAdLoaded?.call(adUnitType, ad);
          },
          onAdFailedToLoad: (LoadAdError error) {
            _interstitialAd = null;
            _isAdLoaded = false;
            onAdFailedToLoad?.call(adUnitType, error, error.toString());
          },
        ));
  }

  @override
  show() {
    final ad = _interstitialAd;
    if (ad == null) return;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) {
        onAdShowed?.call(adUnitType, ad);
      },
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        onAdDismissed?.call(adUnitType, ad);

        ad.dispose();
        load();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        onAdFailedToShow?.call(adUnitType, ad, error.toString());

        ad.dispose();
        load();
      },
    );
    ad.setImmersiveMode(_immersiveModeEnabled);
    ad.show();
    _interstitialAd = null;
    _isAdLoaded = false;
  }
}
