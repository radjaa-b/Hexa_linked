import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:resident_app/features/auth/services/auth_token_helper.dart';
import 'package:resident_app/features/profile/models/resident_profile.dart';

class ActivationValidationResult {
  final String message;
  final String? email;
  final String? username;

  const ActivationValidationResult({
    required this.message,
    this.email,
    this.username,
  });
}

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}

class AuthTokenException extends AuthException {
  const AuthTokenException(super.message);
}

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const residentRole = 'resident';

  // Temporary runtime anchor to stop stale .env madness.
  // Change this later only when your backend IP changes.
  static const String _fixedBaseUrl = 'http://192.168.1.4:8000';

  static const bool _useMock = false;
  static const _mockEmail = 'test@test.com';
  static const _mockPassword = 'password123';
  static const _mockToken =
      'eyJhbGciOiJub25lIiwidHlwIjoiSldUIn0.'
      'eyJzdWIiOiIxIiwicm9sZSI6InJlc2lkZW50IiwiZXhwIjo0MTAyNDQ0ODAwfQ.'
      'mock-signature';

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  static String get baseUrl => _baseUrl();

  static Future<bool> isLoggedIn() async {
    final session = await getStoredSession(requiredRole: residentRole);
    return session != null;
  }

  static Future<AuthSession?> getStoredSession({String? requiredRole}) async {
    final token = await getToken();
    if (token == null || token.trim().isEmpty) {
      return null;
    }

    try {
      final session = AuthTokenHelper.buildSession(
        accessToken: token,
        tokenType: 'bearer',
      );

      if (session.isExpired) {
        await clearToken();
        return null;
      }

      if (requiredRole != null && !session.hasRole(requiredRole)) {
        await clearToken();
        return null;
      }

      return session;
    } on FormatException {
      await clearToken();
      return null;
    }
  }

  static Future<AuthSession> login(String email, String password) async {
    if (_useMock) return _mockLogin(email, password);

    final response = await _sendRequest(
      () => http.post(
        Uri.parse('${_baseUrl()}/auth/login'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'username': email.trim(), 'password': password},
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final token = data['access_token'];
      if (token is! String || token.isEmpty) {
        throw const AuthTokenException(
          'Login response did not include an access token.',
        );
      }

      final tokenType = _extractTokenType(data['token_type']);

      try {
        final session = AuthTokenHelper.buildSession(
          accessToken: token,
          tokenType: tokenType,
        );
        await saveToken(session.accessToken);
        return session;
      } on FormatException catch (error) {
        throw AuthTokenException(
          'Received an invalid access token from the server: ${error.message}',
        );
      }
    }

    throw AuthException(_extractErrorMessage(response.body));
  }

  static Future<ResidentProfile> whoami() async {
    final session = await getStoredSession(requiredRole: residentRole);
    if (session == null) {
      throw const AuthException(
        'Your session is no longer valid. Please sign in again.',
      );
    }

    final response = await _sendRequest(
      () => http.get(
        Uri.parse('${_baseUrl()}/auth/whoami'),
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return ResidentProfile.fromJson(data);
    }

    throw AuthException(_extractErrorMessage(response.body));
  }

  static Future<ActivationValidationResult> validateActivationToken(
    String token,
  ) async {
    final normalizedToken = token.trim();
    if (normalizedToken.isEmpty) {
      throw const AuthException('Activation token is missing');
    }

    final uri = Uri.parse(
      '${_baseUrl()}/auth/activate/validate',
    ).replace(queryParameters: {'token': normalizedToken});

    final response = await _sendRequest(() => http.get(uri));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return ActivationValidationResult(
        message: (data['message'] ?? 'Token valid').toString(),
        email: (data['email'] as String?)?.trim(),
        username: (data['username'] as String?)?.trim(),
      );
    }

    throw AuthException(_extractErrorMessage(response.body));
  }

  static Future<String> completeAccount({
    required String token,
    required String password,
    required String confirmPassword,
  }) async {
    final normalizedToken = token.trim();
    if (normalizedToken.isEmpty) {
      throw const AuthException('Activation token is missing');
    }

    final response = await _sendRequest(
      () => http.post(
        Uri.parse('${_baseUrl()}/auth/complete-account'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': normalizedToken,
          'password': password,
          'confirm_password': confirmPassword,
        }),
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return (data['message'] ?? 'Account completed successfully').toString();
    }

    throw AuthException(_extractErrorMessage(response.body));
  }
  // ─────────────────────────────────────────────────────────────
  // ADD THESE TWO METHODS TO YOUR AuthService CLASS
  // Place them after the existing completeAccount() method.
  // ─────────────────────────────────────────────────────────────

  static Future<void> forgotPassword(String email) async {
    final response = await _sendRequest(
      () => http.post(
        Uri.parse('${_baseUrl()}/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      ),
    );

    // The backend always returns 200 for this endpoint regardless of whether
    // the email exists, to avoid leaking account information.
    if (response.statusCode == 200) return;

    throw Exception(_extractErrorMessage(response.body));
  }

  static Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    final response = await _sendRequest(
      () => http.post(
        Uri.parse('${_baseUrl()}/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token.trim(), 'new_password': newPassword}),
      ),
    );

    if (response.statusCode == 200) return;

    throw Exception(_extractErrorMessage(response.body));
  }

  static Future<AuthSession> _mockLogin(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    if (email == _mockEmail && password == _mockPassword) {
      final session = AuthTokenHelper.buildSession(
        accessToken: _mockToken,
        tokenType: 'bearer',
      );
      await saveToken(session.accessToken);
      return session;
    }

    throw const AuthException('Invalid email or password');
  }

  static String _baseUrl() {
    final envValue = dotenv.env['API_BASE_URL']?.trim();

    if (envValue != null && envValue.isNotEmpty) {
      print('API_BASE_URL from .env = $envValue');
    } else {
      print('API_BASE_URL from .env is missing');
    }

    print('AuthService using fixed backend URL = $_fixedBaseUrl');

    return _fixedBaseUrl.replaceFirst(RegExp(r'/$'), '');
  }

  static Future<http.Response> _sendRequest(
    Future<http.Response> Function() request,
  ) async {
    try {
      return await request().timeout(const Duration(seconds: 12));
    } on SocketException {
      throw AuthException(
        'Cannot reach the backend at ${_baseUrl()}. Check that the API server is running and that this IP is the current laptop IP.',
      );
    } on HttpException {
      throw AuthException(
        'The backend at ${_baseUrl()} rejected the connection.',
      );
    } on TimeoutException {
      throw AuthException(
        'The request sent to ${_baseUrl()} timed out. Please try again.',
      );
    }
  }

  static String _extractTokenType(dynamic rawTokenType) {
    final normalized = rawTokenType?.toString().trim();
    if (normalized == null || normalized.isEmpty) {
      return 'bearer';
    }

    return normalized;
  }

  static String _extractErrorMessage(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);

      if (decoded is Map<String, dynamic>) {
        final detail = decoded['detail'];

        if (detail is String && detail.isNotEmpty) {
          return detail;
        }

        if (detail is List && detail.isNotEmpty) {
          final messages = detail
              .map((item) {
                if (item is Map<String, dynamic>) {
                  final message = item['msg'];
                  if (message is String && message.isNotEmpty) {
                    return message;
                  }
                }
                return item.toString();
              })
              .where((message) => message.isNotEmpty)
              .join(', ');

          if (messages.isNotEmpty) {
            return messages;
          }
        }

        final message = decoded['message'];
        if (message is String && message.isNotEmpty) {
          return message;
        }
      }
    } catch (_) {
      // Ignore JSON parse errors and fall back below.
    }

    return 'Request failed';
  }
}
