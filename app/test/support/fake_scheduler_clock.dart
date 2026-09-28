import 'package:safeher/core/util/scheduler_clock.dart';

class _ScheduledCallback {
  final DateTime fireAt;
  final void Function() callback;
  _ScheduledCallback(this.fireAt, this.callback);
}

/// Deterministic scheduler for tests: `advance()` moves the clock forward and
/// synchronously fires any callback whose deadline falls within the advance,
/// in deadline order — including callbacks newly scheduled by an earlier one
/// firing (e.g. an enter's debounce callback scheduling the countdown timer).
class FakeSchedulerClock implements SchedulerClock {
  DateTime _now;
  final List<_ScheduledCallback> _scheduled = [];

  FakeSchedulerClock([DateTime? start]) : _now = start ?? DateTime(2026, 1, 1);

  @override
  DateTime now() => _now;

  @override
  void schedule(Duration delay, void Function() callback) {
    _scheduled.add(_ScheduledCallback(_now.add(delay), callback));
  }

  void advance(Duration delta) {
    final target = _now.add(delta);
    while (true) {
      _scheduled.sort((a, b) => a.fireAt.compareTo(b.fireAt));
      final dueIndex = _scheduled.indexWhere((c) => !c.fireAt.isAfter(target));
      if (dueIndex == -1) break;
      final due = _scheduled.removeAt(dueIndex);
      _now = due.fireAt;
      due.callback();
    }
    _now = target;
  }
}
