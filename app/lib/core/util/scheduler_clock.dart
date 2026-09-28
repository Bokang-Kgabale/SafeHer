import 'dart:async';

/// Seam between real time (Timer/DateTime.now) and a deterministic fake used in
/// tests, so timing-sensitive controllers (geofence debounce/countdown, panic
/// escalation ack-window) can be unit-tested without real delays.
abstract class SchedulerClock {
  DateTime now();
  void schedule(Duration delay, void Function() callback);
}

class SystemSchedulerClock implements SchedulerClock {
  const SystemSchedulerClock();

  @override
  DateTime now() => DateTime.now();

  @override
  void schedule(Duration delay, void Function() callback) {
    Timer(delay, callback);
  }
}
