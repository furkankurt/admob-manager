abstract class IAdIdManager {
  const IAdIdManager();

  /// Pass null if you wish not to implement admob ads
  ///
  /// AppAdIds? get admobAdIds => null;
  AppAdIds? get admobAdIds;
}

class AppAdIds {
  /// App Id should never be null, if there is no app id for a particular ad network, leave it empty
  final String appId;

  /// if id is null, it will not be implemented
  final String? appOpenId;

  /// if id is null, it will not be implemented
  final String? interstitialId;

  /// if id is null, it will not be implemented
  final String? rewardedInterstitialId;

  /// if id is null, it will not be implemented
  final String? rewardedId;

  /// if id is null, it will not be implemented
  final String? bannerId;

  /// if id is null, it will not be implemented
  final String? nativeId;

  const AppAdIds({
    required this.appId,
    this.appOpenId,
    this.interstitialId,
    this.rewardedInterstitialId,
    this.rewardedId,
    this.bannerId,
    this.nativeId,
  });
}
