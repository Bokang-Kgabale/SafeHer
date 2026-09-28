import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

import '../../core/models/hotspot.dart';
import '../../core/repositories/hotspot_repository.dart';

/// See `lib/data/firebase/README.md` — not wired into [AppServices] by
/// default. Mirrors SRS §6.1's `Hotspot` entity and §6.3's intent that reads
/// are public but writes require authentication (enforced by Firestore
/// security rules, not by this class).
class FirestoreHotspotRepository implements HotspotRepository {
  final CollectionReference<Map<String, dynamic>> _collection;

  FirestoreHotspotRepository({FirebaseFirestore? firestore})
      : _collection = (firestore ?? FirebaseFirestore.instance).collection('hotspots');

  @override
  Stream<List<Hotspot>> watchAll() {
    return _collection
        .where('verificationStatus', isEqualTo: 'published')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_fromDoc).toList());
  }

  @override
  Future<void> report(Hotspot hotspot) async {
    // FR-HS-4/FR-HS-6: timestamp and validation are server-side concerns in
    // production (a Cloud Function trigger, per SEC-5) — this client write
    // is the "submit," not the final trusted record.
    await _collection.doc(hotspot.id).set(_toMap(hotspot));
  }

  Hotspot _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final geoPoint = data['location'] as GeoPoint;
    return Hotspot(
      id: doc.id,
      location: LatLng(geoPoint.latitude, geoPoint.longitude),
      category: HotspotCategory.values.byName(data['category'] as String),
      description: data['description'] as String?,
      reporterId: data['reporterId'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      verificationStatus:
          HotspotVerificationStatus.values.byName(data['verificationStatus'] as String),
      radiusMeters: (data['radiusMeters'] as num).toDouble(),
      // A real backend stores a Storage download URL here, not the reporting
      // device's local file path — this client only ever writes/reads
      // whatever string it's given, upload-to-Storage is a P1 concern (see
      // this file's class doc comment).
      photoPath: data['photoPath'] as String?,
    );
  }

  Map<String, dynamic> _toMap(Hotspot hotspot) => {
        'location': GeoPoint(hotspot.location.latitude, hotspot.location.longitude),
        'category': hotspot.category.name,
        'description': hotspot.description,
        'reporterId': hotspot.reporterId,
        'timestamp': Timestamp.fromDate(hotspot.timestamp),
        'verificationStatus': hotspot.verificationStatus.name,
        'radiusMeters': hotspot.radiusMeters,
        'photoPath': hotspot.photoPath,
      };
}
