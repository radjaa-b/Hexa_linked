// ═══════════════════════════════════════════════════════════════
//  👋 RADJA — MAINTENANCE REQUEST MODEL
//
//  This class maps between the Flutter app and your API.
//
//  toJson()   → what the app SENDS to your API (POST body)
//  fromJson() → what the app EXPECTS to receive from your API
//
//  ⚠️  The field names in toJson/fromJson must match your API
//      response keys exactly (case-sensitive).
//      e.g. if your API returns "unitNumber" instead of
//      "unit_number", update the fromJson keys to match.
// ═══════════════════════════════════════════════════════════════

class MaintenanceRequest {
  final String? id;
  final String unitNumber;
  final String category;
  final String description;
  final String priority;      // "low" | "medium" | "high"
  final DateTime? preferredDate;
  final String status;        // "pending" | "in_progress" | "resolved"
  final DateTime? createdAt;

  MaintenanceRequest({
    this.id,
    required this.unitNumber,
    required this.category,
    required this.description,
    required this.priority,
    this.preferredDate,
    this.status = 'pending',
    this.createdAt,
  });

  // RADJA: This is the JSON body sent to POST /maintenance-requests
  Map<String, dynamic> toJson() => {
        'unit_number':    unitNumber,
        'category':       category,
        'description':    description,
        'priority':       priority,
        'preferred_date': preferredDate?.toIso8601String(),
        'status':         status,
      };

  // RADJA: This parses the JSON your API returns.
  //        Make sure your response includes all these fields.
  factory MaintenanceRequest.fromJson(Map<String, dynamic> json) =>
      MaintenanceRequest(
        id:            json['id']?.toString(),
        unitNumber:    json['unit_number']    ?? '',
        category:      json['category']       ?? '',
        description:   json['description']    ?? '',
        priority:      json['priority']       ?? 'low',
        preferredDate: json['preferred_date'] != null
            ? DateTime.tryParse(json['preferred_date'])
            : null,
        status:    json['status']     ?? 'pending',
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'])
            : null,
      );
}