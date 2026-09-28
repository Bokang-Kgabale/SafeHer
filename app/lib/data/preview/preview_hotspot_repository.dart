import '../../core/models/hotspot.dart';
import '../../core/repositories/hotspot_repository.dart';
import '../../core/util/latest_value_stream.dart';
import 'preview_seed_data.dart';

/// Preview Mode implementation — in-memory only, seeded from static fixtures,
/// never a network call (SEC-11). A newly-reported pin is added locally so the
/// demo flow feels real, but is never persisted or synced anywhere.
class PreviewHotspotRepository implements HotspotRepository {
  final List<Hotspot> _hotspots = [...PreviewSeedData.hotspots];
  final _stream = LatestValueStreamController<List<Hotspot>>();

  PreviewHotspotRepository() {
    _stream.add(List.unmodifiable(_hotspots));
  }

  @override
  Stream<List<Hotspot>> watchAll() => _stream.stream;

  @override
  Future<void> report(Hotspot hotspot) async {
    _hotspots.add(hotspot);
    _stream.add(List.unmodifiable(_hotspots));
  }
}
