import 'package:latlong2/latlong.dart';

import '../../core/services/location_service.dart';

/// Preview Mode's location source — a single fixed position, no permission
/// prompt, no GPS (FR-PREV-1, FR-PREV-2).
class FixedLocationService implements LocationService {
  final LatLng position;

  FixedLocationService(this.position);

  @override
  Future<bool> requestPermission() async => true; // nothing to grant

  @override
  Stream<LatLng> watchPosition() => Stream.value(position);
}
