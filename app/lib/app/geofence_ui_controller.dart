import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/controllers/geofence_alert_controller.dart';
import '../core/controllers/panic_controller.dart';
import '../core/services/alert_feedback_controller.dart';

class ActiveGeofenceAlert {
  final String hotspotId;
  final int secondsRemaining;

  const ActiveGeofenceAlert({required this.hotspotId, required this.secondsRemaining});
}

/// Bridges the pure, unit-tested [GeofenceAlertController] to a UI-observable
/// countdown. The controller itself has no notion of "seconds remaining" (it
/// only reasons about scheduled deadlines) — this class adds a once-a-second
/// display tick purely for the widget layer, using a real [Timer.periodic],
/// which is fine here since production always runs on [SystemSchedulerClock]
/// and this class is never unit-tested directly (the state machine is,
/// exhaustively, in `geofence_alert_controller_test.dart`).
class GeofenceUiController extends StateNotifier<ActiveGeofenceAlert?> {
  final PanicController panicController;
  final AlertFeedbackController alertFeedback;
  final AlertStyle Function() alertStyle;
  late final GeofenceAlertController controller;
  Timer? _ticker;
  static const _countdownSeconds = 60;

  GeofenceUiController({
    required this.panicController,
    required this.alertFeedback,
    required this.alertStyle,
    Duration? countdownDuration,
  }) : super(null) {
    controller = GeofenceAlertController(
      clock: panicController.clock,
      countdownDuration: countdownDuration ?? const Duration(seconds: _countdownSeconds),
      onPanicTrigger: (trigger, {required hotspotId}) {
        panicController.trigger(trigger);
      },
      onVibrateAndCountdownStart: _startDisplay,
      onCountdownCancelled: _stopDisplay,
    );
  }

  void _startDisplay(String hotspotId) {
    _ticker?.cancel();
    var remaining = _countdownSeconds;
    state = ActiveGeofenceAlert(hotspotId: hotspotId, secondsRemaining: remaining);
    unawaited(alertFeedback.start(alertStyle()));
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      remaining -= 1;
      if (remaining <= 0) {
        _ticker?.cancel();
        unawaited(alertFeedback.stop());
        // Leave state at 0 rather than clearing it — a genuine expiry (as
        // opposed to False Alarm/exit) doesn't call onCountdownCancelled, so
        // the panic screen takes over from here.
        state = ActiveGeofenceAlert(hotspotId: hotspotId, secondsRemaining: 0);
        return;
      }
      state = ActiveGeofenceAlert(hotspotId: hotspotId, secondsRemaining: remaining);
    });
  }

  void _stopDisplay(String hotspotId) {
    if (state?.hotspotId == hotspotId) {
      _ticker?.cancel();
      unawaited(alertFeedback.stop());
      state = null;
    }
  }

  /// Demo/debug entry point standing in for real OS geofence callbacks until
  /// P1 wires `geolocator` + the platform Geofencing API. Faithfully goes
  /// through the same debounce path a real geofence transition would.
  void simulateEnter(String hotspotId) =>
      controller.onRawEvent(GeofenceRawEvent.enter, hotspotId: hotspotId);

  void simulateExit(String hotspotId) =>
      controller.onRawEvent(GeofenceRawEvent.exit, hotspotId: hotspotId);

  void falseAlarm(String hotspotId) => controller.falseAlarm(hotspotId);

  @override
  void dispose() {
    _ticker?.cancel();
    unawaited(alertFeedback.stop());
    super.dispose();
  }
}
