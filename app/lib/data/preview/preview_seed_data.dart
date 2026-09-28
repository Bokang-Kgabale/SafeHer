import 'package:latlong2/latlong.dart';

import '../../core/models/emergency_contact.dart';
import '../../core/models/emergency_facility.dart';
import '../../core/models/hotspot.dart';

/// Static seed data for Preview Mode (SRS FR-PREV-2, Algorithm Test Plan §11.4).
///
/// Coordinates are approximate placements around Bloemfontein's named corridors
/// (Westdene, Willows, Universitas, Brandwag, CBD fringe) for demo realism —
/// they are not surveyed/verified real-world hotspot locations. This dataset
/// ships as static Dart, not a fetched asset, so Preview Mode has zero network
/// dependency (SEC-11).
class PreviewSeedData {
  PreviewSeedData._();

  /// Deliberately placed outside every seeded hotspot's radius below — it
  /// used to sit exactly on `preview-hs-3`'s coordinates, which meant real
  /// GPS/proximity wiring (`HotspotProximityWatcher`) triggered a geofence
  /// alert the instant the app launched. Bloemfontein CBD-fringe area,
  /// comfortably clear of all five mock hotspots.
  static const LatLng simulatedUserPosition = LatLng(-29.1150, 26.2050);

  static final List<Hotspot> hotspots = [
    Hotspot(
      id: 'preview-hs-1',
      location: const LatLng(-29.1000, 26.1850), // Westdene
      category: HotspotCategory.noLighting,
      description: 'Poorly lit stretch near the student residences — avoid after dark.',
      reporterId: 'preview-reporter-1',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Hotspot(
      id: 'preview-hs-2',
      location: const LatLng(-29.0917, 26.2264), // Willows
      category: HotspotCategory.robbery,
      description: 'Two robberies reported near the taxi rank in the last month.',
      reporterId: 'preview-reporter-2',
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Hotspot(
      id: 'preview-hs-3',
      location: const LatLng(-29.1074, 26.1904), // Universitas
      category: HotspotCategory.harassment,
      description: 'Persistent catcalling reported along this footpath.',
      reporterId: 'preview-reporter-3',
      timestamp: DateTime.now().subtract(const Duration(hours: 20)),
      radiusMeters: 120,
    ),
    Hotspot(
      id: 'preview-hs-4',
      location: const LatLng(-29.1145, 26.2000), // Brandwag
      category: HotspotCategory.assault,
      description: 'Assault reported near the sports grounds entrance.',
      reporterId: 'preview-reporter-4',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Hotspot(
      id: 'preview-hs-5',
      location: const LatLng(-29.1211, 26.2140), // CBD fringe
      category: HotspotCategory.robbery,
      description: 'Bag-snatching reported near the taxi rank exit.',
      reporterId: 'preview-reporter-5',
      timestamp: DateTime.now().subtract(const Duration(hours: 6)),
    ),
  ];

  static final List<EmergencyFacility> facilities = [
    const EmergencyFacility(
      id: 'preview-fac-1',
      type: FacilityType.police,
      location: LatLng(-29.1187, 26.2144),
      name: 'Bloemfontein Park Road SAPS',
      contactNumber: '10111',
    ),
    const EmergencyFacility(
      id: 'preview-fac-2',
      type: FacilityType.hospital,
      location: LatLng(-29.1030, 26.1950),
      name: 'Universitas Academic Hospital',
      contactNumber: '051 405 1911',
    ),
    const EmergencyFacility(
      id: 'preview-fac-3',
      type: FacilityType.clinic,
      location: LatLng(-29.0960, 26.1900),
      name: 'Heidedal Community Health Clinic',
      contactNumber: '051 411 0000',
    ),
  ];

  static final List<EmergencyContact> contacts = [
    const EmergencyContact(
      id: 'preview-contact-1',
      userId: 'preview-user',
      name: 'Thandi (Mother)',
      phoneNumber: '+27 82 000 0001',
      priorityOrder: 0,
      relationship: 'Mother',
    ),
    const EmergencyContact(
      id: 'preview-contact-2',
      userId: 'preview-user',
      name: 'Lerato (Sister)',
      phoneNumber: '+27 82 000 0002',
      priorityOrder: 1,
      relationship: 'Sister',
    ),
  ];
}
