import '../../core/models/emergency_contact.dart';
import '../../core/repositories/emergency_contact_repository.dart';
import '../../core/util/latest_value_stream.dart';
import 'preview_seed_data.dart';

class PreviewEmergencyContactRepository implements EmergencyContactRepository {
  final List<EmergencyContact> _contacts = [...PreviewSeedData.contacts];
  final _stream = LatestValueStreamController<List<EmergencyContact>>();

  PreviewEmergencyContactRepository() {
    _stream.add(List.unmodifiable(_contacts));
  }

  /// Synchronous snapshot for [PanicController]'s `contactsProvider`, which
  /// needs the current priority list at trigger time without awaiting a
  /// stream. A real Firebase-backed repository should maintain an equivalent
  /// cached snapshot fed by its Firestore listener, rather than making
  /// `contactsProvider` async.
  List<EmergencyContact> get currentContacts => List.unmodifiable(_contacts);

  @override
  Stream<List<EmergencyContact>> watchForUser(String userId) =>
      _stream.stream.map((all) => all.where((c) => c.userId == userId).toList());

  @override
  Future<void> upsert(EmergencyContact contact) async {
    final index = _contacts.indexWhere((c) => c.id == contact.id);
    if (index == -1) {
      _contacts.add(contact);
    } else {
      _contacts[index] = contact;
    }
    _stream.add(List.unmodifiable(_contacts));
  }

  @override
  Future<void> remove(String contactId) async {
    _contacts.removeWhere((c) => c.id == contactId);
    _stream.add(List.unmodifiable(_contacts));
  }
}
