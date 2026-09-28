import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../core/services/location_service.dart';

/// Real device GPS, wrapping `geolocator`. This is the "live demo" path, not
/// Preview Mode — it requests a genuine OS location permission and is only
/// ever activated when a user explicitly opts in (see the app bar's "Live
/// GPS" toggle), never on first launch (FR-PREV-1 only governs Preview Mode
/// itself, but the same zero-surprise-permissions spirit applies everywhere).
///
/// P1 note: this drives the geofence engine directly off real-time distance
/// to the still-mock hotspot set — real background OS geofencing (the
/// `Geofencing` platform API, registering circular regions so the check
/// survives the app being backgrounded) is deferred; this only works while
/// the app is foregrounded. See Algorithm Test Plan §1 for the target design.
class GeolocatorLocationService implements LocationService {
  @override
  Future<bool> requestPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  @override
  Stream<LatLng> watchPosition() {
    const settings = LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 5);
    return Geolocator.getPositionStream(locationSettings: settings)
        .map((position) => LatLng(position.latitude, position.longitude));
  }
}
