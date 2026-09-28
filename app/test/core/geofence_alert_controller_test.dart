import 'package:flutter_test/flutter_test.dart';
import 'package:safeher/core/controllers/geofence_alert_controller.dart';
import 'package:safeher/core/models/panic_event.dart';

import '../support/fake_scheduler_clock.dart';

void main() {
  group('GeofenceAlertController', () {
    late FakeSchedulerClock clock;
    late List<PanicTrigger> dispatched;
    late GeofenceAlertController controller;

    setUp(() {
      clock = FakeSchedulerClock();
      dispatched = [];
      controller = GeofenceAlertController(
        clock: clock,
        onPanicTrigger: (trigger, {required hotspotId}) => dispatched.add(trigger),
      );
    });

    test('GPS flapping near the boundary does not trigger an alert', () {
      for (var i = 0; i < 6; i++) {
        controller.onRawEvent(
          i.isEven ? GeofenceRawEvent.enter : GeofenceRawEvent.exit,
          hotspotId: 'h1',
        );
        clock.advance(const Duration(milliseconds: 500));
      }
      expect(controller.stateOf('h1'), GeofenceState.outside);
      expect(dispatched, isEmpty);
    });

    test('a stable entry past the debounce window starts the countdown', () {
      controller.onRawEvent(GeofenceRawEvent.enter, hotspotId: 'h1');
      clock.advance(const Duration(seconds: 6));
      expect(controller.stateOf('h1'), GeofenceState.entered);
    });

    test('countdown expiry fires the panic pipeline exactly once', () {
      controller.onRawEvent(GeofenceRawEvent.enter, hotspotId: 'h1');
      clock.advance(const Duration(seconds: 6)); // clears debounce -> entered
      clock.advance(const Duration(seconds: 60)); // countdown expiry
      expect(dispatched, [PanicTrigger.geofenceTimeout]);

      clock.advance(const Duration(seconds: 60));
      expect(dispatched.length, 1, reason: 'must not re-fire once resolved');
    });

    test('tapping False Alarm cancels the countdown with no trigger', () {
      controller.onRawEvent(GeofenceRawEvent.enter, hotspotId: 'h1');
      clock.advance(const Duration(seconds: 6));
      controller.falseAlarm('h1');
      clock.advance(const Duration(seconds: 60));
      expect(dispatched, isEmpty);
      expect(controller.stateOf('h1'), GeofenceState.cooldown);
    });

    test('exiting before the countdown expires cancels silently', () {
      controller.onRawEvent(GeofenceRawEvent.enter, hotspotId: 'h1');
      clock.advance(const Duration(seconds: 6));
      controller.onRawEvent(GeofenceRawEvent.exit, hotspotId: 'h1');
      clock.advance(const Duration(seconds: 6));
      clock.advance(const Duration(seconds: 60));
      expect(dispatched, isEmpty);
    });

    test('re-entry during cooldown is suppressed, but fires again after cooldown expires', () {
      controller.onRawEvent(GeofenceRawEvent.enter, hotspotId: 'h1');
      clock.advance(const Duration(seconds: 6));
      controller.falseAlarm('h1'); // -> cooldown

      controller.onRawEvent(GeofenceRawEvent.enter, hotspotId: 'h1');
      clock.advance(const Duration(seconds: 6));
      expect(controller.stateOf('h1'), GeofenceState.cooldown,
          reason: 'still suppressed during cooldown');

      clock.advance(const Duration(minutes: 10)); // cooldown expires
      controller.onRawEvent(GeofenceRawEvent.enter, hotspotId: 'h1');
      clock.advance(const Duration(seconds: 6));
      expect(controller.stateOf('h1'), GeofenceState.entered);
    });

    test('two overlapping hotspots track independent state', () {
      controller.onRawEvent(GeofenceRawEvent.enter, hotspotId: 'h1');
      controller.onRawEvent(GeofenceRawEvent.enter, hotspotId: 'h2');
      clock.advance(const Duration(seconds: 6));
      expect(controller.stateOf('h1'), GeofenceState.entered);
      expect(controller.stateOf('h2'), GeofenceState.entered);

      controller.falseAlarm('h1');
      expect(controller.stateOf('h1'), GeofenceState.cooldown);
      expect(controller.stateOf('h2'), GeofenceState.entered);
    });
  });
}
