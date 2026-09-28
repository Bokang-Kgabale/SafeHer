import 'package:latlong2/latlong.dart';

/// Abstraction over the device's location source so the app can swap between
/// a real GPS stream and Preview Mode's fixed simulated position without the
/// geofence/panic logic caring which one is active.
abstract class LocationService {
  /// Prompts for location permission if needed. Returns whether it was
  /// granted. Preview Mode's implementation never actually prompts (FR-PREV-1).
  Future<bool> requestPermission();

  Stream<LatLng> watchPosition();
}
