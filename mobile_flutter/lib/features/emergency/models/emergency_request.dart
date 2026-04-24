enum EmergencyType { fire, medical, security, noise, other }

extension EmergencyTypeApi on EmergencyType {
  String get apiValue => name;

  String get label {
    switch (this) {
      case EmergencyType.fire:
        return 'Fire';
      case EmergencyType.medical:
        return 'Medical';
      case EmergencyType.security:
        return 'Security';
      case EmergencyType.noise:
        return 'Noise';
      case EmergencyType.other:
        return 'Other';
    }
  }
}

class EmergencyRequest {
  final EmergencyType type;
  final String description;
  final String location;

  const EmergencyRequest({
    required this.type,
    this.description = '',
    this.location = '',
  });

  Map<String, dynamic> toJson() => {
    'incident_type': type.apiValue,
    'description': description,
    'location': location,
  };
}
