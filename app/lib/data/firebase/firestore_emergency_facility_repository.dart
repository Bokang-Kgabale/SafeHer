import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

import '../../core/models/emergency_facility.dart';
import '../../core/repositories/emergency_facility_repository.dart';

/// See `lib/data/firebase/README.md` — not wired into AppServices by
/// default. Public read, admin/backend-only write (SRS §6.3).
class FirestoreEmergencyFacilityRepository implements EmergencyFacilityRepository {
  final CollectionReference<Map<String, dynamic>> _collection;

  FirestoreEmergencyFacilityRepository({FirebaseFirestore? firestore})
      : _collection = (firestore ?? FirebaseFirestore.instance).collection('emergencyFacilities');

  @override
  Stream<List<EmergencyFacility>> watchAll() {
    return _collection.snapshots().map((snapshot) => snapshot.docs.map(_fromDoc).toList());
  }

  EmergencyFacility _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final geoPoint = data['location'] as GeoPoint;
    return EmergencyFacility(
      id: doc.id,
      type: FacilityType.values.byName(data['type'] as String),
      location: LatLng(geoPoint.latitude, geoPoint.longitude),
      name: data['name'] as String,
      contactNumber: data['contactNumber'] as String,
    );
  }
}
