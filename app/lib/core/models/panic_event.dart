import 'package:latlong2/latlong.dart';

enum PanicTrigger { manual, voice, powerButton, fallDetection, geofenceTimeout }

enum PanicStatus { triggered, acknowledged, escalated, resolved, falseAlarm, unresolved }

enum NotificationChannel { call, whatsapp, sms }

class NotifiedContact {
  final String contactId;
  final NotificationChannel channel;
  final bool delivered;
  final DateTime attemptedAt;

  const NotifiedContact({
    required this.contactId,
    required this.channel,
    required this.delivered,
    required this.attemptedAt,
  });
}

class PanicEvent {
  final String id;
  final String userId;
  final LatLng location;
  final DateTime timestamp;
  final PanicTrigger triggerType;
  final PanicStatus status;
  final int escalationIndex;
  final List<NotifiedContact> notifiedContacts;

  const PanicEvent({
    required this.id,
    required this.userId,
    required this.location,
    required this.timestamp,
    required this.triggerType,
    this.status = PanicStatus.triggered,
    this.escalationIndex = 0,
    this.notifiedContacts = const [],
  });

  bool get isTerminal =>
      status == PanicStatus.resolved ||
      status == PanicStatus.falseAlarm ||
      status == PanicStatus.unresolved;

  PanicEvent copyWith({
    PanicStatus? status,
    int? escalationIndex,
    List<NotifiedContact>? notifiedContacts,
  }) =>
      PanicEvent(
        id: id,
        userId: userId,
        location: location,
        timestamp: timestamp,
        triggerType: triggerType,
        status: status ?? this.status,
        escalationIndex: escalationIndex ?? this.escalationIndex,
        notifiedContacts: notifiedContacts ?? this.notifiedContacts,
      );
}
