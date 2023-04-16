abstract class IAdIdManager {
  /// App Id should never be null, if there is no app id for a particular ad network, leave it empty
   String get appId;

  /// if id is null, it will not be implemented
   String get appOpenId;

  /// if id is null, it will not be implemented
   String get interstitialId;

  /// if id is null, it will not be implemented
   String get rewardedInterstitialId;

  /// if id is null, it will not be implemented
   String get rewardedId;

  /// if id is null, it will not be implemented
   String get bannerId;

  /// if id is null, it will not be implemented
   String get nativeId;
}
