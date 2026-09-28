import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Snaps a sequence of waypoints onto real streets using OSRM's public demo
/// server, so a planned route actually follows roads instead of the straight
/// line [RoutePlanner] computes on its own.
///
/// This is the public `router.project-osrm.org` demo instance — free, no API
/// key, but not rate-limit-free or guaranteed available; it is adequate for
/// an MVP demo, not a production dependency. On any failure (no network,
/// timeout, rate limit, malformed response) this returns null and the caller
/// falls back to the straight-line simulation rather than crashing or
/// hanging — matching the same "degrade honestly, never fail silently"
/// principle applied to the panic pipeline (SRS v1.2 §2.8).
class OsrmRoutingService {
  static const _baseUrl = 'https://router.project-osrm.org/route/v1/foot';
  static const _timeout = Duration(seconds: 8);

  final http.Client _client;

  OsrmRoutingService({http.Client? client}) : _client = client ?? http.Client();

  /// Returns a road-following polyline through all [waypoints] in order
  /// (origin, any via-points, destination), or null if a real route
  /// couldn't be obtained.
  Future<List<LatLng>?> fetchRoadRoute(List<LatLng> waypoints) async {
    if (waypoints.length < 2) return null;

    final coords = waypoints.map((p) => '${p.longitude},${p.latitude}').join(';');
    final uri = Uri.parse('$_baseUrl/$coords?overview=full&geometries=geojson');

    try {
      final response = await _client.get(uri).timeout(_timeout);
      if (response.statusCode != 200) return null;

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['code'] != 'Ok') return null;

      final routes = body['routes'] as List<dynamic>?;
      if (routes == null || routes.isEmpty) return null;

      final geometry = (routes.first as Map<String, dynamic>)['geometry'] as Map<String, dynamic>;
      final coordinates = geometry['coordinates'] as List<dynamic>;

      return coordinates.map((point) {
        final pair = point as List<dynamic>;
        return LatLng((pair[1] as num).toDouble(), (pair[0] as num).toDouble());
      }).toList();
    } catch (_) {
      // Network failure, timeout, malformed JSON, unexpected shape — all
      // treated the same: no road route available right now.
      return null;
    }
  }

  void dispose() => _client.close();
}
