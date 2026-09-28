import 'package:latlong2/latlong.dart';

enum FacilityType { police, hospital, clinic }

class EmergencyFacility {
  final String id;
  final FacilityType type;
  final LatLng location;
  final String name;
  final String contactNumber;

  const EmergencyFacility({
    required this.id,
    required this.type,
    required this.location,
    required this.name,
    required this.contactNumber,
  });
}
