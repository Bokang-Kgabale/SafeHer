import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/models/emergency_contact.dart';
import '../../core/repositories/emergency_contact_repository.dart';

/// See `lib/data/firebase/README.md` — not wired into AppServices by
/// default.
///
/// SEC-2 note: production Firestore rules for this collection must require
/// the request to be both the owning user AND recently re-authenticated
/// (Firestore rules can check `request.auth.token.auth_time`) — this class
/// only performs the read/write, it does not and cannot enforce that gate
/// itself. The re-authentication UI flow (e.g. via `local_auth`) is a
/// separate, not-yet-built piece — see `ContactsScreen`'s doc comment.
class FirestoreEmergencyContactRepository implements EmergencyContactRepository {
  final CollectionReference<Map<String, dynamic>> _collection;

  FirestoreEmergencyContactRepository({FirebaseFirestore? firestore})
      : _collection = (firestore ?? FirebaseFirestore.instance).collection('emergencyContacts');

  @override
  Stream<List<EmergencyContact>> watchForUser(String userId) {
    return _collection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_fromDoc).toList());
  }

  @override
  Future<void> upsert(EmergencyContact contact) async {
    await _collection.doc(contact.id).set(_toMap(contact));
  }

  @override
  Future<void> remove(String contactId) async {
    await _collection.doc(contactId).delete();
  }

  EmergencyContact _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return EmergencyContact(
      id: doc.id,
      userId: data['userId'] as String,
      name: data['name'] as String,
      phoneNumber: data['phoneNumber'] as String,
      priorityOrder: data['priorityOrder'] as int,
      relationship: data['relationship'] as String?,
    );
  }

  Map<String, dynamic> _toMap(EmergencyContact contact) => {
        'userId': contact.userId,
        'name': contact.name,
        'phoneNumber': contact.phoneNumber,
        'priorityOrder': contact.priorityOrder,
        'relationship': contact.relationship,
      };
}
