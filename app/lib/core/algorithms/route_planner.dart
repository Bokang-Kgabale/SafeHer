import 'dart:math' show cos, sqrt;

import 'package:latlong2/latlong.dart';

import '../models/hotspot.dart';

class RoutePlanResult {
  final List<LatLng> defaultRoute;
  final List<LatLng> recommendedRoute;
  final List<String> avoidedHotspotIds;

  /// Set when the recommended route could not avoid every flagged area
  /// (either no reasonable detour exists, or the destination itself sits
  /// inside a hotspot) — the UI must surface this, not silently claim safety
  /// it can't back up (Algorithm Test Plan §6.3, SRS v1.2 §2.8's "no false
  /// promises" principle applied to routing, not just the panic pipeline).
  final String? warning;

  /// True once [defaultRoute]/[recommendedRoute] have been snapped to real
  /// streets via [OsrmRoutingService] — false means these are still this
  /// class's own straight-line simulation (no network, or the request
  /// failed), which the UI must also disclose rather than silently show a
  /// straight line as if it were a real route.
  final bool isRoadAccurate;

  const RoutePlanResult({
    required this.defaultRoute,
    required this.recommendedRoute,
    required this.avoidedHotspotIds,
    this.warning,
    this.isRoadAccurate = false,
  });
}

/// FR-RT's hotspot-avoiding routing logic (Algorithm Test Plan §6): computes
/// a straight-line route and detours around any hotspot circle that line
/// crosses. On its own this is a **simulation**, not real road routing — the
/// waypoints it produces (origin, any detour point(s), destination) are
/// meant to be handed to a real router (see [OsrmRoutingService]) to snap
/// each leg onto actual streets, which is what `MapScreen` does. This class
/// stays pure/synchronous/network-free on purpose so the avoidance logic
/// itself stays exhaustively unit-testable regardless of network conditions.
///
/// Geometry is done in a local planar (equirectangular) projection centred on
/// the origin, which is accurate enough at city scale (a few km) without
/// pulling in a full geodesy library.
class RoutePlanner {
  final double detourMarginMeters;
  final double maxDetourRatio;
  final int maxIterations;

  const RoutePlanner({
    this.detourMarginMeters = 30,
    this.maxDetourRatio = 1.6,
    this.maxIterations = 4,
  });

  RoutePlanResult plan({
    required LatLng origin,
    required LatLng destination,
    required List<Hotspot> hotspots,
  }) {
    final defaultRoute = [origin, destination];
    final destinationHotspot = _hotspotContaining(destination, hotspots);

    // A hotspot containing the destination can never be "avoided" — the
    // route has to end there regardless. Excluding it from the
    // detour/intersection loop is what lets that case surface as its own
    // warning instead of being (wrongly) treated as an unavoidable-route
    // failure identical to a hotspot blocking the middle of the path.
    final routableHotspots = destinationHotspot == null
        ? hotspots
        : hotspots.where((h) => h.id != destinationHotspot.id).toList();

    var route = defaultRoute;
    final avoided = <String>{};

    for (var iteration = 0; iteration < maxIterations; iteration++) {
      final intersecting = _firstIntersectingHotspot(route, routableHotspots);
      if (intersecting == null) break;

      route = _insertDetour(route, intersecting);
      avoided.add(intersecting.id);
    }

    final stillIntersects = _firstIntersectingHotspot(route, routableHotspots) != null;
    final tooLong = _pathLength(route) > _pathLength(defaultRoute) * maxDetourRatio;

    if (stillIntersects || tooLong) {
      return RoutePlanResult(
        defaultRoute: defaultRoute,
        recommendedRoute: defaultRoute,
        avoidedHotspotIds: const [],
        warning: 'route_passes_through_flagged_area',
      );
    }

    return RoutePlanResult(
      defaultRoute: defaultRoute,
      recommendedRoute: route,
      avoidedHotspotIds: avoided.toList(),
      warning: destinationHotspot != null ? 'destination_in_flagged_area' : null,
    );
  }

  /// Re-checks an arbitrary polyline (e.g. a real road-snapped route from
  /// [OsrmRoutingService]) against [hotspots] for any intersection.
  ///
  /// This exists because [plan]'s own avoidance check only proves the
  /// **straight-line simulation** clears every hotspot — snapping those same
  /// waypoints onto real streets can still produce a path that curves back
  /// through a flagged area the straight-line detour cleared. Skipping this
  /// re-check was a real bug: the app was telling a route "safe" based only
  /// on geometry that was never actually shown to the user, while the real
  /// road-following line she'd walk could still cut straight through the
  /// hotspot. Every route actually displayed must be checked as drawn, not
  /// just as originally planned.
  Hotspot? firstIntersectingHotspot(List<LatLng> route, List<Hotspot> hotspots) =>
      _firstIntersectingHotspot(route, hotspots);

