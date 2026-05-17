import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:resident_app/features/auth/services/auth_service.dart';

class PassService {
  static Future<Map<String, dynamic>> getResidentPass() async {
    final session = await AuthService.getStoredSession(
      requiredRole: 'resident',
    );

    if (session == null) {
      throw Exception('Resident session not found');
    }

    final baseUrl = AuthService.baseUrl;

    final response = await http.get(
      Uri.parse('$baseUrl/resident-access/my-qr'),
      headers: {
        'Authorization': 'Bearer ${session.accessToken}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load resident QR: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}