import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/maintenance_request.dart';
import '../models/visitor_request.dart';
import '../models/booking_request.dart';
import '../models/parking_spot.dart';
import 'package:flutter/foundation.dart';
import 'package:resident_app/features/auth/services/auth_service.dart';

class RequestsService {
  static String get _baseUrl => AuthService.baseUrl;

  static const bool _useMock = false;

  Map<String, String> _headers({String? token}) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  // ============================================================
  // MAINTENANCE
  // ============================================================

  Future<MaintenanceRequest> submitMaintenanceRequest({
    required MaintenanceRequest request,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/maintenance'),
      headers: _headers(token: token),
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return MaintenanceRequest.fromJson(jsonDecode(response.body));
    }

    throw Exception('Failed to submit maintenance request: ${response.body}');
  }

  Future<List<MaintenanceRequest>> getMaintenanceRequests({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/maintenance/me'),
      headers: _headers(token: token),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => MaintenanceRequest.fromJson(e)).toList();
    }

    throw Exception('Failed to fetch maintenance requests: ${response.body}');
  }

  // ============================================================
  // VISITORS
  // ============================================================

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

  // ============================================================
  // BOOKINGS
  // ============================================================

  Future<BookingRequest> submitBookingRequest({
    required BookingRequest request,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/booking-requests'),
      headers: _headers(token: token),
      body: jsonEncode(request.toJson()),
    );

    debugPrint('BOOKING POST STATUS: ${response.statusCode}');
    debugPrint('BOOKING POST BODY: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return BookingRequest.fromJson(jsonDecode(response.body));
    }

    throw Exception(_cleanError(response));
  }

  String _cleanError(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['detail'] != null) {
        return decoded['detail'].toString();
      }
    } catch (_) {}

    return 'Something went wrong. Please try again.';
  }

  /// ✅ GET my bookings (Activity Overview)
  Future<List<BookingRequest>> getMyBookingRequests({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/booking-requests/my'),
      headers: _headers(token: token),
    );

    debugPrint('BOOKING GET STATUS: ${response.statusCode}');
    debugPrint('BOOKING GET BODY: ${response.body}');

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => BookingRequest.fromJson(e)).toList();
    }

    throw Exception('Failed to fetch booking requests: ${response.body}');
  }

  // ============================================================
  // PARKING
  // ============================================================

  Future<List<ParkingSpot>> fetchParkingSpots({String? token}) async {
    final authToken = token ?? await AuthService.getToken();

    final response = await http.get(
      Uri.parse('${AuthService.baseUrl}/parking-spots'),
      headers: _headers(token: authToken),
    );

    debugPrint('PARKING GET STATUS: ${response.statusCode}');
    debugPrint('PARKING GET BODY: ${response.body}');

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => ParkingSpot.fromJson(e)).toList();
    }

    if (response.statusCode == 401) {
      throw Exception('Your session expired. Please log in again.');
    }

    throw Exception(_cleanError(response));
  }

  Future<List<ParkingSpot>> fetchAvailableParkingSpots({String? token}) async {
    final authToken = token ?? await AuthService.getToken();

    final response = await http.get(
      Uri.parse('${AuthService.baseUrl}/parking-spots/available'),
      headers: _headers(token: authToken),
    );

    debugPrint('PARKING AVAILABLE STATUS: ${response.statusCode}');
    debugPrint('PARKING AVAILABLE BODY: ${response.body}');

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => ParkingSpot.fromJson(e)).toList();
    }

    if (response.statusCode == 401) {
      throw Exception('Your session expired. Please log in again.');
    }

    throw Exception(_cleanError(response));
  }
}
