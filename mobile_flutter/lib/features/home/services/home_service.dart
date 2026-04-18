import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../auth/services/auth_service.dart';
import '../models/announcement_model.dart';

class HomeService {
  const HomeService();

  // Always delegate to AuthService — both services share one source of truth
  // for the base URL (the hardcoded _fixedBaseUrl in AuthService).
  String get _baseUrl => AuthService.baseUrl;

  Future<Map<String, String>> _headers() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // ─── Shared request helper ────────────────────────────────────────────────

  Future<http.Response> _send(
    Future<http.Response> Function() request, {
    List<int> expectedStatuses = const [200],
  }) async {
    final http.Response response;

    try {
      response = await request().timeout(const Duration(seconds: 12));
    } on TimeoutException {
      throw Exception(
        'Request timed out. Make sure the API is running at $_baseUrl '
        'and your device is on the same Wi-Fi network as your laptop.',
      );
    } on SocketException {
      throw Exception(
        'Cannot reach $_baseUrl. '
        'Check that the API server is running and both devices share the same network.',
      );
    } on HttpException {
      throw Exception('The server rejected the connection.');
    }

    if (expectedStatuses.contains(response.statusCode)) return response;

    throw Exception(_extractDetail(response));
  }

  String _extractDetail(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        final detail = body['detail'];
        if (detail is String && detail.isNotEmpty) return detail;
        if (detail is List && detail.isNotEmpty) {
          return detail
              .map((e) {
                if (e is Map<String, dynamic>) {
                  final field = (e['loc'] as List?)?.lastOrNull ?? 'field';
                  final msg = e['msg'] ?? 'invalid value';
                  return '$field: $msg';
                }
                return e.toString();
              })
              .join(', ');
        }
      }
    } catch (_) {}
    return 'Request failed (HTTP ${response.statusCode})';
  }

  // ─── Announcements ────────────────────────────────────────────────────────

  Future<List<AnnouncementModel>> fetchAnnouncements() async {
    final response = await _send(
      () async => http.get(
        Uri.parse('$_baseUrl/announcements'),
        headers: await _headers(),
      ),
      expectedStatuses: [200],
    );

    final decoded = jsonDecode(response.body);
    if (decoded is! List)
      throw Exception('Unexpected announcements response format');

    return decoded
        .map((item) => AnnouncementModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<AnnouncementModel> createAnnouncement({
    required String content,
    bool isPinned = false,
  }) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty)
      throw Exception('Announcement content cannot be empty');

    // Backend schema requires title with min_length:1.
    // The Flutter UI has no separate title field, so we derive it from content.
    final derivedTitle = trimmed.length > 80
        ? '${trimmed.substring(0, 80)}…'
        : trimmed;

    final response = await _send(
      () async => http.post(
        Uri.parse('$_baseUrl/announcements'),
        headers: await _headers(),
        body: jsonEncode({
          'title': derivedTitle,
          'content': trimmed,
          'is_pinned': isPinned,
        }),
      ),
      expectedStatuses: [200, 201],
    );

    return AnnouncementModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<AnnouncementModel> updateAnnouncement({
    required String announcementId,
    required String content,
    bool? isPinned,
  }) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty)
      throw Exception('Announcement content cannot be empty');

    final derivedTitle = trimmed.length > 80
        ? '${trimmed.substring(0, 80)}…'
        : trimmed;

    final response = await _send(
      () async => http.put(
        Uri.parse('$_baseUrl/announcements/$announcementId'),
        headers: await _headers(),
        body: jsonEncode({
          'title': derivedTitle,
          'content': trimmed,
          if (isPinned != null) 'is_pinned': isPinned,
        }),
      ),
      expectedStatuses: [200],
    );

    return AnnouncementModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<void> deleteAnnouncement({required String announcementId}) async {
    await _send(
      () async => http.delete(
        Uri.parse('$_baseUrl/announcements/$announcementId'),
        headers: await _headers(),
      ),
      expectedStatuses: [200, 204],
    );
  }
}
