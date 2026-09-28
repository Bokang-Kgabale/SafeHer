import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

import '../../app/hotspot_proximity_watcher.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/algorithms/route_planner.dart';
import '../../core/models/emergency_facility.dart';
import '../../core/models/hotspot.dart';
import '../../l10n/generated/app_localizations.dart';
import '../activity/activity_screen.dart';
import '../contacts/contacts_screen.dart';
import '../panic/fall_countdown_banner.dart';
import '../panic/geofence_countdown_banner.dart';
import '../panic/panic_button.dart';
import 'animated_crime_heatmap_layer.dart';
import 'hotspot_style.dart';
import 'map_settings_sheet.dart';
import 'quick_actions_bar.dart';
import 'report_hotspot_sheet.dart';

class MapScreen extends ConsumerWidget {
  /// Overridable for tests, which have no real network access — defaults to
  /// flutter_map's normal [NetworkTileProvider] otherwise.
  final TileProvider? tileProvider;

  const MapScreen({super.key, this.tileProvider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hotspots = ref.watch(hotspotsProvider);
    final facilities = ref.watch(facilitiesProvider);
    final currentPosition = ref.watch(currentPositionControllerProvider);
    final isFallDetectionEnabled = ref.watch(fallDetectionEnabledProvider);
    final isVoiceTriggerEnabled = ref.watch(voiceTriggerEnabledProvider);
    final showHeatmap = ref.watch(showHeatmapProvider);
    final routePlanMode = ref.watch(routePlanModeProvider);
    final routeResult = ref.watch(routePlanResultProvider);
    final reportMode = ref.watch(reportModeProvider);
    final isPlanningRoute = ref.watch(isPlanningRouteProvider);

    // Activating this provider (return value unused) wires real position +
    // hotspot updates into the geofence engine for as long as this screen is
    // on-screen — see HotspotProximityWatcher's doc comment.
    ref.watch(hotspotProximityWatcherProvider);
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shield_rounded, size: 22),
            const SizedBox(width: 8),
            Text(t.appTitle),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: t.mapSettingsTooltip,
            onPressed: () => showMapSettingsSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.contacts),
            tooltip: t.nextOfKinTooltip,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ContactsScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: t.activityTooltip,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ActivityScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const _PreviewModeBanner(),
          const QuickActionsBar(),
          _AnimatedBanner(
            visible: isFallDetectionEnabled || isVoiceTriggerEnabled,
            child: _ExperimentalFeatureBanner(
              fallDetection: isFallDetectionEnabled,
              voiceTrigger: isVoiceTriggerEnabled,
            ),
          ),
          const GeofenceCountdownBanner(),
          const FallCountdownBanner(),
          _AnimatedBanner(visible: reportMode, child: const _ReportModeHintBanner()),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.topCenter,
            child: isPlanningRoute
                ? const LinearProgressIndicator(minHeight: 3)
                : const SizedBox(width: double.infinity),
          ),
          _AnimatedBanner(
            visible: !isPlanningRoute && routePlanMode && routeResult == null,
            child: const _RoutePlanHintBanner(),
          ),
          // Deliberately independent conditions, not an else-if chain: a
          // route can be BOTH not-yet-road-verified AND known (from the
          // straight-line simulation) to still cut through a flagged area.
          // Previously these were mutually exclusive, so a route with a real
          // safety warning would silently show only the generic offline
          // notice instead — the exact "doesn't flag anything" failure mode.
          // The warning must always surface once it exists, network or not.
          _AnimatedBanner(
            visible: !isPlanningRoute && routeResult != null && !routeResult.isRoadAccurate,
            child: const _RouteOfflineBanner(),
          ),
          _AnimatedBanner(
            visible: !isPlanningRoute && routeResult?.warning != null,
            child: _RouteWarningBanner(warning: routeResult?.warning ?? ''),
          ),
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: currentPosition,
                initialZoom: 14,
                onLongPress: (tapPosition, point) => _reportHotspotAt(context, ref, point),
                onTap: (tapPosition, point) {
                  if (reportMode) {
                    _reportHotspotAt(context, ref, point);
                  } else if (routePlanMode) {
                    _planRouteTo(context, ref, currentPosition, point);
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'co.za.nexmotiontechnologies.safeher',
                  tileProvider: tileProvider,
                  // Swallow tile-fetch failures instead of letting them spam the
                  // console — matters for offline/degraded connectivity on a
                  // real device (NFR-3).
                  errorTileCallback: (tile, error, stackTrace) {},
                ),
                if (showHeatmap)
                  AnimatedCrimeHeatmapLayer(hotspots: hotspots.asData?.value ?? const []),
                if (routeResult != null)
                  PolylineLayer(
                    polylines: [
                      // Only draw the default line where it actually differs
                      // from the recommended one, so a route with no
                      // detour needed doesn't show two overlapping strokes.
                      if (!_sameRoute(routeResult.defaultRoute, routeResult.recommendedRoute))
                        Polyline(
                          points: routeResult.defaultRoute,
                          strokeWidth: 3,
                          color: Colors.grey.shade600,
                          pattern: StrokePattern.dashed(segments: const [10.0, 8.0]),
                        ),
                      Polyline(
                        points: routeResult.recommendedRoute,
                        strokeWidth: 5,
                        color: routeResult.warning == null
                            ? SafeHerColors.safe
                            : SafeHerColors.warning,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: currentPosition,
                      width: 44,
                      height: 44,
                      child: const _CurrentPositionMarker(),
                    ),
                    if (routeResult != null)
                      Marker(
                        point: routeResult.recommendedRoute.last,
                        width: 36,
                        height: 36,
                        child: Icon(Icons.flag_rounded, color: SafeHerColors.violetDark, size: 32),
                      ),
                    ...facilities.maybeWhen(
                      data: (list) => list.map((facility) => Marker(
                            point: facility.location,
                            width: 40,
                            height: 40,
                            child: _FacilityMarker(facility: facility),
                          )),
                      orElse: () => const <Marker>[],
                    ),
                    ...hotspots.maybeWhen(
                      data: (list) => list.map((hotspot) => Marker(
                            point: hotspot.location,
                            width: 44,
                            height: 44,
                            child: GestureDetector(
                              onTap: () => _showHotspotSheet(context, ref, hotspot),
                              child: _HotspotMarker(hotspot: hotspot),
                            ),
                          )),
                      orElse: () => const <Marker>[],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: const PanicButton(),
    );
  }

  /// Escalating detour margins to retry with if the *real* road-snapped
  /// route still clips a hotspot the straight-line simulation thought it had
  /// cleared (see [RoutePlanner.firstIntersectingHotspot]'s doc comment for
  /// why that can happen — real streets don't follow a straight perpendicular
  /// offset).
  static const _detourMarginRetriesMeters = [30.0, 80.0, 160.0];

  Future<void> _planRouteTo(
    BuildContext context,
    WidgetRef ref,
    LatLng origin,
    LatLng destination,
  ) async {
    final hotspots = ref.read(hotspotsProvider).asData?.value ?? const [];
    final osrm = ref.read(osrmRoutingServiceProvider);

    // A hotspot the destination itself sits inside can never be "avoided" —
    // the route has to end there regardless, so it's excluded from the
    // road-accurate re-check below the same way `RoutePlanner.plan` already
    // excludes it from its own straight-line check. Without this, the
    // re-check's own last segment (ending inside that hotspot) always
    // reports an intersection, clobbering the specific
    // `destination_in_flagged_area` warning with the generic "no detour
    // avoids this" one.
    const planner0 = RoutePlanner();
    final destinationHotspot = planner0.hotspotContaining(destination, hotspots);
    final routableHotspots = destinationHotspot == null
        ? hotspots
        : hotspots.where((h) => h.id != destinationHotspot.id).toList();

    // Straight-line simulation first, shown immediately so the tap feels
    // responsive while the real road route is fetched below.
    var result = planner0.plan(origin: origin, destination: destination, hotspots: hotspots);
    ref.read(routePlanResultProvider.notifier).state = result;
    ref.read(isPlanningRouteProvider.notifier).state = true;

    List<LatLng>? roadRecommended;
    var roadStillIntersects = false;

    for (final margin in _detourMarginRetriesMeters) {
      final planner = RoutePlanner(detourMarginMeters: margin);
      result = planner.plan(origin: origin, destination: destination, hotspots: hotspots);

      roadRecommended = await osrm.fetchRoadRoute(result.recommendedRoute);
      if (roadRecommended == null) break; // no network at all — stop, fall back below

      // The critical re-check: does the ACTUAL road-following line still cut
      // through a hotspot, regardless of what the straight-line simulation
      // predicted? This is what was missing before — the app was declaring a
      // route safe based on geometry it never actually drew.
      roadStillIntersects =
          planner.firstIntersectingHotspot(roadRecommended, routableHotspots) != null;
      if (!roadStillIntersects) break;
    }

    final detourNeeded = !_sameRoute(result.defaultRoute, result.recommendedRoute);
    final roadDefault =
        detourNeeded ? await osrm.fetchRoadRoute(result.defaultRoute) : roadRecommended;

    if (roadRecommended != null) {
      result = RoutePlanResult(
        defaultRoute: roadDefault ?? result.defaultRoute,
        recommendedRoute: roadRecommended,
        avoidedHotspotIds: roadStillIntersects ? const [] : result.avoidedHotspotIds,
        // The real-road intersection takes priority over whatever the
        // straight-line simulation concluded — it's a strictly more accurate
        // finding about the path actually being shown to her.
        warning: roadStillIntersects ? 'route_passes_through_flagged_area' : result.warning,
        isRoadAccurate: true,
      );
    }

    ref.read(isPlanningRouteProvider.notifier).state = false;
    // The tap may have toggled route mode off while the request was in
    // flight (e.g. the user gave up waiting) — don't resurrect a result for
    // a mode that's no longer active.
    if (ref.read(routePlanModeProvider)) {
      ref.read(routePlanResultProvider.notifier).state = result;
    }

    if (roadRecommended == null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).noNetworkRouteSnackbar)),
      );
    }
  }

  bool _sameRoute(List<LatLng> a, List<LatLng> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Future<void> _reportHotspotAt(BuildContext context, WidgetRef ref, LatLng point) async {
    final currentLocation = ref.read(currentPositionControllerProvider);
    final result = await showReportHotspotSheet(
      context,
      tappedLocation: point,
      currentLocation: currentLocation,
    );
    if (result == null) return;

    final services = ref.read(appServicesProvider);
    await services.hotspotRepository.report(Hotspot(
      id: const Uuid().v4(),
      location: result.location,
      category: result.category,
      description: result.description,
      reporterId: services.currentUserId,
      timestamp: DateTime.now(),
      photoPath: result.photoPath,
    ));

    // One-shot: leave report mode once a pin is actually placed, so the next
    // ordinary tap doesn't also drop a pin. A cancelled sheet leaves the mode
    // on so the user can retry without re-toggling it.
    ref.read(reportModeProvider.notifier).state = false;

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).hotspotPublishedSnackbar)),
      );
    }
  }

  void _showHotspotSheet(BuildContext context, WidgetRef ref, Hotspot hotspot) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final t = AppLocalizations.of(context);
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(iconForCategory(hotspot.category), color: SafeHerColors.danger),
                  const SizedBox(width: 8),
                  Text(labelForCategory(context, hotspot.category),
                      style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
              if (hotspot.description != null) ...[
                const SizedBox(height: 8),
                Text(hotspot.description!),
              ],
              if (hotspot.photoPath != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.file(
                    File(hotspot.photoPath!),
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                t.hotspotSheetDemoNote,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.directions_walk),
                  label: Text(t.hotspotSheetSimulateButton),
                  onPressed: () {
                    ref.read(geofenceUiControllerProvider.notifier).simulateEnter(hotspot.id);
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Wraps a banner so it grows/shrinks into view instead of instantly
/// popping in or vanishing — the widget stays mounted at zero height when
/// not visible (rather than being added/removed from the parent Column's
/// children), which is what lets [AnimatedSize] actually animate the
/// transition instead of just snapping between two layouts.
class _AnimatedBanner extends StatelessWidget {
  final bool visible;
  final Widget child;

  const _AnimatedBanner({required this.visible, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: visible ? child : const SizedBox(width: double.infinity),
    );
  }
}

/// Shared visual shell for every full-width map banner, so tone (color +
/// icon) is the only thing each call site decides — keeps the growing list
/// of banners (preview mode, report/route hints, offline, warning,
/// experimental features) reading as one consistent system instead of each
/// picking its own ad hoc `Container`.
class _InfoBanner extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;
  final Color? foreground;

  const _InfoBanner({
    required this.color,
    required this.icon,
    required this.text,
    this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    final fg = foreground ?? Colors.white;
    return Container(
      width: double.infinity,
      color: color,
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 12),
      child: Row(
        children: [
          Icon(icon, color: fg, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.left,
              style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoutePlanHintBanner extends StatelessWidget {
  const _RoutePlanHintBanner();

  @override
  Widget build(BuildContext context) {
    return _InfoBanner(
      color: SafeHerColors.info,
      icon: Icons.alt_route,
      text: AppLocalizations.of(context).routePlanHint,
    );
  }
}

class _ReportModeHintBanner extends StatelessWidget {
  const _ReportModeHintBanner();

  @override
  Widget build(BuildContext context) {
    return _InfoBanner(
      color: SafeHerColors.magenta,
      icon: Icons.add_location_alt,
      text: AppLocalizations.of(context).reportModeHint,
    );
  }
}

class _RouteOfflineBanner extends StatelessWidget {
  const _RouteOfflineBanner();

  @override
  Widget build(BuildContext context) {
    return _InfoBanner(
      color: const Color(0xFF5C5568),
      icon: Icons.cloud_off,
      text: AppLocalizations.of(context).routeOfflineBanner,
    );
  }
}

class _RouteWarningBanner extends StatelessWidget {
  final String warning;

  const _RouteWarningBanner({required this.warning});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final message = switch (warning) {
      'destination_in_flagged_area' => t.routeWarningDestinationInFlagged,
      'route_passes_through_flagged_area' => t.routeWarningPassesThrough,
      _ => t.routeWarningGeneric,
    };

    return _InfoBanner(
      color: SafeHerColors.warning,
      icon: Icons.warning_amber_rounded,
      text: message,
    );
  }
}

class _PreviewModeBanner extends StatelessWidget {
  const _PreviewModeBanner();

  @override
  Widget build(BuildContext context) {
    return _InfoBanner(
      color: SafeHerColors.violetDark,
      icon: Icons.science_outlined,
      text: AppLocalizations.of(context).previewModeBanner,
    );
  }
}

/// Persistent (not just a tooltip) reminder that an experimental, unverified
/// trigger is live — per SRS v1.2 §2.8's tiering, these must never be mistaken
/// for MVP-verified capability, and a tooltip nobody hovers over isn't a
/// strong enough signal for a safety-critical distinction.
class _ExperimentalFeatureBanner extends StatelessWidget {
  final bool fallDetection;
  final bool voiceTrigger;

  const _ExperimentalFeatureBanner({required this.fallDetection, required this.voiceTrigger});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final active = [
      if (fallDetection) t.quickActionFallDetection,
      if (voiceTrigger) t.quickActionVoiceTrigger,
    ].join(' + ');

    return _InfoBanner(
      color: Colors.black87,
      icon: Icons.science,
      foreground: Colors.amberAccent,
      text: t.experimentalBanner(active),
    );
  }
}

/// Pulsing-style "you are here" marker — a soft violet halo that ripples
/// outward behind a solid dot reads as unmistakably *live* against both the
/// OSM tile colors and the route lines, unlike a static plain Material icon.
class _CurrentPositionMarker extends StatefulWidget {
  const _CurrentPositionMarker();

  @override
  State<_CurrentPositionMarker> createState() => _CurrentPositionMarkerState();
}

class _CurrentPositionMarkerState extends State<_CurrentPositionMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final t = _controller.value;
            return Opacity(
              opacity: (1 - t) * 0.5,
              child: Transform.scale(
                scale: 0.4 + t * 0.9,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: SafeHerColors.violet,
                  ),
                ),
              ),
            );
          },
        ),
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: SafeHerColors.violet,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 4),
            ],
          ),
        ),
      ],
    );
  }
}

/// Rounded badge marker for a reported hotspot — a filled circle in the
/// danger color reads as "flagged" at a glance, distinct from the outlined
/// facility markers and the solid current-position dot.
class _HotspotMarker extends StatelessWidget {
  final Hotspot hotspot;

  const _HotspotMarker({required this.hotspot});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: SafeHerColors.danger,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 3),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Icon(iconForCategory(hotspot.category), color: Colors.white, size: 20),
    );
  }
}

/// Rounded badge marker for a facility (police/hospital/clinic) — white fill
/// with the facility's semantic color as the icon/border, so it reads as
/// "help available here" distinctly from the solid-danger hotspot badges.
class _FacilityMarker extends StatelessWidget {
  final EmergencyFacility facility;

  const _FacilityMarker({required this.facility});

  @override
  Widget build(BuildContext context) {
    final color = colorForFacility(facility.type);
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 3),
        ],
      ),
      padding: const EdgeInsets.all(7),
      child: Icon(iconForFacility(facility.type), color: color, size: 18),
    );
  }
}
