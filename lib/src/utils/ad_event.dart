import 'package:admob_manager_flutter/src/enums/ad_event_type.dart';
import 'package:admob_manager_flutter/src/enums/ad_unit_type.dart';

/// [AdEvent] is used to pass data inside event streams in [AdmobManager] ads instance
/// You can use this to distinguish between different event types and each event type has a data attached to it.
class AdEvent {
  final AdEventType type;
  final AdUnitType? adUnitType;

  /// Any custom data along with the event
  final Object? data;

  /// In case of [AdEventType.adFailedToLoad] & [AdEventType.adFailedToShow] or in any error case
  final String? error;

  AdEvent({
    required this.type,
    this.adUnitType,
    this.data,
    this.error,
  });
}
