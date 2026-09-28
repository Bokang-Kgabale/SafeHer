import '../models/hotspot.dart';

abstract class HotspotRepository {
  /// Live stream of published hotspots. Preview Mode never touches a network;
  /// the real (Firestore) implementation wired in P1 streams from a realtime
  /// listener instead of a one-off fetch (SRS FR-MAP-2).
  Stream<List<Hotspot>> watchAll();

  Future<void> report(Hotspot hotspot);
}
