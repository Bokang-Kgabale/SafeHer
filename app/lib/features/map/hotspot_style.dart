import 'package:flutter/material.dart';

import '../../core/models/emergency_facility.dart';
import '../../core/models/hotspot.dart';
import '../../l10n/generated/app_localizations.dart';

IconData iconForCategory(HotspotCategory category) {
  switch (category) {
    case HotspotCategory.robbery:
      return Icons.money_off;
    case HotspotCategory.harassment:
      return Icons.record_voice_over;
    case HotspotCategory.assault:
      return Icons.warning_amber_rounded;
    case HotspotCategory.noLighting:
      return Icons.lightbulb_outline;
    case HotspotCategory.other:
      return Icons.report_problem_outlined;
  }
}

String labelForCategory(BuildContext context, HotspotCategory category) {
  final t = AppLocalizations.of(context);
  switch (category) {
    case HotspotCategory.robbery:
      return t.categoryRobbery;
    case HotspotCategory.harassment:
      return t.categoryHarassment;
    case HotspotCategory.assault:
      return t.categoryAssault;
    case HotspotCategory.noLighting:
      return t.categoryNoLighting;
    case HotspotCategory.other:
      return t.categoryOther;
  }
}

IconData iconForFacility(FacilityType type) {
  switch (type) {
    case FacilityType.police:
      return Icons.local_police;
    case FacilityType.hospital:
      return Icons.local_hospital;
    case FacilityType.clinic:
      return Icons.medical_services;
  }
}

Color colorForFacility(FacilityType type) {
  switch (type) {
    case FacilityType.police:
      return Colors.blue.shade700;
    case FacilityType.hospital:
      return Colors.green.shade700;
    case FacilityType.clinic:
      return Colors.teal.shade700;
  }
}
