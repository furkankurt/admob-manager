import 'package:admob_manager_flutter/admob_manager_flutter.dart';
import 'package:admob_manager_flutter/src/ad_base.dart';

class AdmobAppOpenAd extends AdBase {
  final AdRequest _adRequest;

  AdmobAppOpenAd(super.adUnitId, this._adRequest);
  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;

  @override
  AdUnitType get adUnitType => AdUnitType.appOpen;

  @override
  bool get isAdLoaded => _appOpenAd != null;

  @override
  void dispose() {
    _appOpenAd?.dispose();
    _appOpenAd = null;
  }

  @override
  Future<void> load() {
    if (isAdLoaded) return Future.value();

    return AppOpenAd.load(
      adUnitId: adUnitId,
      request: _adRequest,
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (AppOpenAd ad) {
          _appOpenAd = ad;
          onAdLoaded?.call(adUnitType, ad);
        },
        onAdFailedToLoad: (LoadAdError error) {
          _appOpenAd = null;
          onAdFailedToLoad?.call(adUnitType, error, error.toString());
        },
      ),
    );
  }

  @override
  show() async {
    if (!isAdLoaded) {
      await load();
      return;
    }

    if (_isShowingAd) {
      onAdFailedToShow?.call(
          adUnitType, null, 'Tried to show ad while already showing an ad.');
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (AppOpenAd ad) {
        _isShowingAd = true;

        onAdShowed?.call(adUnitType, ad);
      },
      onAdDismissedFullScreenContent: (AppOpenAd ad) {
        _isShowingAd = false;

        onAdDismissed?.call(adUnitType, ad);
        ad.dispose();
        _appOpenAd = null;
        load();
      },
      onAdFailedToShowFullScreenContent: (AppOpenAd ad, AdError error) {
        _isShowingAd = false;

        onAdFailedToShow?.call(adUnitType, ad, error.toString());

        ad.dispose();
        _appOpenAd = null;
        load();
      },
    );

    _appOpenAd!.show();
    _appOpenAd = null;
    _isShowingAd = false;
  }
}
