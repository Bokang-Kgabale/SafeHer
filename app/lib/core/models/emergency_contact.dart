class EmergencyContact {
  final String id;
  final String userId;
  final String name;
  final String phoneNumber;
  final int priorityOrder;
  final String? relationship;

  const EmergencyContact({
    required this.id,
    required this.userId,
    required this.name,
    required this.phoneNumber,
    required this.priorityOrder,
    this.relationship,
  });
}
