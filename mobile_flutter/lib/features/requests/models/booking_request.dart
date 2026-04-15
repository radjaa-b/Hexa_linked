// ═══════════════════════════════════════════════════════════════
//  👋 RADJA — BOOKING REQUEST MODEL
//
//  toJson()   → what the app SENDS to your API (POST body)
//  fromJson() → what the app EXPECTS to receive from your API
//
//  ⚠️  Match the field names below to your API response keys.
// ═══════════════════════════════════════════════════════════════

class BookingRequest {
  final String? id;
  final String unitNumber;
  final String areaName;      // "Gym" | "Pool" | "Rooftop" |
                               // "BBQ Area" | "Meeting Room" | "Kids Room"
  final DateTime bookingDate;
  final String startTime;     // "HH:mm" format, e.g. "09:00"
  final String endTime;       // "HH:mm" format, e.g. "10:00"
  final int guestCount;
  final String? notes;        // nullable
  final String status;        // "pending" | "approved" | "denied"
  final DateTime? createdAt;

  BookingRequest({
    this.id,
    required this.unitNumber,
    required this.areaName,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.guestCount,
    this.notes,
    this.status = 'pending',
    this.createdAt,
  });

  // RADJA: This is the JSON body sent to POST /booking-requests
  Map<String, dynamic> toJson() => {
        'unit_number':  unitNumber,
        'area_name':    areaName,
        'booking_date': bookingDate.toIso8601String(),
        'start_time':   startTime,
        'end_time':     endTime,
        'guest_count':  guestCount,
        'notes':        notes,
        'status':       status,
      };

  // RADJA: This parses the JSON your API returns.
  //        Make sure your response includes all these fields.
  factory BookingRequest.fromJson(Map<String, dynamic> json) => BookingRequest(
        id:          json['id']?.toString(),
        unitNumber:  json['unit_number']  ?? '',
        areaName:    json['area_name']    ?? '',
        bookingDate: DateTime.parse(json['booking_date']),
        startTime:   json['start_time']   ?? '',
        endTime:     json['end_time']     ?? '',
        guestCount:  json['guest_count']  ?? 1,
        notes:       json['notes'],
        status:      json['status']       ?? 'pending',
        createdAt:   json['created_at'] != null
            ? DateTime.tryParse(json['created_at'])
            : null,
      );
}