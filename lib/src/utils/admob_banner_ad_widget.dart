import 'package:admob_manager_flutter/admob_manager_flutter.dart';
import 'package:admob_manager_flutter/src/ad_base.dart';
import 'package:admob_manager_flutter/src/utils/badged_banner.dart';
import 'package:flutter/material.dart';

class AdmobBannerAdWidget extends StatefulWidget {
  final AdSize adSize;
  const AdmobBannerAdWidget({
    this.adSize = AdSize.banner,
    super.key,
  });

  @override
  State<AdmobBannerAdWidget> createState() => _AdmobBannerAdWidgetState();
}

class _AdmobBannerAdWidgetState extends State<AdmobBannerAdWidget> {
  AdBase? _bannerAd;

  @override
  Widget build(BuildContext context) {
    if (AdmobManager.instance.showAdBadge) {
      return BadgedBanner(child: _bannerAd?.show(), adSize: widget.adSize);
    }

    return _bannerAd?.show() ?? const SizedBox();
  }

  @override
  void didUpdateWidget(covariant AdmobBannerAdWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    createBanner();
    _bannerAd?.onBannerAdReadyForSetState = onBannerAdReadyForSetState;
  }

  void createBanner() {
    _bannerAd = AdmobManager.instance.createBanner(adSize: widget.adSize);
    _bannerAd?.load();
  }

  @override
  void initState() {
    super.initState();

    createBanner();

    _bannerAd?.onAdLoaded = onBannerAdReadyForSetState;
  }

  @override
  void dispose() {
    super.dispose();
    _bannerAd?.dispose();
    _bannerAd = null;
  }

  void onBannerAdReadyForSetState(AdUnitType adUnitType, Object? data) {
    setState(() {});
  }
}
