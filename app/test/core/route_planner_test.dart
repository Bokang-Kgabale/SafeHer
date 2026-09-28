import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:safeher/core/algorithms/route_planner.dart';
import 'package:safeher/core/models/hotspot.dart';

Hotspot _hotspot(String id, LatLng location, {double radiusMeters = 150}) {
  return Hotspot(
    id: id,
    location: location,
    category: HotspotCategory.robbery,
    reporterId: 'test-reporter',
    timestamp: DateTime(2026, 1, 1),
    radiusMeters: radiusMeters,
  );
}

void main() {
  group('RoutePlanner', () {
    const planner = RoutePlanner();
    // ~111m per 0.001 degree of latitude — small, deterministic offsets.
    const origin = LatLng(-29.1000, 26.2000);
    const destination = LatLng(-29.1000, 26.2100); // ~965m due east

    test('no hotspot near the path returns the default route unchanged', () {
      final result = planner.plan(
        origin: origin,
        destination: destination,
        hotspots: [_hotspot('far', const LatLng(-29.1200, 26.2000))],
      );

      expect(result.avoidedHotspotIds, isEmpty);
      expect(result.recommendedRoute, result.defaultRoute);
      expect(result.warning, isNull);
    });

    test('a hotspot directly on the path is avoided by a detour', () {
      final midpoint = const LatLng(-29.1000, 26.2050);
      final result = planner.plan(
        origin: origin,
        destination: destination,
        hotspots: [_hotspot('mid', midpoint, radiusMeters: 100)],
      );

      expect(result.avoidedHotspotIds, ['mid']);
      expect(result.recommendedRoute.length, greaterThan(2));
      expect(result.warning, isNull);

      // The recommended route must not itself pass back through the hotspot.
      final replanned = planner.plan(
        origin: result.recommendedRoute.first,
        destination: result.recommendedRoute.last,
        hotspots: [_hotspot('mid', midpoint, radiusMeters: 100)],
      );
      expect(_intersectsAlongPolyline(result.recommendedRoute, midpoint, 100), isFalse);
      // (Guards against a false-pass if the test fixture itself were wrong.)
      expect(replanned.recommendedRoute, isNotEmpty);
    });

    test('destination inside a hotspot is still routed to, with a warning', () {
      final result = planner.plan(
        origin: origin,
        destination: destination,
        hotspots: [_hotspot('at-dest', destination, radiusMeters: 200)],
      );

      expect(result.recommendedRoute.last, destination);
      expect(result.warning, 'destination_in_flagged_area');
    });

    test('a hotspot with no reasonable detour falls back to the default route with a warning', () {
      // A centred obstacle's perpendicular-detour ratio approaches sqrt(2)
      // (~1.41x) as its radius approaches half the origin-destination
      // distance, and can never legitimately exceed that for a single
      // centred circle — so exercising the "detour too long" rejection
      // needs a stricter ratio than the default (which is deliberately
      // lenient for normal use), not just a bigger radius. A bigger radius
      // alone would instead start overlapping the destination itself,
      // which is the *other* edge case (tested above) — kept distinct here
      // by staying well clear of it (this hotspot's radius, 300m, is far
      // short of the ~482m to either endpoint).
      const strictPlanner = RoutePlanner(maxDetourRatio: 1.1);
      final midpoint = const LatLng(-29.1000, 26.2050);
      final result = strictPlanner.plan(
        origin: origin,
        destination: destination,
        hotspots: [_hotspot('blocking', midpoint, radiusMeters: 300)],
      );

      expect(result.recommendedRoute, result.defaultRoute);
      expect(result.avoidedHotspotIds, isEmpty);
      expect(result.warning, 'route_passes_through_flagged_area');
    });

    test('multiple hotspots along the path are each detoured around', () {
      final first = const LatLng(-29.1000, 26.2030);
      final second = const LatLng(-29.1000, 26.2070);
      final result = planner.plan(
        origin: origin,
        destination: destination,
        hotspots: [
          _hotspot('first', first, radiusMeters: 80),
          _hotspot('second', second, radiusMeters: 80),
        ],
      );

      expect(result.avoidedHotspotIds.toSet(), {'first', 'second'});
      expect(result.warning, isNull);
    });

    group('firstIntersectingHotspot (re-check for real, road-snapped routes)', () {
      // Covers the real bug this method exists to catch: a straight-line
      // simulation clearing a hotspot is not proof that a real road-snapped
      // version of the same waypoints does too — a street can curve back
      // through the exact area a perpendicular detour avoided.
      test('returns null for a polyline that stays clear of every hotspot', () {
        final farHotspot = _hotspot('far', const LatLng(-29.1200, 26.2000));
        final route = [origin, const LatLng(-29.1000, 26.2050), destination];

        expect(planner.firstIntersectingHotspot(route, [farHotspot]), isNull);
      });

      test('detects a hotspot that a multi-point polyline curves back through', () {
        final hotspot = _hotspot('curve-back', const LatLng(-29.1005, 26.2050), radiusMeters: 60);
        // Simulates a road that loops away from the hotspot then back
        // through it — exactly the shape a straight two-point check would
        // never see, since neither endpoint pair alone crosses it.
        final roadLikeRoute = [
          origin,
          const LatLng(-29.0980, 26.2030), // detours north, clear
          const LatLng(-29.1005, 26.2050), // curves back — straight onto the hotspot centre
          const LatLng(-29.0980, 26.2070), // back north again
          destination,
        ];

        expect(planner.firstIntersectingHotspot(roadLikeRoute, [hotspot]), same(hotspot));
      });
    });
  });
}

/// Test-only helper mirroring the planner's own point-to-segment check, used
/// to independently verify a returned polyline actually clears a hotspot —
/// kept deliberately simple (equirectangular + planar distance) rather than
/// reaching into the planner's private geometry helpers.
bool _intersectsAlongPolyline(List<LatLng> route, LatLng center, double radiusMeters) {
  const distance = Distance();
  for (var i = 0; i < route.length - 1; i++) {
    // Coarse sampling along the segment is enough for a test assertion at
    // this scale (segments are hundreds of metres, samples every ~10%).
    for (var t = 0.0; t <= 1.0; t += 0.1) {
      final lat = route[i].latitude + (route[i + 1].latitude - route[i].latitude) * t;
      final lng = route[i].longitude + (route[i + 1].longitude - route[i].longitude) * t;
      if (distance.as(LengthUnit.Meter, LatLng(lat, lng), center) < radiusMeters) {
        return true;
      }
    }
  }
  return false;
}
