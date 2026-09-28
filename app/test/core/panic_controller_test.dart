import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:safeher/core/controllers/panic_controller.dart';
import 'package:safeher/core/models/emergency_contact.dart';
import 'package:safeher/core/models/panic_event.dart';

import '../support/fake_scheduler_clock.dart';
import '../support/panic_fakes.dart';

const contactA = EmergencyContact(
  id: 'c1',
  userId: 'u1',
  name: 'Mom',
  phoneNumber: '+27000000001',
  priorityOrder: 0,
);
const contactB = EmergencyContact(
  id: 'c2',
  userId: 'u1',
  name: 'Sister',
  phoneNumber: '+27000000002',
  priorityOrder: 1,
);

void main() {
  group('PanicController', () {
    late FakeSchedulerClock clock;
    late FakeTelephonyGateway telephony;
    late FakeWhatsAppGateway whatsapp;
    late InMemoryPanicEventRepository repository;

    PanicController buildController({List<EmergencyContact>? contacts}) {
      return PanicController(
        clock: clock,
        telephony: telephony,
        whatsapp: whatsapp,
        repository: repository,
        contactsProvider: () => contacts ?? [contactA, contactB],
        locationProvider: () => const LatLng(-29.12, 26.21),
        userId: 'u1',
        ackWindow: const Duration(seconds: 90),
      );
    }

    setUp(() {
      clock = FakeSchedulerClock();
      telephony = FakeTelephonyGateway();
      whatsapp = FakeWhatsAppGateway();
      repository = InMemoryPanicEventRepository();
    });

    test('a trigger calls the first contact and sends WhatsApp immediately', () async {
      final controller = buildController();
      await controller.trigger(PanicTrigger.manual);
      await controller.pump();

      expect(telephony.callsAttempted, [contactA]);
      expect(whatsapp.sent, [contactA]);
    });

    test('escalates to the next contact only after the ack window elapses unanswered', () async {
      final controller = buildController();
      await controller.trigger(PanicTrigger.manual);
      await controller.pump();
      expect(telephony.callsAttempted, [contactA]);

      clock.advance(const Duration(seconds: 91));
      await controller.pump();

      expect(telephony.callsAttempted, [contactA, contactB]);
    });

    test('acknowledging within the ack window resolves without escalating further', () async {
      final controller = buildController();
      await controller.trigger(PanicTrigger.manual);
      await controller.pump();

      controller.acknowledge();
      await controller.pump();

      expect(telephony.callsAttempted, [contactA]);
      expect(repository.events.last.status, PanicStatus.resolved);
    });

    test('two triggers within the dedupe window create exactly one event', () async {
      final controller = buildController();
      final first = await controller.trigger(PanicTrigger.voice);
      final second = await controller.trigger(PanicTrigger.powerButton);

      expect(second.id, first.id);
      expect(repository.events.map((e) => e.id).toSet().length, 1);
    });

    test('a trigger after the dedupe window (event resolved) creates a new event', () async {
      final controller = buildController();
      await controller.trigger(PanicTrigger.manual);
      await controller.pump();
      controller.acknowledge();
      await controller.pump();

      final second = await controller.trigger(PanicTrigger.fallDetection);
      expect(repository.events.map((e) => e.id).toSet().length, 2);
      expect(second.triggerType, PanicTrigger.fallDetection);
    });

    test('exhausting all contacts unacknowledged marks the event unresolved', () async {
      final controller = buildController(contacts: [contactA]);
      await controller.trigger(PanicTrigger.manual);
      await controller.pump();

      clock.advance(const Duration(seconds: 91));
      await controller.pump();

      expect(repository.events.last.status, PanicStatus.unresolved);
    });

    test('resumes an unresolved event after a simulated process restart', () async {
      repository.seed(PanicEvent(
        id: 'existing-1',
        userId: 'u1',
        location: const LatLng(-29.12, 26.21),
        timestamp: clock.now(),
        triggerType: PanicTrigger.fallDetection,
        status: PanicStatus.triggered,
      ));

      final controllerAfterRestart = buildController();
      await controllerAfterRestart.resumeAnyUnresolved();
      await controllerAfterRestart.pump();

      expect(telephony.callsAttempted, [contactA]);
    });
  });
}
