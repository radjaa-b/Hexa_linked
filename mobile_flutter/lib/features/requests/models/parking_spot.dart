enum SpotStatus { available, occupied }

class ParkingSpot {
  final int id;
  final String spotId;
  final String location;
  final SpotStatus status;
  final double? distanceCm;
  final String? deviceId;
  final DateTime? lastUpdated;

  const ParkingSpot({
    required this.id,
    required this.spotId,
    required this.location,
    required this.status,
    this.distanceCm,
    this.deviceId,
    this.lastUpdated,
  });

  bool get isVisitorSpot => spotId.toUpperCase().startsWith('V-');

  String? get residentId => null;

  factory ParkingSpot.fromJson(Map<String, dynamic> json) {
    final isOccupied = json['is_occupied'] == true;

    return ParkingSpot(
      id: json['id'] ?? 0,
      spotId: json['spot_code'] ?? '',
      location: json['location'] ?? 'Unknown location',
      status: isOccupied ? SpotStatus.occupied : SpotStatus.available,
      distanceCm: json['distance_cm'] == null
          ? null
          : (json['distance_cm'] as num).toDouble(),
      deviceId: json['device_id'],
      lastUpdated: json['last_updated'] == null
          ? null
          : DateTime.tryParse(json['last_updated'].toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'spot_code': spotId,
    'location': location,
    'is_occupied': status == SpotStatus.occupied,
    'distance_cm': distanceCm,
    'device_id': deviceId,
    'last_updated': lastUpdated?.toIso8601String(),
  };
}
