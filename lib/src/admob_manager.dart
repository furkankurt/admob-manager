import 'dart:async';
import 'dart:io';

import 'package:admob_manager_flutter/admob_manager_flutter.dart';
import 'package:admob_manager_flutter/src/ad_base.dart';
import 'package:admob_manager_flutter/src/admob/admob_interstitial_ad.dart';
import 'package:admob_manager_flutter/src/admob/admob_native_ad.dart';
import 'package:admob_manager_flutter/src/admob/admob_rewarded_ad.dart';
import 'package:admob_manager_flutter/src/admob/admob_rewarded_int_ad.dart';
import 'package:admob_manager_flutter/src/utils/ad_event_controller.dart';
import 'package:admob_manager_flutter/src/utils/admob_logger.dart';
import 'package:admob_manager_flutter/src/utils/auto_hiding_loader_dialog.dart';
import 'package:admob_manager_flutter/src/utils/extensions.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class AdmobManager {
  AdmobManager._admobManager();
  static final AdmobManager instance = AdmobManager._admobManager();

  /// Google admob's ad request
  AdRequest _adRequest = const AdRequest();
  late final IAdIdManager adIdManager;
  late AppLifecycleReactor _appLifecycleReactor;

  final _eventController = AdEventController();
  Stream<AdEvent> get onEvent => _eventController.onEvent;

  List<AdBase> get _allAds => [
        ..._interstitialAds,
        ..._rewardedAds,
        ..._rewardedInterstitialAds,
      ];

  /// All the interstitial ads will be stored in it
  final List<AdBase> _appOpenAds = [];

  /// All the interstitial ads will be stored in it
  final List<AdBase> _interstitialAds = [];

  /// All the rewarded ads will be stored in it
  final List<AdBase> _rewardedAds = [];

  /// All the rewarded ads will be stored in it
  final List<AdBase> _rewardedInterstitialAds = [];

  /// [_logger] is used to show Ad logs in the console
  final AdmobLogger _logger = AdmobLogger();

  /// On banner, ad badge will appear
  bool get showAdBadge => _showAdBadge;
  bool _showAdBadge = false;

  /// Initializes the Google Mobile Ads SDK.
  ///
  /// Call this method as early as possible after the app launches
  /// [adMobAdRequest] will be used in all the admob requests. By default empty request will be used if nothing passed here.
  /// [fbTestingId] can be obtained by running the app once without the testingId.
  Future<void> initialize(
    IAdIdManager manager, {
    AdRequest? adMobAdRequest,
    RequestConfiguration? admobConfiguration,
    bool enableLogger = true,
    int appOpenAdOrientation = AppOpenAd.orientationPortrait,
    bool showAdBadge = false,
  }) async {
    _showAdBadge = showAdBadge;
    if (enableLogger) _logger.enable(enableLogger);
    adIdManager = manager;
    if (adMobAdRequest != null) {
      _adRequest = adMobAdRequest;
    }

    if (admobConfiguration != null) {
      MobileAds.instance.updateRequestConfiguration(admobConfiguration);
    }

    final admobAdId = manager.admobAdIds?.appId;
    if (admobAdId != null && admobAdId.isNotEmpty) {
      if (Platform.isIOS) {
        final appTrackingTransparencyStatus =
            await AppTrackingTransparency.requestTrackingAuthorization();
        final uuid = await AppTrackingTransparency.getAdvertisingIdentifier();

        _logger.logInfo(
            'AppTrackingTransparency status: ${appTrackingTransparencyStatus.name}'
            ', advertisingIdentifier (UUID): $uuid');
      }

      final response = await MobileAds.instance.initialize();
      final status = response.adapterStatuses.values.firstOrNull?.state;

      _eventController.fireNetworkInitializedEvent(
          status == AdapterInitializationState.ready);

      // Initializing admob Ads
      await AdmobManager.instance._initAdmob(
        appOpenAdUnitId: manager.admobAdIds?.appOpenId,
        interstitialAdUnitId: manager.admobAdIds?.interstitialId,
        rewardedInterstitialAdUnitId:
            manager.admobAdIds?.rewardedInterstitialId,
        rewardedAdUnitId: manager.admobAdIds?.rewardedId,
        appOpenAdOrientation: appOpenAdOrientation,
      );
    }
  }

  /// Returns [AdBase] if ad is created successfully. It assumes that you have already assigned banner id in Ad Id Manager
  ///
  /// if [adNetwork] is provided, only that network's ad would be created. For now, only unity and admob banner is supported
  /// [adSize] is used to provide ad banner size
  AdBase? createBanner({AdSize adSize = AdSize.banner}) {
    AdBase? ad;
    final bannerId = adIdManager.admobAdIds?.bannerId;
    assert(bannerId != null,
        'You are trying to create a banner and Admob Banner id is null in ad id manager');
    if (bannerId != null) {
      ad = AdmobBannerAd(bannerId, adSize: adSize, adRequest: _adRequest);
      _eventController.setupEvents(ad);
    }
    return ad;
  }

  /// Returns [AdBase] if ad is created successfully. It assumes that you have already assigned banner id in Ad Id Manager
  ///
  /// if [adNetwork] is provided, only that network's ad would be created. For now, only unity and admob banner is supported
  /// [adSize] is used to provide ad banner size
  AdBase? createNative({
    required NativeTemplateStyle style,
    NativeAdOptions? options,
    BoxConstraints? constraints,
  }) {
    AdBase? ad;
    final nativeId = adIdManager.admobAdIds?.nativeId;
    assert(nativeId != null,
        'You are trying to create a native and Admob Native id is null in ad id manager');
    if (nativeId != null) {
      ad = AdmobNativeAd(
        nativeId,
        style: style,
        adRequest: _adRequest,
        constraints: constraints,
        nativeAdOptions: options,
      );
      _eventController.setupEvents(ad);
    }
    return ad;
  }

  Future<void> _initAdmob({
    String? appOpenAdUnitId,
    String? interstitialAdUnitId,
    String? rewardedInterstitialAdUnitId,
    String? rewardedAdUnitId,
    bool immersiveModeEnabled = true,
    int appOpenAdOrientation = AppOpenAd.orientationPortrait,
  }) async {
    // init interstitial ads
    if (interstitialAdUnitId != null &&
        _interstitialAds.doesNotContain(AdUnitType.interstitial)) {
      final ad = AdmobInterstitialAd(
          interstitialAdUnitId, _adRequest, immersiveModeEnabled);
      _interstitialAds.add(ad);
      _eventController.setupEvents(ad);

      await ad.load();
    }

    // init interstitial ads
    if (rewardedInterstitialAdUnitId != null &&
        _rewardedInterstitialAds
            .doesNotContain(AdUnitType.rewardedInterstitial)) {
      final ad = AdmobRewardedIntAd(
          rewardedInterstitialAdUnitId, _adRequest, immersiveModeEnabled);
      _rewardedInterstitialAds.add(ad);
      _eventController.setupEvents(ad);

      await ad.load();
    }

    // init rewarded ads
    if (rewardedAdUnitId != null &&
        _rewardedAds.doesNotContain(AdUnitType.rewarded)) {
      final ad =
          AdmobRewardedAd(rewardedAdUnitId, _adRequest, immersiveModeEnabled);
      _rewardedAds.add(ad);
      _eventController.setupEvents(ad);

      await ad.load();
    }

    if (appOpenAdUnitId != null &&
        _appOpenAds.doesNotContain(AdUnitType.appOpen)) {
      final appOpenAdManager =
          AdmobAppOpenAd(appOpenAdUnitId, _adRequest, appOpenAdOrientation);
      await appOpenAdManager.load();
      _appLifecycleReactor =
          AppLifecycleReactor(appOpenAdManager: appOpenAdManager);
      _appLifecycleReactor.listenToAppStateChanges();
      _appOpenAds.add(appOpenAdManager);
      _eventController.setupEvents(appOpenAdManager);
    }
  }

  /// Displays [adUnitType] ad from [adNetwork]. It will check if first ad it found from list is loaded,
  /// it will be displayed if [adNetwork] is not mentioned otherwise it will load the ad.
  ///
  /// Returns bool indicating whether ad has been successfully displayed or not
  ///
  /// [adUnitType] should be mentioned here, only interstitial or rewarded should be mentioned here
  /// if [adNetwork] is provided, only that network's ad would be displayed
  /// if [shouldShowLoader] before interstitial. If it's true, you have to provide build context.
  bool showAd(AdUnitType adUnitType,
      {bool shouldShowLoader = false,
      int delayInSeconds = 2,
      BuildContext? context}) {
    List<AdBase> ads = [];
    if (adUnitType == AdUnitType.rewarded) {
      ads = _rewardedAds;
    } else if (adUnitType == AdUnitType.interstitial) {
      ads = _interstitialAds;
    } else if (adUnitType == AdUnitType.rewardedInterstitial) {
      ads = _rewardedInterstitialAds;
    } else if (adUnitType == AdUnitType.appOpen) {
      ads = _appOpenAds;
    }

    // if (adNetwork != AdNetwork.any) {
    //   final ad = ads.firstWhereOrNull((e) => adNetwork == e.adNetwork);
    //   if (ad?.isAdLoaded == true) {
    //     if (ad?.adUnitType == AdUnitType.interstitial &&
    //         shouldShowLoader &&
    //         context != null) {
    //       showLoaderDialog(context, delay: delayInSeconds)
    //           .then((_) => ad?.show());
    //     } else {
    //       ad?.show();
    //     }
    //     return true;
    //   } else {
    //     _logger.logInfo(
    //         'AdMob ${ad?.adUnitType} was not loaded, so called loading');
    //     ad?.load();
    //     return false;
    //   }
    // }

    for (final ad in ads) {
      if (ad.isAdLoaded) {
        if ((ad.adUnitType == AdUnitType.interstitial ||
                ad.adUnitType == AdUnitType.rewardedInterstitial) &&
            shouldShowLoader &&
            context != null) {
          showLoaderDialog(context, delay: delayInSeconds)
              .then((_) => ad.show());
        } else {
          ad.show();
        }
        return true;
      } else {
        _logger.logInfo(
            'AdMob ${ad.adUnitType} was not loaded, so called loading');
        ad.load();
      }
    }

    return false;
  }

  /// This will load both rewarded and interstitial ads.
  /// If a particular ad is already loaded, it will not load it again.
  /// Also you do not have to call this method everytime. Ad is automatically loaded after being displayed.
  ///
  void loadAd() {
    for (final e in _rewardedAds) {
      e.load();
    }

    for (final e in _interstitialAds) {
      e.load();
    }

    for (final e in _rewardedInterstitialAds) {
      e.load();
    }
  }

  /// Returns bool indicating whether ad has been loaded
  ///
  bool isRewardedAdLoaded() {
    final ad = _rewardedAds.firstWhereOrNull((e) => e.isAdLoaded);
    return ad?.isAdLoaded ?? false;
  }

  /// Returns bool indicating whether ad has been loaded
  ///
  bool isInterstitialAdLoaded() {
    final ad = _interstitialAds.firstWhereOrNull((e) => e.isAdLoaded);
    return ad?.isAdLoaded ?? false;
  }

  /// Returns bool indicating whether ad has been loaded
  ///
  bool isRewardedInterstitialAdLoaded() {
    final ad = _rewardedInterstitialAds.firstWhereOrNull((e) => e.isAdLoaded);
    return ad?.isAdLoaded ?? false;
  }

  /// Do not call this method until unless you want to remove ads entirely from the app.
  /// Best user case for this method could be removeAds In app purchase.
  ///
  /// After this, ads would stop loading. You would have to call initialize again.
  ///
  /// if [adUnitType] is provided only that ad unit type will be disposed, otherwise it will be ignored
  void destroyAds({AdUnitType? adUnitType}) {
    for (final e in _allAds) {
      if (adUnitType == null || adUnitType == e.adUnitType) {
        e.dispose();
      }
    }
  }
}
