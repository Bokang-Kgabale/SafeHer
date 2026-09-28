import 'package:latlong2/latlong.dart';

import '../../core/controllers/panic_controller.dart';
import '../../core/models/emergency_contact.dart';
import '../../core/models/simulated_dispatch_entry.dart';
import '../../core/util/latest_value_stream.dart';

/// Preview Mode's "SimulatedDispatcher" (Algorithm Test Plan §11.4): logs what
/// would have been sent to an on-screen timeline instead of ever placing a
/// real call or WhatsApp message (SRS FR-PREV-3).
class SimulatedDispatchLog {
  final List<SimulatedDispatchEntry> _entries = [];
  final _stream = LatestValueStreamController<List<SimulatedDispatchEntry>>();

  Stream<List<SimulatedDispatchEntry>> watchAll() => _stream.stream;

  void log(SimulatedDispatchEntry entry) {
    _entries.add(entry);
    _stream.add(List.unmodifiable(_entries));
  }
}

class PreviewTelephonyGateway implements TelephonyGateway {
  final SimulatedDispatchLog log;

  PreviewTelephonyGateway(this.log);

  @override
  Future<bool> attemptCall(EmergencyContact contact) async {
    log.log(SimulatedDispatchEntry(
      at: DateTime.now(),
      contactName: contact.name,
      channel: 'call',
      summary: 'Simulated call placed to ${contact.phoneNumber} (Preview Mode — not real)',
    ));
    return true; // simulate a connected call so the escalation timeline is demoable
  }
}

class PreviewWhatsAppGateway implements WhatsAppGateway {
  final SimulatedDispatchLog log;

  PreviewWhatsAppGateway(this.log);

  @override
  Future<void> sendLocation(EmergencyContact contact, LatLng location) async {
    log.log(SimulatedDispatchEntry(
      at: DateTime.now(),
      contactName: contact.name,
      channel: 'whatsapp',
      summary:
          'Simulated WhatsApp sent to ${contact.phoneNumber} with coordinates '
          '(${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}) — Preview Mode, not real',
    ));
  }
}
