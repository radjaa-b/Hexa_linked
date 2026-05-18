import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:resident_app/features/auth/services/auth_service.dart';

class ContactAdminService {
  static Future<void> sendRequest({
    required String subject,
    required String message,
    required String urgency,
  }) async {
    debugPrint('CONTACT ADMIN SERVICE: start');

    final token = await AuthService.getToken();

    if (token == null || token.trim().isEmpty) {
      throw Exception('No auth token found. Please log in again.');
    }

    final url = Uri.parse('${AuthService.baseUrl}/contact-admin');

    final body = {
      'subject': subject.trim(),
      'message': message.trim(),
      'urgency': urgency.trim(),
    };

    debugPrint('CONTACT ADMIN SERVICE: url=$url');
    debugPrint('CONTACT ADMIN SERVICE: tokenExists=true');
    debugPrint('CONTACT ADMIN SERVICE: body=${jsonEncode(body)}');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    debugPrint('CONTACT ADMIN SERVICE: status=${response.statusCode}');
    debugPrint('CONTACT ADMIN SERVICE: response=${response.body}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Contact admin failed: ${response.statusCode} ${response.body}',
      );
    }
  }
}