  /// Public wrapper for [_hotspotContaining] — lets a caller (e.g.
  /// `MapScreen`'s road-route re-check) exclude an unavoidable
  /// destination-hotspot from a *separate* intersection check the same way
  /// [plan] already does internally, instead of that check re-flagging the
  /// unavoidable "route ends inside a hotspot" case as if it were a detour
  /// failure and clobbering the more specific `destination_in_flagged_area`
  /// warning with the generic one.
  Hotspot? hotspotContaining(LatLng point, List<Hotspot> hotspots) =>
      _hotspotContaining(point, hotspots);

  Hotspot? _hotspotContaining(LatLng point, List<Hotspot> hotspots) {
    for (final h in hotspots) {
      if (const Distance().as(LengthUnit.Meter, point, h.location) <= h.radiusMeters) {
        return h;
      }
    }
    return null;
  }

  Hotspot? _firstIntersectingHotspot(List<LatLng> route, List<Hotspot> hotspots) {
    for (var i = 0; i < route.length - 1; i++) {
      final a = _project(route[i], route[0]);
      final b = _project(route[i + 1], route[0]);
      for (final hotspot in hotspots) {
        final h = _project(hotspot.location, route[0]);
        final dist = _pointToSegmentDistance(h, a, b);
        if (dist <= hotspot.radiusMeters) return hotspot;
      }
    }
    return null;
  }

  /// Replaces whichever segment of [route] crosses [hotspot] with a
  /// two-segment detour around it, offset perpendicular to the original
  /// direction of travel by the hotspot's radius plus a safety margin.
  List<LatLng> _insertDetour(List<LatLng> route, Hotspot hotspot) {
    for (var i = 0; i < route.length - 1; i++) {
      final origin = route[0];
      final a = _project(route[i], origin);
      final b = _project(route[i + 1], origin);
      final h = _project(hotspot.location, origin);
      final dist = _pointToSegmentDistance(h, a, b);
      if (dist > hotspot.radiusMeters) continue;

      final abx = b.x - a.x, aby = b.y - a.y;
      final length = sqrt(abx * abx + aby * aby);
      if (length == 0) continue;
      final ux = abx / length, uy = aby / length;
      // Perpendicular to the direction of travel, either side.
      final perpX = -uy, perpY = ux;
      final offset = hotspot.radiusMeters + detourMarginMeters;

      // Deterministically detour to the right of the direction of travel.
      // A real router would pick whichever side is actually clear of other
      // hazards/roads; this simulation doesn't model that, so it always
      // tries one side first and relies on the caller's iteration loop (plus
      // the final re-check in `plan()`) to catch and reject a detour that
      // happens to clip a neighbouring hotspot instead.
      final chosen = _Vec2(h.x + perpX * offset, h.y + perpY * offset);
      final detourPoint = _unproject(chosen, origin);
      return [...route.sublist(0, i + 1), detourPoint, ...route.sublist(i + 1)];
    }
    return route;
  }

  double _pathLength(List<LatLng> route) {
    const distance = Distance();
    var total = 0.0;
    for (var i = 0; i < route.length - 1; i++) {
      total += distance.as(LengthUnit.Meter, route[i], route[i + 1]);
    }
    return total;
  }

  _Vec2 _project(LatLng point, LatLng reference) {
    const metersPerDegreeLat = 111320.0;
    final metersPerDegreeLng = 111320.0 * cos(reference.latitude * pi / 180);
    return _Vec2(
      (point.longitude - reference.longitude) * metersPerDegreeLng,
      (point.latitude - reference.latitude) * metersPerDegreeLat,
    );
  }

  LatLng _unproject(_Vec2 v, LatLng reference) {
    const metersPerDegreeLat = 111320.0;
    final metersPerDegreeLng = 111320.0 * cos(reference.latitude * pi / 180);
    return LatLng(
      reference.latitude + v.y / metersPerDegreeLat,
      reference.longitude + v.x / metersPerDegreeLng,
    );
  }

  double _pointToSegmentDistance(_Vec2 p, _Vec2 a, _Vec2 b) {
    final abx = b.x - a.x, aby = b.y - a.y;
    final apx = p.x - a.x, apy = p.y - a.y;
    final abLenSq = abx * abx + aby * aby;
    final t = abLenSq == 0 ? 0.0 : ((apx * abx + apy * aby) / abLenSq).clamp(0.0, 1.0);
    final closestX = a.x + t * abx, closestY = a.y + t * aby;
    final dx = p.x - closestX, dy = p.y - closestY;
    return sqrt(dx * dx + dy * dy);
  }
}

class _Vec2 {
  final double x;
  final double y;
  const _Vec2(this.x, this.y);
}
