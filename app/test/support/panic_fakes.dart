import 'package:latlong2/latlong.dart';
import 'package:safeher/core/controllers/panic_controller.dart';
import 'package:safeher/core/models/emergency_contact.dart';
import 'package:safeher/core/models/panic_event.dart';

class FakeTelephonyGateway implements TelephonyGateway {
  final List<EmergencyContact> callsAttempted = [];
  bool connectsButNeverAcks = false;
  bool alwaysFailsToConnect = false;

  @override
  Future<bool> attemptCall(EmergencyContact contact) async {
    callsAttempted.add(contact);
    if (alwaysFailsToConnect) return false;
    return true; // OS reports connected; ack behaviour is separate (see PanicController.acknowledge)
  }
}

class FakeWhatsAppGateway implements WhatsAppGateway {
  final List<EmergencyContact> sent = [];

  @override
  Future<void> sendLocation(EmergencyContact contact, LatLng location) async {
    sent.add(contact);
  }
}

class InMemoryPanicEventRepository implements PanicEventRepository {
  final List<PanicEvent> events = [];

  void seed(PanicEvent event) => events.add(event);

  @override
  Stream<List<PanicEvent>> watchAll() => Stream.value(events);

  @override
  Future<void> save(PanicEvent event) async {
    final index = events.indexWhere((e) => e.id == event.id);
    if (index == -1) {
      events.add(event);
    } else {
      events[index] = event;
    }
  }

  @override
  Future<PanicEvent?> findUnresolvedForUser(String userId) async {
    for (final event in events.reversed) {
      if (event.userId == userId && !event.isTerminal) return event;
    }
    return null;
  }
}
