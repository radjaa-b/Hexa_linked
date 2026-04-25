import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/maintenance_request.dart';
import '../models/visitor_request.dart';
import '../models/booking_request.dart';
import '../models/parking_spot.dart';
import 'package:flutter/foundation.dart';

//   HEY RADJA  zwina  rabi m3ak   — READ THIS FIRST

class RequestsService {
  static const String _baseUrl = 'http://192.168.1.4:8000';

  static const bool _useMock = false;

  Map<String, String> _headers({String? token}) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  Future<MaintenanceRequest> submitMaintenanceRequest({
    required MaintenanceRequest request,
    required String token, // make token required
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/maintenance'), // ✅ correct
      headers: _headers(token: token),
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return MaintenanceRequest.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to submit maintenance request: ${response.body}');
  }

  Future<List<MaintenanceRequest>> getMaintenanceRequests({
    required String token, // make token required
  }) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/maintenance/me'), // ✅ resident sees only their own
      headers: _headers(token: token),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => MaintenanceRequest.fromJson(e)).toList();
    }
    throw Exception('Failed to fetch maintenance requests: ${response.body}');
  }

  // ═══════════════════════════════════════════════════════════════
  //  VISITOR REQUESTS
  //
  //  POST   /visitor-requests           → register a visitor pass
  //  GET    /visitor-requests           → list passes
  //                                       (optional: ?unit_number=A-204)
  // ═══════════════════════════════════════════════════════════════

  // RADJA: Called when the resident registers a visitor.
  //
  // Expected request body (JSON):
  // {
  //   "visitor_name":  "Ahmed Benali",
  //   "visitor_phone": "+213 555 123 456",
  //   "visit_date":    "2025-06-01T00:00:00.000",
  //   "visit_purpose": "Personal Visit",
  //   "unit_number":   "A-204",
  //   "status":        "pending"
  // }
  //
  // Expected response body (JSON) — the created record:
  // {
  //   "id":            "55",
  //   "visitor_name":  "Ahmed Benali",
  //   "visitor_phone": "+213 555 123 456",
  //   "visit_date":    "2025-06-01T00:00:00.000",
  //   "visit_purpose": "Personal Visit",
  //   "unit_number":   "A-204",
  //   "status":        "pending",
  //   "created_at":    "2025-05-28T10:30:00.000"
  // }
  Future<VisitorRequest> submitVisitorRequest({
    required VisitorRequest request,
    String? token,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/visitor-requests'),
      headers: _headers(token: token),
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return VisitorRequest.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to submit visitor request: ${response.body}');
  }

  // RADJA: Called to list all visitor passes for a unit.
  //
  // Expected response body (JSON) — array of records (same shape as above).
  Future<List<VisitorRequest>> getMyVisitorRequests({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/visitor-requests/my'),
      headers: _headers(token: token),
    );

    debugPrint('VISITOR GET STATUS: ${response.statusCode}');
    debugPrint('VISITOR GET BODY: ${response.body}');

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => VisitorRequest.fromJson(e)).toList();
    }

    throw Exception('Failed to fetch visitor requests: ${response.body}');
  }

  // ═══════════════════════════════════════════════════════════════
  //  BOOKING REQUESTS
  //
  //  POST   /booking-requests           → submit a new booking
  //  GET    /booking-requests           → list bookings
  //                                       (optional: ?unit_number=A-204)
  // ═══════════════════════════════════════════════════════════════

  // RADJA: Called when the resident submits a shared area booking.
  //
  // Expected request body (JSON):
  // {
  //   "unit_number":  "A-204",
  //   "area_name":    "Gym",
  //   "booking_date": "2025-06-01T00:00:00.000",
  //   "start_time":   "09:00",
  //   "end_time":     "10:00",
  //   "guest_count":  2,
  //   "notes":        "Will need chairs set up.", // nullable
  //   "status":       "pending"
  // }
  //
  // Expected response body (JSON) — the created record:
  // {
  //   "id":           "88",
  //   "unit_number":  "A-204",
  //   "area_name":    "Gym",
  //   "booking_date": "2025-06-01T00:00:00.000",
  //   "start_time":   "09:00",
  //   "end_time":     "10:00",
  //   "guest_count":  2,
  //   "notes":        null,
  //   "status":       "pending",
  //   "created_at":   "2025-05-28T10:30:00.000"
  // }
  Future<BookingRequest> submitBookingRequest({
    required BookingRequest request,
    String? token,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/booking-requests'),
      headers: _headers(token: token),
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return BookingRequest.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to submit booking request: ${response.body}');
  }

  // RADJA: Called to list all bookings for a unit.
  //
  // Expected response body (JSON) — array of records (same shape as above).
  Future<List<BookingRequest>> getBookingRequests({
    String? token,
    String? unitNumber,
  }) async {
    final uri = Uri.parse('$_baseUrl/booking-requests').replace(
      queryParameters: {if (unitNumber != null) 'unit_number': unitNumber},
    );
    final response = await http.get(uri, headers: _headers(token: token));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => BookingRequest.fromJson(e)).toList();
    }
    throw Exception('Failed to fetch booking requests: ${response.body}');
  }

  // ═══════════════════════════════════════════════════════════════
  //  PARKING
  //
  //  GET    /parking/spots              → list all parking spots
  //
  //  RADJA: This endpoint should return ALL spots with their
  //         current status so the resident can see the full map.
  //         Resident spots are in rows A, B, C...
  //         Visitor spots are in row V.
  // ═══════════════════════════════════════════════════════════════

  // RADJA: Called when the resident opens the Parking Lot screen.
  //
  // Expected response body (JSON) — array of spot objects:
  // [
  //   {
  //     "spot_id"        : "A-01",
  //     "status"         : "occupied",    // "available" | "occupied"
  //     "resident_id"    : "res-42",      // null if visitor spot or free
  //     "is_visitor_spot": false
  //   },
  //   {
  //     "spot_id"        : "V-01",
  //     "status"         : "available",
  //     "resident_id"    : null,
  //     "is_visitor_spot": true
  //   },
  //   ...
  // ]
  Future<List<ParkingSpot>> fetchParkingSpots({String? token}) async {
    if (_useMock) return _mockFetchSpots();

    // RADJA: flip _useMock to false and this real call will run ──
    final response = await http.get(
      Uri.parse('$_baseUrl/parking/spots'),
      headers: _headers(token: token),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => ParkingSpot.fromJson(e)).toList();
    }
    throw Exception('Failed to fetch parking spots: ${response.body}');
  }

  // ── Mock data — remove when backend is ready ──────────────────
  //    Row A & B → resident spots (20 each, each assigned to a resident)
  //    Row V     → visitor spots  (10 spots, shared)
  Future<List<ParkingSpot>> _mockFetchSpots() async {
    await Future.delayed(const Duration(seconds: 1)); // simulate network

    final spots = <ParkingSpot>[];

    // ── Row A — resident spots ─────────────────────────────────
    // RADJA: each spot has a residentId assigned by the backend
    // 'mock-resident-01' is the logged in resident (spot A-03)
    final rowAResidents = [
      'res-01',
      'res-02',
      'mock-resident-01',
      'res-04',
      'res-05',
      'res-06',
      'res-07',
      'res-08',
      'res-09',
      'res-10',
      'res-11',
      'res-12',
      'res-13',
      'res-14',
      'res-15',
      'res-16',
      'res-17',
      'res-18',
      'res-19',
      'res-20',
    ];
    for (int i = 0; i < 20; i++) {
      spots.add(
        ParkingSpot(
          spotId: 'A-${(i + 1).toString().padLeft(2, '0')}',
          status: SpotStatus.occupied, // resident spots are always occupied
          residentId: rowAResidents[i],
          isVisitorSpot: false,
        ),
      );
    }

    // ── Row B — resident spots ─────────────────────────────────
    for (int i = 0; i < 20; i++) {
      spots.add(
        ParkingSpot(
          spotId: 'B-${(i + 1).toString().padLeft(2, '0')}',
          status: SpotStatus.occupied,
          residentId: 'res-${i + 21}',
          isVisitorSpot: false,
        ),
      );
    }

    // ── Row V — visitor spots ──────────────────────────────────
    // RADJA: visitor spots have no residentId, status changes in real time
    final visitorStatuses = [
      SpotStatus.available,
      SpotStatus.available,
      SpotStatus.occupied,
      SpotStatus.available,
      SpotStatus.occupied,
      SpotStatus.available,
      SpotStatus.available,
      SpotStatus.occupied,
      SpotStatus.available,
      SpotStatus.available,
    ];
    for (int i = 0; i < 10; i++) {
      spots.add(
        ParkingSpot(
          spotId: 'V-${(i + 1).toString().padLeft(2, '0')}',
          status: visitorStatuses[i],
          residentId: null,
          isVisitorSpot: true,
        ),
      );
    }

    return spots;
  }
}
