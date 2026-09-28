import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/algorithms/route_planner.dart';
import '../core/models/emergency_contact.dart';
import '../core/models/emergency_facility.dart';
import '../core/models/hotspot.dart';
import '../core/models/panic_event.dart';
import '../core/models/simulated_dispatch_entry.dart';
import '../core/services/alert_feedback_controller.dart';
import '../data/routing/osrm_routing_service.dart';
import 'package:latlong2/latlong.dart';

import 'app_services.dart';
import 'current_position_controller.dart';
import 'fall_detection_controller.dart';
import 'geofence_ui_controller.dart';
import 'locale_controller.dart';
import 'onboarding_controller.dart';
import 'voice_trigger_controller.dart';

final appServicesProvider = Provider<AppServices>((ref) => AppServices());

/// Overridden in `main.dart` with the real instance before `runApp` — reading
/// it before that override is wired up is a programming error, not a
/// recoverable state, hence the throw rather than a nullable fallback.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main.dart');
});

final localeControllerProvider = StateNotifierProvider<LocaleController, Locale?>((ref) {
  return LocaleController(ref.watch(sharedPreferencesProvider));
});

final onboardingSeenControllerProvider = StateNotifierProvider<OnboardingController, bool>((ref) {
  return OnboardingController(ref.watch(sharedPreferencesProvider));
});

final hotspotsProvider = StreamProvider<List<Hotspot>>((ref) {
  return ref.watch(appServicesProvider).hotspotRepository.watchAll();
});

final facilitiesProvider = StreamProvider<List<EmergencyFacility>>((ref) {
  return ref.watch(appServicesProvider).facilityRepository.watchAll();
});

final contactsProvider = StreamProvider<List<EmergencyContact>>((ref) {
  final services = ref.watch(appServicesProvider);
  return services.contactRepository.watchForUser(services.currentUserId);
});

final simulatedDispatchLogProvider = StreamProvider<List<SimulatedDispatchEntry>>((ref) {
  return ref.watch(appServicesProvider).simulatedDispatchLog.watchAll();
});

final panicEventsProvider = StreamProvider<List<PanicEvent>>((ref) {
  return ref.watch(appServicesProvider).panicEventRepository.watchAll();
});

/// Whether the animated crime heatmap overlay is shown — purely visual, on
/// by default.
final showHeatmapProvider = StateProvider<bool>((ref) => true);

/// Whether tapping the map sets a route destination (FR-RT's simulated safe
/// routing) instead of doing nothing. Off by default so a stray tap never
/// surprises the user with a route appearing.
final routePlanModeProvider = StateProvider<bool>((ref) => false);

/// The most recently computed route, or null if none has been planned yet /
/// it was cleared.
final routePlanResultProvider = StateProvider<RoutePlanResult?>((ref) => null);

/// True while a route request is in flight (the OSRM road-snapping call) —
/// drives a loading indicator so tapping the map doesn't look unresponsive.
final isPlanningRouteProvider = StateProvider<bool>((ref) => false);

final osrmRoutingServiceProvider = Provider<OsrmRoutingService>((ref) {
  final service = OsrmRoutingService();
  ref.onDispose(service.dispose);
  return service;
});

/// Whether tapping the map drops a new hotspot pin (an explicit, discoverable
/// alternative to the long-press gesture, which testing showed nobody finds
/// on their own). Mutually exclusive with [routePlanModeProvider] — see
/// `QuickActionsBar`.
final reportModeProvider = StateProvider<bool>((ref) => false);

/// Which sustained alert style (real device vibration vs. looped ringtone)
/// the geofence and fall-detection countdowns use. Defaults to vibration —
/// user-togglable, never `HapticFeedback`'s short click either way.
final alertStyleProvider = StateProvider<AlertStyle>((ref) => AlertStyle.vibration);

final alertFeedbackControllerProvider = Provider<AlertFeedbackController>((ref) {
  final controller = AlertFeedbackController();
  ref.onDispose(controller.stop);
  return controller;
});

final geofenceUiControllerProvider =
    StateNotifierProvider<GeofenceUiController, ActiveGeofenceAlert?>((ref) {
  final services = ref.watch(appServicesProvider);
  return GeofenceUiController(
    panicController: services.panicController,
    alertFeedback: ref.watch(alertFeedbackControllerProvider),
    alertStyle: () => ref.read(alertStyleProvider),
  );
});

final currentPositionControllerProvider =
    StateNotifierProvider<CurrentPositionController, LatLng>((ref) {
  return CurrentPositionController(ref.watch(appServicesProvider));
});

/// Tracks purely whether the user has opted into real GPS, for the app bar
/// toggle's display — kept separate from [currentPositionControllerProvider]
/// because flipping this happens synchronously on button press, while that
/// provider's state only updates once a position (real or reset-to-preview)
/// actually lands.
final useLiveGpsProvider = StateProvider<bool>((ref) => false);

/// Mirrors [useLiveGpsProvider]'s pattern: flips synchronously on button
/// press, independent of [fallDetectionControllerProvider]'s `state` (which
/// only changes once a countdown actually starts/ticks/ends, not when the
/// sensor subscription itself starts or stops).
final fallDetectionEnabledProvider = StateProvider<bool>((ref) => false);

final voiceTriggerEnabledProvider = StateProvider<bool>((ref) => false);

final voiceTriggerControllerProvider = Provider<VoiceTriggerController>((ref) {
  // Plain Provider (not StateNotifierProvider), so ref.onDispose here is the
  // only cleanup hook — unlike the StateNotifierProviders above, there's no
  // built-in auto-dispose to conflict with.
  final controller = VoiceTriggerController(ref.watch(appServicesProvider).panicController);
  ref.onDispose(controller.stop);
  return controller;
});

final fallDetectionControllerProvider =
    StateNotifierProvider<FallDetectionController, ActiveFallAlert?>((ref) {
  // No manual ref.onDispose here — StateNotifierProvider already calls
  // dispose() on its notifier automatically; adding a second call caused a
  // "set state after dispose" assertion failure (state_notifier's
  // _debugIsMounted check) the first time this was wired up.
  return FallDetectionController(
    panicController: ref.watch(appServicesProvider).panicController,
    alertFeedback: ref.watch(alertFeedbackControllerProvider),
    alertStyle: () => ref.read(alertStyleProvider),
  );
});
