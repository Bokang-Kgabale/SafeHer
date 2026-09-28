import 'package:latlong2/latlong.dart';

import '../core/controllers/panic_controller.dart';
import '../core/repositories/emergency_contact_repository.dart';
import '../core/repositories/emergency_facility_repository.dart';
import '../core/repositories/hotspot_repository.dart';
import '../core/services/location_service.dart';
import '../core/util/scheduler_clock.dart';
import '../data/device/geolocator_location_service.dart';
import '../data/preview/fixed_location_service.dart';
import '../data/preview/preview_dispatch_gateways.dart';
import '../data/preview/preview_emergency_contact_repository.dart';
import '../data/preview/preview_emergency_facility_repository.dart';
import '../data/preview/preview_hotspot_repository.dart';
import '../data/preview/preview_panic_event_repository.dart';
import '../data/preview/preview_seed_data.dart';

/// Bundles every service the app needs behind their interfaces. Today this
/// always wires the Preview (mock, zero-network) implementations — real
/// Firebase-backed services are a P1 fast-follow that only needs to change
/// this one file, since everything above (controllers, UI) depends on the
/// interfaces, not on Preview directly.
class AppServices {
  final String currentUserId = 'preview-user';

  final SchedulerClock clock = const SystemSchedulerClock();
  final SimulatedDispatchLog simulatedDispatchLog = SimulatedDispatchLog();

  late final HotspotRepository hotspotRepository = PreviewHotspotRepository();
  late final EmergencyContactRepository contactRepository =
      PreviewEmergencyContactRepository();
  late final EmergencyFacilityRepository facilityRepository =
      PreviewEmergencyFacilityRepository();
  late final PanicEventRepository panicEventRepository = PreviewPanicEventRepository();

  late final TelephonyGateway telephonyGateway =
      PreviewTelephonyGateway(simulatedDispatchLog);
  late final WhatsAppGateway whatsappGateway =
      PreviewWhatsAppGateway(simulatedDispatchLog);

  /// Preview Mode has no real GPS story — this is a fixed simulated position
  /// a demo can reason about, matching FR-PREV-2's "simulated (non-GPS) user
  /// position." [CurrentPositionController] writes through to this field
  /// whenever a real GPS fix (or a reset back to simulated) lands, so
  /// [PanicController]'s synchronous `locationProvider` always reads the
  /// latest value without needing to be async.
  LatLng currentPosition = PreviewSeedData.simulatedUserPosition;

  final LocationService previewLocationService =
      FixedLocationService(PreviewSeedData.simulatedUserPosition);
  final LocationService liveLocationService = GeolocatorLocationService();

  late final PanicController panicController = PanicController(
    clock: clock,
    telephony: telephonyGateway,
    whatsapp: whatsappGateway,
    repository: panicEventRepository,
    contactsProvider: () {
      // Preview repository is in-memory/synchronous under the hood; a real
      // Firebase-backed AppServices will cache the latest stream value here
      // instead of calling into async Firestore mid-escalation.
      final preview = contactRepository as PreviewEmergencyContactRepository;
      return preview.currentContacts;
    },
    locationProvider: () => currentPosition,
    userId: currentUserId,
  );
}
