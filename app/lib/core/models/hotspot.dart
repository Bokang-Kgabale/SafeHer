import 'package:latlong2/latlong.dart';

enum HotspotCategory { robbery, harassment, assault, noLighting, other }

enum HotspotVerificationStatus { published, flagged, disputed, removed }

class Hotspot {
  final String id;
  final LatLng location;
  final HotspotCategory category;
  final String? description;
  final String reporterId;
  final DateTime timestamp;
  final HotspotVerificationStatus verificationStatus;
  final double radiusMeters;

  /// Local file path (mobile) or storage URL (once wired to a real backend)
  /// of an optional photo attached to the report — evidence that helps a
  /// viewer judge severity at a glance instead of relying on the category +
  /// free-text description alone. Never required (FR-HS's category is the
  /// only mandatory field); a report with no camera access or no desire to
  /// take a photo must still publish normally.
  final String? photoPath;

  const Hotspot({
    required this.id,
    required this.location,
    required this.category,
    required this.reporterId,
    required this.timestamp,
    this.description,
    this.verificationStatus = HotspotVerificationStatus.published,
    this.radiusMeters = 150,
    this.photoPath,
  });

  Hotspot copyWith({HotspotVerificationStatus? verificationStatus}) => Hotspot(
        id: id,
        location: location,
        category: category,
        description: description,
        reporterId: reporterId,
        timestamp: timestamp,
        verificationStatus: verificationStatus ?? this.verificationStatus,
        radiusMeters: radiusMeters,
        photoPath: photoPath,
      );
}
