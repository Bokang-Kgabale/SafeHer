import '../models/panic_event.dart';
import '../util/scheduler_clock.dart';

enum GeofenceRawEvent { enter, exit }

enum GeofenceState { outside, entered, cooldown }

/// Per-hotspot debounced proximity state machine (SRS FR-GEO, Algorithm Test Plan §1).
///
/// Design notes:
/// - Debounces both entry and exit so GPS jitter near a boundary can't flap the alert.
/// - Countdown expiry is guarded by re-checking state at fire time, so an exit or a
///   False Alarm tap that happens after the timer is scheduled silently prevents it
///   from firing, without needing to explicitly cancel a platform Timer.
/// - Cooldown suppresses re-entry into the same hotspot for a period after any
///   resolution (false alarm or escalation), so a person lingering at the boundary
///   doesn't get re-alerted every time GPS nudges her back in.
class GeofenceAlertController {
  final SchedulerClock clock;
  final Duration debounce;
  final Duration countdownDuration;
  final Duration cooldownDuration;
  final void Function(PanicTrigger trigger, {required String hotspotId}) onPanicTrigger;
  final void Function(String hotspotId)? onVibrateAndCountdownStart;
  final void Function(String hotspotId)? onCountdownCancelled;

  final Map<String, GeofenceState> _state = {};
  final Map<String, GeofenceRawEvent> _pendingRaw = {};
  final Map<String, DateTime> _pendingRawSince = {};

  GeofenceAlertController({
    required this.clock,
    required this.onPanicTrigger,
    this.debounce = const Duration(seconds: 5),
    this.countdownDuration = const Duration(seconds: 60),
    this.cooldownDuration = const Duration(minutes: 10),
    this.onVibrateAndCountdownStart,
    this.onCountdownCancelled,
  });

  GeofenceState stateOf(String hotspotId) => _state[hotspotId] ?? GeofenceState.outside;

  /// Feed a raw (unfiltered) geofence transition from the OS geofencing API / a
  /// location stream comparison. Debounced internally — callers do not need to
  /// pre-filter noisy readings.
  void onRawEvent(GeofenceRawEvent event, {required String hotspotId}) {
    if (stateOf(hotspotId) == GeofenceState.cooldown) return;

    final since = clock.now();
    _pendingRaw[hotspotId] = event;
    _pendingRawSince[hotspotId] = since;

    clock.schedule(debounce, () {
      final stillPending =
          _pendingRaw[hotspotId] == event && _pendingRawSince[hotspotId] == since;
      if (!stillPending) return; // superseded by a later flip before debounce elapsed
      _applyDebounced(event, hotspotId);
    });
  }

  /// User tapped "False Alarm" during an active countdown.
  void falseAlarm(String hotspotId) {
    if (stateOf(hotspotId) == GeofenceState.entered) {
      onCountdownCancelled?.call(hotspotId);
      _enterCooldown(hotspotId);
    }
  }

  void _applyDebounced(GeofenceRawEvent event, String hotspotId) {
    final current = stateOf(hotspotId);
    if (event == GeofenceRawEvent.enter && current == GeofenceState.outside) {
      _state[hotspotId] = GeofenceState.entered;
      onVibrateAndCountdownStart?.call(hotspotId);
      clock.schedule(countdownDuration, () {
        if (stateOf(hotspotId) == GeofenceState.entered) {
          onPanicTrigger(PanicTrigger.geofenceTimeout, hotspotId: hotspotId);
          _enterCooldown(hotspotId);
        }
      });
    } else if (event == GeofenceRawEvent.exit && current == GeofenceState.entered) {
      // Left before the countdown expired — cancel silently, no panic trigger.
      onCountdownCancelled?.call(hotspotId);
      _enterCooldown(hotspotId);
    }
  }

  void _enterCooldown(String hotspotId) {
    _state[hotspotId] = GeofenceState.cooldown;
    clock.schedule(cooldownDuration, () {
      _state[hotspotId] = GeofenceState.outside;
    });
  }
}
