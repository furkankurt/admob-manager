import 'package:admob_manager_flutter/admob_manager_flutter.dart';
import 'package:admob_manager_flutter/src/ad_base.dart';
import 'package:flutter/material.dart';

class AdmobNativeAd extends AdBase {
  final AdRequest _adRequest;
  final NativeTemplateStyle? style;
  final NativeAdOptions? nativeAdOptions;
  final BoxConstraints? constraints;

  AdmobNativeAd(
    String adUnitId, {
    this.style,
    this.nativeAdOptions,
    this.constraints,
    AdRequest? adRequest,
  })  : _adRequest = adRequest ?? const AdRequest(),
        super(adUnitId);

  NativeAd? _nativeAd;
  bool _isAdLoaded = false;

  @override
  AdUnitType get adUnitType => AdUnitType.native;

  @override
  void dispose() {
    _isAdLoaded = false;
    _nativeAd?.dispose();
    _nativeAd = null;
  }

  @override
  bool get isAdLoaded => _isAdLoaded;

  @override
  Future<void> load() async {
    await _nativeAd?.dispose();
    _nativeAd = null;
    _isAdLoaded = false;

    _nativeAd = NativeAd(
      nativeTemplateStyle: style ??
          NativeTemplateStyle(
            // Required: Choose a template.
            templateType: TemplateType.medium,
            // Optional: Customize the ad's style.
            mainBackgroundColor: Colors.purple,
            cornerRadius: 10.0,
            callToActionTextStyle: NativeTemplateTextStyle(
                textColor: Colors.cyan,
                backgroundColor: Colors.red,
                style: NativeTemplateFontStyle.monospace,
                size: 16.0),
            primaryTextStyle: NativeTemplateTextStyle(
                textColor: Colors.red,
                backgroundColor: Colors.cyan,
                style: NativeTemplateFontStyle.italic,
                size: 16.0),
            secondaryTextStyle: NativeTemplateTextStyle(
                textColor: Colors.green,
                backgroundColor: Colors.black,
                style: NativeTemplateFontStyle.bold,
                size: 16.0),
            tertiaryTextStyle: NativeTemplateTextStyle(
                textColor: Colors.brown,
                backgroundColor: Colors.amber,
                style: NativeTemplateFontStyle.normal,
                size: 16.0),
          ),
      adUnitId: adUnitId,
      listener: NativeAdListener(
        onAdLoaded: (Ad ad) {
          _nativeAd = ad as NativeAd?;
          _isAdLoaded = true;
          onAdLoaded?.call(adUnitType, ad);
          onNativeAdReadyForSetState?.call(adUnitType, ad);
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          _nativeAd = null;
          _isAdLoaded = false;
          onAdFailedToLoad?.call(adUnitType, ad, error.toString());
          ad.dispose();
        },
        onAdOpened: (Ad ad) => onAdClicked?.call(adUnitType, ad),
        onAdClosed: (Ad ad) => onAdDismissed?.call(adUnitType, ad),
        onAdImpression: (Ad ad) => onAdShowed?.call(adUnitType, ad),
      ),
      request: _adRequest,
      nativeAdOptions: nativeAdOptions,
    );
    _nativeAd?.load();
  }

  @override
  dynamic show() {
    if (_nativeAd == null || _isAdLoaded == false) {
      load();
      return const SizedBox();
    }

    // Small template
    final smallAdContainer = ConstrainedBox(
      constraints: constraints ??
          const BoxConstraints(
            minWidth: 320, // minimum recommended width
            minHeight: 90, // minimum recommended height
            maxWidth: 400,
            maxHeight: 200,
          ),
      child: AdWidget(ad: _nativeAd!),
    );

// Medium template
    final mediumAdContainer = ConstrainedBox(
      constraints: constraints ??
          const BoxConstraints(
            minWidth: 320, // minimum recommended width
            minHeight: 320, // minimum recommended height
            maxWidth: 400,
            maxHeight: 400,
          ),
      child: AdWidget(ad: _nativeAd!),
    );
    return mediumAdContainer;
  }
}
