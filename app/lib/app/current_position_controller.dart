import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../data/preview/preview_seed_data.dart';
import 'app_services.dart';

/// Single source of truth for "where is the user right now" — either the
/// Preview Mode fixed position, or (once explicitly opted into) a real GPS
/// stream. Writes through to [AppServices.currentPosition] so
/// [PanicController]'s synchronous `locationProvider` always reads the
/// latest value.
class CurrentPositionController extends StateNotifier<LatLng> {
  final AppServices services;
  StreamSubscription<LatLng>? _subscription;
  bool _isLive = false;

  CurrentPositionController(this.services) : super(services.currentPosition);

  bool get isLive => _isLive;

  /// Returns false (without changing state) if permission was refused.
  Future<bool> enableLiveGps() async {
    final granted = await services.liveLocationService.requestPermission();
    if (!granted) return false;

    _isLive = true;
    _subscription?.cancel();
    _subscription = services.liveLocationService.watchPosition().listen((position) {
      services.currentPosition = position;
      state = position;
    });
    return true;
  }

  void disableLiveGps() {
    _isLive = false;
    _subscription?.cancel();
    _subscription = null;
    services.currentPosition = PreviewSeedData.simulatedUserPosition;
    state = services.currentPosition;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
