import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/maintenance_request.dart';
import '../models/visitor_request.dart';
import '../models/booking_request.dart';
import '../models/parking_spot.dart';

// ═══════════════════════════════════════════════════════════════
//   HEY RADJA  zwina  rabi m3ak   — READ THIS FIRST
//
//  This file is the only place you need to touch to connect the
//  backend. Every API call in the app goes through here.
//
//  STEP 1 — Replace the base URL below with your real server URL.
//  STEP 2 — Check each method's expected request body (toJson)
//            and expected response shape (fromJson) in the models/
//            folder. The field names must match your API exactly.
//  STEP 3 — If your API uses auth tokens, pass the token into
//            each method. The _headers() helper already handles
//            the Authorization header for you.
//
//  That's it. The screens handle loading states and error display
//  automatically — you don't need to touch any UI file.
// ═══════════════════════════════════════════════════════════════

class RequestsService {

  // ── RADJA: Replace this with your real API base URL ─────────
  //    e.g. 'https://resident-app.example.com/api'
  //    or   'http://192.168.1.10:8000/api'  (local dev)
  static const String _baseUrl = 'https://your-api.com/api';

  // ── Mock toggle ───────────────────────────────────────────────
  //    RADJA: flip this to false when the backend is ready
  static const bool _useMock = true;

  // ── Auth header helper ────────────────────────────────────────
  //    RADJA: If your API uses Bearer tokens, pass the token when
  //    calling any method below. If you use a different auth
  //    scheme (cookies, API keys, etc.), update this method.
  Map<String, String> _headers({String? token}) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };


  // ═══════════════════════════════════════════════════════════════
  //  MAINTENANCE REQUESTS
  //
  //  POST   /maintenance-requests       → submit a new request
  //  GET    /maintenance-requests       → list requests
  //                                       (optional: ?unit_number=A-204)
  // ═══════════════════════════════════════════════════════════════

  // RADJA: Called when the resident submits the maintenance form.
  //
  // Expected request body (JSON):
  // {
  //   "unit_number":    "A-204",
  //   "category":       "Plumbing",
  //   "description":    "Leaking pipe under the sink",
  //   "priority":       "high",          // "low" | "medium" | "high"
  //   "preferred_date": "2025-06-01T00:00:00.000", // nullable
  //   "status":         "pending"
  // }
  //
  // Expected response body (JSON) — the created record:
  // {
  //   "id":             "123",
  //   "unit_number":    "A-204",
  //   "category":       "Plumbing",
  //   "description":    "Leaking pipe under the sink",
  //   "priority":       "high",
  //   "preferred_date": "2025-06-01T00:00:00.000",
  //   "status":         "pending",
  //   "created_at":     "2025-05-28T10:30:00.000"
  // }
  Future<MaintenanceRequest> submitMaintenanceRequest({
    required MaintenanceRequest request,
    String? token,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/maintenance-requests'),
      headers: _headers(token: token),
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return MaintenanceRequest.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to submit maintenance request: ${response.body}');
  }

  // RADJA: Called to list all maintenance requests for a unit.
  //
  // Expected response body (JSON) — array of records:
  // [
  //   { "id": "123", "unit_number": "A-204", "status": "pending", ... },
  //   { "id": "124", "unit_number": "A-204", "status": "in_progress", ... }
  // ]
  Future<List<MaintenanceRequest>> getMaintenanceRequests({
    String? token,
    String? unitNumber,
  }) async {
    final uri = Uri.parse('$_baseUrl/maintenance-requests').replace(
      queryParameters: {if (unitNumber != null) 'unit_number': unitNumber},
    );
    final response = await http.get(uri, headers: _headers(token: token));
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
  Future<List<VisitorRequest>> getVisitorRequests({
    String? token,
    String? unitNumber,
  }) async {
    final uri = Uri.parse('$_baseUrl/visitor-requests').replace(
      queryParameters: {if (unitNumber != null) 'unit_number': unitNumber},
    );
    final response = await http.get(uri, headers: _headers(token: token));
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
      'res-01', 'res-02', 'mock-resident-01', 'res-04', 'res-05',
      'res-06', 'res-07', 'res-08', 'res-09', 'res-10',
      'res-11', 'res-12', 'res-13', 'res-14', 'res-15',
      'res-16', 'res-17', 'res-18', 'res-19', 'res-20',
    ];
    for (int i = 0; i < 20; i++) {
      spots.add(ParkingSpot(
        spotId:        'A-${(i + 1).toString().padLeft(2, '0')}',
        status:        SpotStatus.occupied,   // resident spots are always occupied
        residentId:    rowAResidents[i],
        isVisitorSpot: false,
      ));
    }

    // ── Row B — resident spots ─────────────────────────────────
    for (int i = 0; i < 20; i++) {
      spots.add(ParkingSpot(
        spotId:        'B-${(i + 1).toString().padLeft(2, '0')}',
        status:        SpotStatus.occupied,
        residentId:    'res-${i + 21}',
        isVisitorSpot: false,
      ));
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
      spots.add(ParkingSpot(
        spotId:        'V-${(i + 1).toString().padLeft(2, '0')}',
        status:        visitorStatuses[i],
        residentId:    null,
        isVisitorSpot: true,
      ));
    }

    return spots;
  }
}