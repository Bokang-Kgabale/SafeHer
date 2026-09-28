import 'package:flutter/painting.dart';
import 'package:flutter_map/flutter_map.dart';

/// A [TileProvider] that never touches the network — returns flutter_map's
/// own bundled 1x1 transparent PNG for every tile. Widget tests have no real
/// network access, so using the default [NetworkTileProvider] would spend
/// every test attempting (and failing) real HTTP requests, including the
/// console noise from flutter_map cleaning up a failed in-flight fetch when
/// the widget tree tears down at test end.
class NoNetworkTileProvider extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    return MemoryImage(TileProvider.transparentImage);
  }
}
