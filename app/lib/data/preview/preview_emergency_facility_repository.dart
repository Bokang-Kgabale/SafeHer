import '../../core/models/emergency_facility.dart';
import '../../core/repositories/emergency_facility_repository.dart';
import '../../core/util/latest_value_stream.dart';
import 'preview_seed_data.dart';

class PreviewEmergencyFacilityRepository implements EmergencyFacilityRepository {
  final _stream = LatestValueStreamController<List<EmergencyFacility>>();

  PreviewEmergencyFacilityRepository() {
    _stream.add(PreviewSeedData.facilities);
  }

  @override
  Stream<List<EmergencyFacility>> watchAll() => _stream.stream;
}
