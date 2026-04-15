// ============================================================
//  ParkingSpot Model
//  Radja: each spot comes from your backend as a JSON object
// ============================================================

enum SpotStatus { available, occupied }

class ParkingSpot {
  final String spotId;        // e.g. "A-01", "V-05"
  final SpotStatus status;
  final String? residentId;   // null if visitor spot or available
  final bool isVisitorSpot;   // true = Row V (shared visitor parking)

  const ParkingSpot({
    required this.spotId,
    required this.status,
    required this.isVisitorSpot,
    this.residentId,
  });

  // ── Radja: map this to your backend response fields ──────
  // Example backend response:
  // {
  //   "spot_id"        : "A-01",
  //   "status"         : "occupied",    // "available" | "occupied"
  //   "resident_id"    : "res-42",      // null if visitor spot or free
  //   "is_visitor_spot": false
  // }
  factory ParkingSpot.fromJson(Map<String, dynamic> json) {
    return ParkingSpot(
      spotId:        json['spot_id'],
      isVisitorSpot: json['is_visitor_spot'] ?? false,
      residentId:    json['resident_id'],
      status: SpotStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SpotStatus.occupied,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'spot_id'         : spotId,
    'status'          : status.name,
    'resident_id'     : residentId,
    'is_visitor_spot' : isVisitorSpot,
  };
}