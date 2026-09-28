import 'dart:async';
import 'dart:math' show pi, sin;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';

import '../../core/models/hotspot.dart';

/// Animated ("breathing") crime-density heatmap layer, built from the same
/// hotspot list the map's pin markers already use. Purely a visual overview
/// — the geofence engine reasons about individual hotspot radii, not this
/// layer, so nothing safety-critical depends on it.
///
/// The pulse is driven by a plain [Timer.periodic] rather than an
/// [AnimationController]/[Ticker]: the underlying `flutter_map_heatmap`
/// package only repaints when its `reset` stream fires (it caches rendered
/// tiles by a pseudo-URL otherwise), so there is no benefit to a 60fps
/// animation clock here — sampling at a few times a second is what actually
/// produces visible frames, so that's the real cadence used throughout.
class AnimatedCrimeHeatmapLayer extends StatefulWidget {
  final List<Hotspot> hotspots;

  const AnimatedCrimeHeatmapLayer({super.key, required this.hotspots});

  @override
  State<AnimatedCrimeHeatmapLayer> createState() => _AnimatedCrimeHeatmapLayerState();
}

class _AnimatedCrimeHeatmapLayerState extends State<AnimatedCrimeHeatmapLayer> {
  // Wide swings on both radius and opacity — an earlier version used a much
  // narrower range (26-42, opacity 0.5-0.8) that real-device testing showed
  // was too subtle to actually read as "animated" rather than just a static
  // heatmap. This is deliberately a strong, unmissable pulse.
  static const _minRadius = 16.0;
  static const _maxRadius = 60.0;
  static const _minOpacity = 0.25;
  static const _maxOpacity = 1.0;
  static const _tickInterval = Duration(milliseconds: 150);
  static const _phaseStepPerTick = pi / 5; // 10 ticks/cycle * 150ms = 1.5s pulse period

  late final HeatMapOptions _options;
  final _resetController = StreamController<void>.broadcast();
  Timer? _ticker;
  double _phase = 0;

  @override
  void initState() {
    super.initState();
    _options = HeatMapOptions(radius: _minRadius, minOpacity: 0.2, blurFactor: 0.75);
    _ticker = Timer.periodic(_tickInterval, (_) => _pulse());
  }

  void _pulse() {
    _phase += _phaseStepPerTick;
    final t = (sin(_phase) + 1) / 2; // 0..1
    _options
      ..radius = _minRadius + (_maxRadius - _minRadius) * t
      ..layerOpacity = _minOpacity + (_maxOpacity - _minOpacity) * t;
    if (!_resetController.isClosed) _resetController.add(null);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _resetController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.hotspots.isEmpty) return const SizedBox.shrink();

    final data = widget.hotspots
        .map((h) => WeightedLatLng(h.location, _severityWeight(h.category)))
        .toList();

    return IgnorePointer(
      child: HeatMapLayer(
        heatMapDataSource: InMemoryHeatMapDataSource(data: data),
        heatMapOptions: _options,
        reset: _resetController.stream,
        // Shorter than the tick interval so each pulse frame fully settles
        // before the next one starts, rather than perpetually crossfading
        // and smoothing the pulse into near-invisibility.
        tileDisplay: const TileDisplay.fadeIn(duration: Duration(milliseconds: 100)),
      ),
    );
  }

  /// Weights denser/more severe categories higher so the heatmap reads as a
  /// genuine risk overview, not just a count of pins.
  double _severityWeight(HotspotCategory category) {
    switch (category) {
      case HotspotCategory.assault:
        return 1.0;
      case HotspotCategory.robbery:
        return 0.85;
      case HotspotCategory.harassment:
        return 0.65;
      case HotspotCategory.noLighting:
        return 0.5;
      case HotspotCategory.other:
        return 0.4;
    }
  }
}
