// ═══════════════════════════════════════════════════════════════
//  👋 RADJA — VISITOR REQUEST MODEL
//
//  toJson()   → what the app SENDS to your API (POST body)
//  fromJson() → what the app EXPECTS to receive from your API
//
//  ⚠️  Match the field names below to your API response keys.
// ═══════════════════════════════════════════════════════════════

class VisitorRequest {
  final String? id;
  final String visitorName;
  final String visitorPhone;
  final DateTime visitDate;
  final String visitPurpose;  // "Personal Visit" | "Delivery" |
                               // "Contractor / Repair" | "Caregiver" |
                               // "Moving In/Out" | "Other"
  final String unitNumber;
  final String status;         // "pending" | "approved" | "denied"
  final DateTime? createdAt;

  VisitorRequest({
    this.id,
    required this.visitorName,
    required this.visitorPhone,
    required this.visitDate,
    required this.visitPurpose,
    required this.unitNumber,
    this.status = 'pending',
    this.createdAt,
  });

  // RADJA: This is the JSON body sent to POST /visitor-requests
  Map<String, dynamic> toJson() => {
        'visitor_name':  visitorName,
        'visitor_phone': visitorPhone,
        'visit_date':    visitDate.toIso8601String(),
        'visit_purpose': visitPurpose,
        'unit_number':   unitNumber,
        'status':        status,
      };

  // RADJA: This parses the JSON your API returns.
  //        Make sure your response includes all these fields.
  factory VisitorRequest.fromJson(Map<String, dynamic> json) => VisitorRequest(
        id:           json['id']?.toString(),
        visitorName:  json['visitor_name']  ?? '',
        visitorPhone: json['visitor_phone'] ?? '',
        visitDate:    DateTime.parse(json['visit_date']),
        visitPurpose: json['visit_purpose'] ?? '',
        unitNumber:   json['unit_number']   ?? '',
        status:       json['status']        ?? 'pending',
        createdAt:    json['created_at'] != null
            ? DateTime.tryParse(json['created_at'])
            : null,
      );
}