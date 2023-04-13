import 'dart:async';
import 'dart:io';

import 'package:admob_manager_flutter/admob_manager_flutter.dart';
import 'package:flutter/material.dart';

const IAdIdManager adIdManager = TestAdIdManager();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AdmobManager.instance.initialize(
    adIdManager,
    adMobAdRequest: const AdRequest(),
    admobConfiguration: RequestConfiguration(testDeviceIds: []),
    showAdBadge: Platform.isIOS,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Admob Manager Ads Example',
      home: CountryListScreen(),
    );
  }
}

class CountryListScreen extends StatefulWidget {
  const CountryListScreen({Key? key}) : super(key: key);

  @override
  State<CountryListScreen> createState() => _CountryListScreenState();
}

class _CountryListScreenState extends State<CountryListScreen> {
  /// Using it to cancel the subscribed callbacks
  StreamSubscription? _streamSubscription;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ad Network List"),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'AppOpen',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium!
                    .copyWith(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
              AdButton(
                networkName: 'Admob AppOpen',
                onTap: () => _showAd(AdUnitType.appOpen),
              ),
              const Divider(thickness: 2),
              Text(
                'Interstitial',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium!
                    .copyWith(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
              AdButton(
                networkName: 'Admob Interstitial',
                onTap: () => _showAd(AdUnitType.interstitial),
              ),
              AdButton(
                networkName: 'Available Interstitial',
                onTap: () => _showAvailableAd(AdUnitType.interstitial),
              ),
              const Divider(thickness: 2),
              Text(
                'Rewarded',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium!
                    .copyWith(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
              AdButton(
                networkName: 'Admob Rewarded',
                onTap: () => _showAd(AdUnitType.rewarded),
              ),
              AdButton(
                networkName: 'Available Rewarded',
                onTap: () => _showAvailableAd(AdUnitType.rewarded),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAd(AdUnitType adUnitType) {
    if (AdmobManager.instance.showAd(adUnitType,
        shouldShowLoader: Platform.isAndroid,
        context: context,
        delayInSeconds: 1)) {
      // Canceling the last callback subscribed
      _streamSubscription?.cancel();
      // Listening to the callback from showRewardedAd()
      _streamSubscription = AdmobManager.instance.onEvent.listen((event) {
        if (event.adUnitType == adUnitType) {
          _streamSubscription?.cancel();
          goToNextScreen();
        }
      });
    } else {
      goToNextScreen();
    }
  }

  void _showAvailableAd(AdUnitType adUnitType) {
    if (AdmobManager.instance.showAd(adUnitType)) {
      // Canceling the last callback subscribed
      _streamSubscription?.cancel();
      // Listening to the callback from showRewardedAd()
      _streamSubscription = AdmobManager.instance.onEvent.listen((event) {
        if (event.adUnitType == adUnitType) {
          _streamSubscription?.cancel();
          goToNextScreen();
        }
      });
    } else {
      goToNextScreen();
    }
  }

  void goToNextScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CountryDetailScreen(),
      ),
    );
  }
}

class CountryDetailScreen extends StatefulWidget {
  const CountryDetailScreen({Key? key}) : super(key: key);

  @override
  State<CountryDetailScreen> createState() => _CountryDetailScreenState();
}

class _CountryDetailScreenState extends State<CountryDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('United States'),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 200,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                    'https://cdn.britannica.com/33/4833-050-F6E415FE/Flag-United-States-of-America.jpg'),
              ),
            ),
          ),
          const AdmobBannerAdWidget(
            adSize: AdSize.largeBanner,
          ),
          const Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'The U.S. is a country of 50 states covering a vast swath of North America, with Alaska in the northwest and Hawaii extending the nation’s presence into the Pacific Ocean. Major Atlantic Coast cities are New York, a global finance and culture center, and capital Washington, DC. Midwestern metropolis Chicago is known for influential architecture and on the west coast, Los Angeles\' Hollywood is famed for filmmaking',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AdButton extends StatelessWidget {
  final String networkName;
  final VoidCallback onTap;
  const AdButton({Key? key, required this.onTap, required this.networkName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            networkName,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w300),
          ),
        ),
      ),
    );
  }
}
