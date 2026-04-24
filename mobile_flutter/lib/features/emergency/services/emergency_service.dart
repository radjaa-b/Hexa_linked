import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:resident_app/features/auth/services/auth_service.dart';
import 'package:resident_app/features/emergency/models/emergency_request.dart';

class EmergencyService {
  static Future<void> send(EmergencyRequest request) async {
    final session = await AuthService.getStoredSession(
      requiredRole: 'resident',
    );

    if (session == null) {
      throw Exception('Your session expired. Please log in again.');
    }

    final response = await http.post(
      Uri.parse('${AuthService.baseUrl}/alerts'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${session.accessToken}',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(_extractErrorMessage(response.body));
    }
  }

  static Future<List<dynamic>> getMyIncidents() async {
    final session = await AuthService.getStoredSession(
      requiredRole: 'resident',
    );

    if (session == null) {
      throw Exception('Your session expired. Please log in again.');
    }

    final response = await http.get(
      Uri.parse('${AuthService.baseUrl}/alerts/me'),
      headers: {'Authorization': 'Bearer ${session.accessToken}'},
    );

    if (response.statusCode != 200) {
      throw Exception(_extractErrorMessage(response.body));
    }

    return jsonDecode(response.body) as List<dynamic>;
  }

  static String _extractErrorMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final detail = decoded['detail'];
        if (detail is String) return detail;
      }
    } catch (_) {}

    return 'Request failed';
  }
}
