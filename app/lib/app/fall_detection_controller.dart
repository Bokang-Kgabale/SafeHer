import 'dart:async';
import 'dart:math' show sqrt;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../core/algorithms/fall_detector.dart';
import '../core/controllers/panic_controller.dart';
import '../core/models/panic_event.dart';
import '../core/services/alert_feedback_controller.dart';

class ActiveFallAlert {
  final int secondsRemaining;
  const ActiveFallAlert(this.secondsRemaining);
}

/// Live wiring for FR-PANIC-5 around the pure, unit-tested [FallDetector].
///
/// UNVERIFIED ON A REAL DEVICE: this repo has no accelerometer to test
/// against (see Algorithm Test Plan §4.4 — real acceptance needs a recorded
/// on-device corpus, not just the synthetic fixtures backing
/// `fall_detector_test.dart`). Kept behind an explicit opt-in toggle (rather
/// than active by default) so a platform where `sensors_plus` has no
/// implementation (desktop/web) degrades to a no-op instead of crashing.
class FallDetectionController extends StateNotifier<ActiveFallAlert?> {
  final PanicController panicController;
  final AlertFeedbackController alertFeedback;
  final AlertStyle Function() alertStyle;
  final FallDetector detector;
  final Duration bufferWindow;
  final int countdownSeconds;

  final List<AccelMagnitudeSample> _buffer = [];
  final Stopwatch _stopwatch = Stopwatch();
  StreamSubscription<AccelerometerEvent>? _sensorSubscription;
  Timer? _ticker;
  bool _countdownActive = false;

  FallDetectionController({
    required this.panicController,
    required this.alertFeedback,
    required this.alertStyle,
    FallDetector? detector,
    this.bufferWindow = const Duration(seconds: 5),
    this.countdownSeconds = 15,
  })  : detector = detector ?? FallDetector.defaultTuning(),
        super(null);

  bool get isActive => _sensorSubscription != null;

  void start() {
    if (isActive) return;
    _stopwatch
      ..reset()
      ..start();
    _sensorSubscription = accelerometerEventStream(
      samplingPeriod: SensorInterval.gameInterval,
    ).listen(
      _onEvent,
      onError: (Object _) => stop(), // e.g. no sensor on this platform — degrade quietly
      cancelOnError: true,
    );
  }

  void stop() {
    _sensorSubscription?.cancel();
    _sensorSubscription = null;
    _ticker?.cancel();
    _ticker = null;
    _countdownActive = false;
    _buffer.clear();
    state = null;
    unawaited(alertFeedback.stop());
  }

  void _onEvent(AccelerometerEvent event) {
    final magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
    final t = _stopwatch.elapsed;
    _buffer.add(AccelMagnitudeSample(t, magnitude));
    _buffer.removeWhere((s) => t - s.t > bufferWindow);

    if (_countdownActive) return; // already confirming a candidate — don't re-evaluate

    final result = detector.evaluate(_buffer);
    if (result.confirmed) {
      _startCountdown();
    }
  }

  void _startCountdown() {
    _countdownActive = true;
    var remaining = countdownSeconds;
    state = ActiveFallAlert(remaining);
    unawaited(alertFeedback.start(alertStyle()));
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      remaining -= 1;
      if (remaining <= 0) {
        _ticker?.cancel();
        _countdownActive = false;
        _buffer.clear(); // don't let the same window immediately re-trigger
        state = null;
        unawaited(alertFeedback.stop());
        panicController.trigger(PanicTrigger.fallDetection);
        return;
      }
      state = ActiveFallAlert(remaining);
    });
  }

  /// User confirms she's OK — cancels before escalation.
  void confirmOk() {
    _ticker?.cancel();
    _countdownActive = false;
    _buffer.clear();
    state = null;
    unawaited(alertFeedback.stop());
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
