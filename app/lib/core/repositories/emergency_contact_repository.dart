import '../models/emergency_contact.dart';

abstract class EmergencyContactRepository {
  Stream<List<EmergencyContact>> watchForUser(String userId);
  Future<void> upsert(EmergencyContact contact);
  Future<void> remove(String contactId);
}
