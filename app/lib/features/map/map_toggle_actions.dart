import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../l10n/generated/app_localizations.dart';

/// Shared toggle handlers for the map settings sheet — extracted out of
/// `MapScreen` so they have exactly one implementation regardless of which
/// widget surfaces the control.
Future<void> toggleLiveGps(BuildContext context, WidgetRef ref, bool currentlyLive) async {
  if (currentlyLive) {
    ref.read(currentPositionControllerProvider.notifier).disableLiveGps();
    ref.read(useLiveGpsProvider.notifier).state = false;
    return;
  }

  final granted = await ref.read(currentPositionControllerProvider.notifier).enableLiveGps();
  if (granted) {
    ref.read(useLiveGpsProvider.notifier).state = true;
  } else if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).locationPermissionDenied)),
    );
  }
}

Future<void> toggleVoiceTrigger(BuildContext context, WidgetRef ref, bool currentlyEnabled) async {
  final controller = ref.read(voiceTriggerControllerProvider);
  if (currentlyEnabled) {
    controller.stop();
    ref.read(voiceTriggerEnabledProvider.notifier).state = false;
    return;
  }

  final started = await controller.start();
  if (started) {
    ref.read(voiceTriggerEnabledProvider.notifier).state = true;
  } else if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).speechUnavailable)),
    );
  }
}

void toggleFallDetection(WidgetRef ref, bool currentlyEnabled) {
  final controller = ref.read(fallDetectionControllerProvider.notifier);
  if (currentlyEnabled) {
    controller.stop();
  } else {
    controller.start();
  }
  ref.read(fallDetectionEnabledProvider.notifier).state = !currentlyEnabled;
}

/// Report mode and route-plan mode both capture the map's `onTap` for their
/// own purpose, so only one may be active at a time — turning one on turns
/// the other off (and clears any in-progress route, since leaving route mode
/// implies abandoning it).
void toggleReportMode(WidgetRef ref, bool currentlyEnabled) {
  final next = !currentlyEnabled;
  ref.read(reportModeProvider.notifier).state = next;
  if (next) ref.read(routePlanModeProvider.notifier).state = false;
}

void toggleRoutePlanMode(WidgetRef ref, bool currentlyEnabled) {
  final next = !currentlyEnabled;
  ref.read(routePlanModeProvider.notifier).state = next;
  if (next) {
    ref.read(reportModeProvider.notifier).state = false;
  } else {
    ref.read(routePlanResultProvider.notifier).state = null;
  }
}
