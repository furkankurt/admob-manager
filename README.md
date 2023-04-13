# Admob Manager Flutter

This is a customized package of [Easy Ads Flutter](https://pub.dev/packages/easy_ads_flutter) package.

## Features

- Google Mobile Ads (banner, appOpen, interstitial, rewarded ad)

## Platform Specific Setup

### iOS

#### Update your Info.plist

Update your app's `ios/Runner/Info.plist` file to add two keys:

```xml
<key>GADApplicationIdentifier</key>
<string>YOUR_SDK_KEY</string>
```

- You have to add `SKAdNetworkItems` for all networks provided by admob-manager [info.plist](https://github.com/furkankurt/admob-manager/blob/master/example/ios/Runner/Info.plist) you can copy paste `SKAdNetworkItems` in your own project.

### Android

#### Update AndroidManifest.xml

```xml
<manifest>
    <application>
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy"/>
    </application>
</manifest>
```

## Initialize Ad Ids

```dart
import 'dart:io';

import 'package:admob_manager_flutter/admob_manager_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class TestAdIdManager extends IAdIdManager {
  const TestAdIdManager();

  @override
  AppAdIds? get admobAdIds => AppAdIds(
    appId: Platform.isAndroid
        ? 'ca-app-pub-3940256099942544~3347511713'
        : 'ca-app-pub-3940256099942544~1458002511',
    appOpenId: Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/3419835294'
        : 'ca-app-pub-3940256099942544/5662855259',
    bannerId: 'ca-app-pub-3940256099942544/6300978111',
    interstitialId: 'ca-app-pub-3940256099942544/1033173712',
    rewardedId: 'ca-app-pub-3940256099942544/5224354917',
  );
}
```

## Initialize the SDK

Before loading ads, have your app initialize the Mobile Ads SDK by calling `AdmobManager.instance.initialize()` which initializes the SDK and returns a `Future` that finishes once initialization is complete (or after a 30-second timeout). This needs to be done only once, ideally right before running the app.

```dart
import 'package:admob_manager_flutter/admob_manager_flutter.dart';
import 'package:flutter/material.dart';

const IAdIdManager adIdManager = TestAdIdManager();

AdmobManager.instance.initialize(
    adIdManager,
    adMobAdRequest: const AdRequest(),
    // Set true if you want to show age restricted (age below 16 years) ads for applovin
    isAgeRestrictedUserForApplovin: true,
    // To enable Facebook Test mode ads
    fbTestMode: true,
    admobConfiguration: RequestConfiguration(testDeviceIds: [
      '072D2F3992EF5B4493042ADC632CE39F', // Mi Phone
      '00008030-00163022226A802E',
    ]),
  );
```

## Interstitial/Rewarded Ads

### Load an ad

Ad is automatically loaded after being displayed or first time when you call initialize.
But on safe side, you can call this method. This will load both rewarded and interstitial ads.
If a particular ad is already loaded, it will not load it again.

```dart
AdmobManager.instance.loadAd();
```

### Show interstitial or rewarded ad

```dart
AdmobManager.instance.showAd(AdUnitType.rewarded);
```

### Show random interstitial ad

```dart
AdmobManager.instance.showRandomAd(AdUnitType.interstitial)
```

### Show appOpen ad

```dart
AdmobManager.instance.showAd(AdUnitType.appOpen)
```

## Show Banner Ads

This is how you may show banner ad in widget-tree somewhere:

```dart
@override
Widget build(BuildContext context) {
  Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SomeWidget(),
      const Spacer(),
      AdmobBannerAdWidget(adSize: AdSize.mediumRectangle),
    ],
  );
}
```

## Listening to the callbacks

Declare this object in the class

```dart
  StreamSubscription? _streamSubscription;
```

We are showing InterstitialAd here and also checking if ad has been shown.
If `true`, we are canceling the subscribed callbacks, if any.
Then, we are listening to the Stream and accessing the particular event we need

```dart
if (AdmobManager.instance.showInterstitialAd()) {
  // Canceling the last callback subscribed
  _streamSubscription?.cancel();
  // Listening to the callback from showInterstitialAd()
  _streamSubscription =
  AdmobManager.instance.onEvent.listen((event) {
    if (event.adUnitType == AdUnitType.interstitial &&
        event.type == AdEventType.adDismissed) {
      _streamSubscription?.cancel();
      goToNextScreen(countryList[index]);
    }
  });
}
```