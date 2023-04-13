import 'dart:async';

import 'package:admob_manager_flutter/admob_manager_flutter.dart';
import 'package:logger/logger.dart';

/// [AdmobLogger] is used to listen to the callbacks in stream & show logs
class AdmobLogger {
  /// [Logger] is used to show logs in console for [AdmobManager]
  final _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );
  StreamSubscription? streamSubscription;

  void enable(bool enabled) {
    streamSubscription?.cancel();
    if (enabled) {
      streamSubscription = AdmobManager.instance.onEvent.listen(_onAdEvent);
    }
  }

  void logInfo(String message) => _logger.i(message);

  void _onAdNetworkInitialized(AdEvent event) {
    if (event.data == true) {
      _logger.i("AdMob has been initialized and is ready to use.");
    } else {
      _logger.e("AdMob could not be initialized.");
    }
  }

  void _onAdLoaded(AdEvent event) {
    _logger.i("${event.adUnitType?.value} ads for AdMob have been loaded.");
  }

  void _onAdFailedToLoad(AdEvent event) {
    _logger.e(
        "${event.adUnitType?.value} ads for AdMob could not be loaded.\nERROR: ${event.error}");
  }

  void _onAdShowed(AdEvent event) {
    _logger.i("${event.adUnitType?.value} ad for AdMob has been shown.");
  }

  void _onAdFailedShow(AdEvent event) {
    _logger.e(
        "${event.adUnitType?.value} ad for AdMob could not be showed.\nERROR: ${event.error}");
  }

  void _onAdDismissed(AdEvent event) {
    _logger.i("${event.adUnitType?.value} ad for AdMob has been dismissed.");
  }

  void _onEarnedReward(AdEvent event) {
    final dataMap = event.data as Map<String, dynamic>?;
    _logger.i(
        "User has earned ${dataMap?['rewardAmount']} of ${dataMap?['rewardType']} from AdMob");
  }

  void _onAdEvent(AdEvent event) {
    switch (event.type) {
      case AdEventType.adNetworkInitialized:
        _onAdNetworkInitialized(event);
        break;
      case AdEventType.adLoaded:
        _onAdLoaded(event);
        break;
      case AdEventType.adDismissed:
        _onAdDismissed(event);
        break;
      case AdEventType.adShowed:
        _onAdShowed(event);
        break;
      case AdEventType.adFailedToLoad:
        _onAdFailedToLoad(event);
        break;
      case AdEventType.adFailedToShow:
        _onAdFailedShow(event);
        break;
      case AdEventType.earnedReward:
        _onEarnedReward(event);
        break;
    }
  }
}
