import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../core/models/hotspot.dart';
import 'providers.dart';

/// Bridges live position + the hotspot list into the geofence engine's raw
/// enter/exit events — the real-world equivalent of the OS Geofencing API's
/// callbacks, computed here in Dart against [Distance] instead, since P1
/// only wires foreground GPS (see [GeolocatorLocationService]'s docs for why
/// background OS geofencing is deferred).
///
/// Instantiated once via [hotspotProximityWatcherProvider] and kept alive for
/// as long as something `ref.watch`es it — see `MapScreen`, which watches it
/// purely to activate these side effects.
class HotspotProximityWatcher {
  final Ref ref;
  final _distance = const Distance();
  final Set<String> _inside = {};

  List<Hotspot> _hotspots = [];
  LatLng? _position;

  late final ProviderSubscription<LatLng> _positionSub;
  late final ProviderSubscription<AsyncValue<List<Hotspot>>> _hotspotsSub;

  HotspotProximityWatcher(this.ref) {
    _positionSub = ref.listen<LatLng>(currentPositionControllerProvider, (previous, next) {
      _position = next;
      _recompute();
    }, fireImmediately: true);

    _hotspotsSub = ref.listen<AsyncValue<List<Hotspot>>>(hotspotsProvider, (previous, next) {
      next.whenData((list) {
        _hotspots = list;
        _recompute();
      });
    }, fireImmediately: true);
  }

  void _recompute() {
    final position = _position;
    if (position == null) return;

    final geofence = ref.read(geofenceUiControllerProvider.notifier);
    for (final hotspot in _hotspots) {
      final meters = _distance.as(LengthUnit.Meter, position, hotspot.location);
      final isInside = meters <= hotspot.radiusMeters;
      final wasInside = _inside.contains(hotspot.id);

      if (isInside && !wasInside) {
        _inside.add(hotspot.id);
        geofence.simulateEnter(hotspot.id);
      } else if (!isInside && wasInside) {
        _inside.remove(hotspot.id);
        geofence.simulateExit(hotspot.id);
      }
    }
  }

  void dispose() {
    _positionSub.close();
    _hotspotsSub.close();
  }
}

final hotspotProximityWatcherProvider = Provider<HotspotProximityWatcher>((ref) {
  final watcher = HotspotProximityWatcher(ref);
  ref.onDispose(watcher.dispose);
  return watcher;
});
