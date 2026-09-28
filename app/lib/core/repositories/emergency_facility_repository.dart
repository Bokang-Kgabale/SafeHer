import '../models/emergency_facility.dart';

abstract class EmergencyFacilityRepository {
  Stream<List<EmergencyFacility>> watchAll();
}
