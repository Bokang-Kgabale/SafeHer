import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

import '../../core/controllers/panic_controller.dart';
import '../../core/models/panic_event.dart';

/// See `lib/data/firebase/README.md` — not wired into AppServices by
/// default.
///
/// SEC-1 note: production Firestore rules must ensure a client can only
/// create/update a `PanicEvent` for their own `userId`, and that live-location
/// fields are readable only by that event's assigned, currently-active next
/// of kin (SRS §6.3) — this class performs the read/write only, it is not
/// itself the access-control boundary.
class FirestorePanicEventRepository implements PanicEventRepository {
  final CollectionReference<Map<String, dynamic>> _collection;

  FirestorePanicEventRepository({FirebaseFirestore? firestore})
      : _collection = (firestore ?? FirebaseFirestore.instance).collection('panicEvents');

  @override
  Future<void> save(PanicEvent event) async {
    await _collection.doc(event.id).set(_toMap(event));
  }

  @override
  Future<PanicEvent?> findUnresolvedForUser(String userId) async {
    final snapshot = await _collection
        .where('userId', isEqualTo: userId)
        .where('status', whereIn: ['triggered', 'acknowledged', 'escalated'])
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return _fromDoc(snapshot.docs.first);
  }

  @override
  Stream<List<PanicEvent>> watchAll() {
    return _collection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_fromDoc).toList());
  }

  PanicEvent _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final geoPoint = data['location'] as GeoPoint;
    final notified = (data['notifiedContacts'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>()
        .map((m) => NotifiedContact(
              contactId: m['contactId'] as String,
              channel: NotificationChannel.values.byName(m['channel'] as String),
              delivered: m['delivered'] as bool,
              attemptedAt: (m['attemptedAt'] as Timestamp).toDate(),
            ))
        .toList();

    return PanicEvent(
      id: doc.id,
      userId: data['userId'] as String,
      location: LatLng(geoPoint.latitude, geoPoint.longitude),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      triggerType: PanicTrigger.values.byName(data['triggerType'] as String),
      status: PanicStatus.values.byName(data['status'] as String),
      escalationIndex: data['escalationIndex'] as int? ?? 0,
      notifiedContacts: notified,
    );
  }

  Map<String, dynamic> _toMap(PanicEvent event) => {
        'userId': event.userId,
        'location': GeoPoint(event.location.latitude, event.location.longitude),
        'timestamp': Timestamp.fromDate(event.timestamp),
        'triggerType': event.triggerType.name,
        'status': event.status.name,
        'escalationIndex': event.escalationIndex,
        'notifiedContacts': event.notifiedContacts
            .map((n) => {
                  'contactId': n.contactId,
                  'channel': n.channel.name,
                  'delivered': n.delivered,
                  'attemptedAt': Timestamp.fromDate(n.attemptedAt),
                })
            .toList(),
      };
}
