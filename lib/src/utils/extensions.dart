import 'package:admob_manager_flutter/src/ad_base.dart';
import 'package:admob_manager_flutter/src/enums/ad_unit_type.dart';

extension AdBaseListExtension on List<AdBase> {
  bool doesNotContain(AdUnitType type) =>
      indexWhere((e) => e.adUnitType == type) == -1;
}
