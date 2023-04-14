import 'package:admob_manager_flutter/admob_manager_flutter.dart';
import 'package:admob_manager_flutter/src/ad_base.dart';
import 'package:flutter/material.dart';

class AdmobNativeAdWidget extends StatefulWidget {
  final NativeTemplateStyle style;
  final NativeAdOptions? options;
  final BoxConstraints? constraints;
  const AdmobNativeAdWidget({
    required this.style,
    this.options,
    this.constraints,
    Key? key,
  }) : super(key: key);

  @override
  State<AdmobNativeAdWidget> createState() => _AdmobNativeAdWidgetState();
}

class _AdmobNativeAdWidgetState extends State<AdmobNativeAdWidget> {
  AdBase? _nativeAd;

  @override
  Widget build(BuildContext context) {
    return _nativeAd?.show() ?? const SizedBox();
  }

  @override
  void didUpdateWidget(covariant AdmobNativeAdWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    createNative();
    _nativeAd?.onNativeAdReadyForSetState = onNativeAdReadyForSetState;
  }

  void createNative() {
    _nativeAd = AdmobManager.instance.createNative(
      style: widget.style,
      options: widget.options,
      constraints: widget.constraints,
    );
    _nativeAd?.load();
  }

  @override
  void initState() {
    super.initState();

    createNative();

    _nativeAd?.onAdLoaded = onNativeAdReadyForSetState;
  }

  @override
  void dispose() {
    super.dispose();
    _nativeAd?.dispose();
    _nativeAd = null;
  }

  void onNativeAdReadyForSetState(AdUnitType adUnitType, Object? data) {
    setState(() {});
  }
}
