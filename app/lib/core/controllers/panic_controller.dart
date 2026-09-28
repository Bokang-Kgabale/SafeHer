import 'dart:async';

import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

import '../models/emergency_contact.dart';
import '../models/panic_event.dart';
import '../util/scheduler_clock.dart';

/// Attempts a voice call. Returns whether the OS reports the call as connected
/// — this is a best-effort signal, not proof the contact actually answered
/// (Algorithm Test Plan §2.3, edge case 3).
abstract class TelephonyGateway {
  Future<bool> attemptCall(EmergencyContact contact);
}

abstract class WhatsAppGateway {
  Future<void> sendLocation(EmergencyContact contact, LatLng location);
}

abstract class PanicEventRepository {
  Future<void> save(PanicEvent event);
  Future<PanicEvent?> findUnresolvedForUser(String userId);

  /// Live feed for UI/admin views (e.g. the Activity screen's escalation
  /// timeline, or the Flutter Web dashboard's finance/admin view per SRS
  /// FR-PAY-8). Declared on the interface — not just on the Preview
  /// implementation — so a real backend can be a drop-in replacement.
  Stream<List<PanicEvent>> watchAll();
}

/// Funnels every trigger source (manual, voice, power-button, fall, geofence
/// timeout) into one pipeline: dedupe concurrent triggers into a single event,
/// attempt escalation through the next-of-kin priority list with a call +
/// WhatsApp fallback at each step, and never block local persistence on
/// network/telephony success (SRS FR-PANIC, Algorithm Test Plan §2).
class PanicController {
  final SchedulerClock clock;
  final TelephonyGateway telephony;
  final WhatsAppGateway whatsapp;
  final PanicEventRepository repository;
  final List<EmergencyContact> Function() contactsProvider;
  final LatLng Function() locationProvider;
  final String userId;
  final Duration dedupeWindow;
  final Duration ackWindow;
  final Uuid _uuid;

  PanicEvent? _active;
  Completer<bool>? _ackCompleter;
  Future<void>? _escalationInFlight;

  PanicController({
    required this.clock,
    required this.telephony,
    required this.whatsapp,
    required this.repository,
    required this.contactsProvider,
    required this.locationProvider,
    required this.userId,
    this.dedupeWindow = const Duration(minutes: 5),
    this.ackWindow = const Duration(seconds: 90),
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  PanicEvent? get activeEvent => _active;

  /// Fires the pipeline. Returns immediately after persisting the event locally
  /// so the UI can give instant feedback — escalation runs in the background.
  Future<PanicEvent> trigger(PanicTrigger source) async {
    final existing = _active;
    if (existing != null &&
        !existing.isTerminal &&
        clock.now().difference(existing.timestamp) < dedupeWindow) {
      return existing; // two triggers within the dedupe window -> one event
    }

    final event = PanicEvent(
      id: _uuid.v4(),
      userId: userId,
      location: locationProvider(),
      timestamp: clock.now(),
      triggerType: source,
    );
    _active = event;
    await repository.save(event);
    _escalationInFlight = _escalate(event);
    return event;
  }

  /// Resumes an unresolved event after a simulated (or real) process restart.
  Future<void> resumeAnyUnresolved() async {
    final unresolved = await repository.findUnresolvedForUser(userId);
    if (unresolved != null && !unresolved.isTerminal) {
      _active = unresolved;
      _escalationInFlight = _escalate(unresolved);
    }
  }

  /// Contact (or the user herself, via an in-app "I'm safe" confirmation) has
  /// acknowledged the alert.
  void acknowledge() {
    if (_ackCompleter != null && !_ackCompleter!.isCompleted) {
      _ackCompleter!.complete(true);
    }
  }

  /// Lets tests flush pending escalation microtasks (e.g. after advancing a fake
  /// clock past an ack-window timeout). Deliberately does NOT await
  /// [_escalationInFlight] to completion — that future may still be legitimately
  /// suspended waiting on the next ack window, which is exactly the mid-flight
  /// state most tests want to inspect.
  Future<void> pump() async {
    await Future<void>.delayed(Duration.zero);
  }

  /// Exposed for diagnostics/tests that want to know whether escalation is
  /// still running in the background.
  Future<void>? get escalationInFlight => _escalationInFlight;

  Future<void> _escalate(PanicEvent event) async {
    final contacts = [...contactsProvider()]
      ..sort((a, b) => a.priorityOrder.compareTo(b.priorityOrder));

    for (var i = event.escalationIndex; i < contacts.length; i++) {
      final contact = contacts[i];
      _active = _active?.copyWith(escalationIndex: i);
      await repository.save(_active!);

      final connected = await telephony.attemptCall(contact);
      await whatsapp.sendLocation(contact, event.location); // always sent, belt-and-braces

      _active = _active?.copyWith(notifiedContacts: [
        ..._active!.notifiedContacts,
        NotifiedContact(
          contactId: contact.id,
          channel: NotificationChannel.call,
          delivered: connected,
          attemptedAt: clock.now(),
        ),
        NotifiedContact(
          contactId: contact.id,
          channel: NotificationChannel.whatsapp,
          delivered: true,
          attemptedAt: clock.now(),
        ),
      ]);
      await repository.save(_active!);

      final acknowledged = await _waitForAck();
      if (acknowledged) {
        _active = _active?.copyWith(status: PanicStatus.resolved);
        await repository.save(_active!);
        return;
      }
    }

    _active = _active?.copyWith(status: PanicStatus.unresolved);
    await repository.save(_active!);
  }

  Future<bool> _waitForAck() {
    final completer = Completer<bool>();
    _ackCompleter = completer;
    clock.schedule(ackWindow, () {
      if (!completer.isCompleted) completer.complete(false);
    });
    return completer.future;
  }
}
