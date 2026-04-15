enum EmergencyType { fire, medical, intrusion, other }

class EmergencyRequest {
  final EmergencyType type;
  final DateTime timestamp;
  final String residentId;

  EmergencyRequest({
    required this.type,
    required this.residentId,
  }) : timestamp = DateTime.now();

  Map<String, dynamic> toJson() => {
    'type'       : type.name,
    'timestamp'  : timestamp.toIso8601String(),
    'residentId' : residentId,
  };
}