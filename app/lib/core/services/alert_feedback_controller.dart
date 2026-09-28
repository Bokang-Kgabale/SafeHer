import 'dart:async';

import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

enum AlertStyle { vibration, ringtone }

/// Real, sustained alert feedback for the geofence and fall-detection
/// countdowns — deliberately **not** `HapticFeedback.vibrate()`, which only
/// produces a brief UI-feedback click on most devices, not a controllable
/// vibration. This uses the actual vibration motor via a repeating on/off
/// pattern ("streaming" vibration) for as long as a countdown is active, or
/// repeats the platform's system alert sound as the alternative style.
///
/// The ringtone style deliberately uses [SystemSound] rather than a
/// third-party "play an alarm/ringtone" plugin: an earlier version used
/// `flutter_ringtone_player`, whose Android module is built against an
/// incompatible (older) compileSdk and broke the real Android build — not
/// worth the risk for what is, here, a secondary alert style. `SystemSound`
/// ships with Flutter itself, so it can never introduce that class of
/// failure; the trade-off is a repeated short system tone rather than a true
/// looping melody.
class AlertFeedbackController {
  /// 500ms on, 500ms off, repeating from index 0 for as long as `stop()`
  /// hasn't been called.
  static const _pulsePattern = [0, 500, 500];
  static const _ringtoneInterval = Duration(milliseconds: 700);

  bool _active = false;
  Timer? _ringtoneTimer;

  Future<void> start(AlertStyle style) async {
    _active = true;
    switch (style) {
      case AlertStyle.vibration:
        await _startVibration();
      case AlertStyle.ringtone:
        _startRingtone();
    }
  }

  Future<void> stop() async {
    _active = false;
    _ringtoneTimer?.cancel();
    _ringtoneTimer = null;
    // Safe to call even if vibration wasn't the active style — a no-op then.
    unawaited(Vibration.cancel());
  }

  Future<void> _startVibration() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (!hasVibrator || !_active) return;
    // `repeat: 0` loops the pattern from index 0 indefinitely until cancelled.
    unawaited(Vibration.vibrate(pattern: _pulsePattern, repeat: 0));
  }

  void _startRingtone() {
    if (!_active) return;
    unawaited(SystemSound.play(SystemSoundType.alert));
    _ringtoneTimer?.cancel();
    _ringtoneTimer = Timer.periodic(_ringtoneInterval, (_) {
      unawaited(SystemSound.play(SystemSoundType.alert));
    });
  }
}
