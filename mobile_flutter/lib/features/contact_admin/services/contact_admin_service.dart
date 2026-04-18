import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:resident_app/features/auth/services/auth_service.dart';

class ContactAdminService {
  static const String _baseUrl = 'http://192.168.1.13:8000';

  static Future<void> sendRequest({
    required String subject,
    required String message,
    required String urgency,
  }) async {
    debugPrint('CONTACT ADMIN SERVICE: start');

    final token = await AuthService.getToken();
    final url = Uri.parse('$_baseUrl/contact-admin');

    debugPrint('CONTACT ADMIN SERVICE: url=$url');
    debugPrint('CONTACT ADMIN SERVICE: tokenExists=${token != null}');
    debugPrint(
      'CONTACT ADMIN SERVICE: body=${jsonEncode({
        'subject': subject,
        'message': message,
        'urgency': urgency,
      })}',
    );

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'subject': subject,
        'message': message,
        'urgency': urgency,
      }),
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