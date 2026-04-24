import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:resident_app/features/auth/services/auth_service.dart';
import 'package:resident_app/features/chat/models/conversation.dart';
import 'package:resident_app/features/chat/models/message.dart';
import 'package:flutter/material.dart';

class ChatService {
  static String _currentUserId = '';
  static String _currentUserName = 'You';
  static String _currentUserUnit = '';

  static final Map<String, Resident> _residentCacheById = {};
  static final Map<String, Conversation> _conversationCacheById = {};

  static Future<void>? _currentUserLoad;

  static String get currentUserId => _currentUserId;
  static String get currentUserName => _currentUserName;
  static String get currentUserUnit => _currentUserUnit;

  // Call this on logout to reset cached user state.
  static void clearCurrentUser() {
    _currentUserId = '';
    _currentUserName = 'You';
    _currentUserUnit = '';
    _currentUserLoad = null;
    _residentCacheById.clear();
    _conversationCacheById.clear();
  }

  static Future<List<Message>> fetchMessages(String conversationId) async {
    return fetchDmMessages(conversationId);
  }

  static Future<void> sendMessage(String conversationId, String content) async {
    return sendDmMessage(conversationId, content);
  }

  static Future<void> sendImage(String imagePath) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  static Future<Conversation> fetchGroupConversation() async {
    await _ensureCurrentUserLoaded();

    final response = await http
        .get(
          Uri.parse('${_baseUrl()}/chat/home'),
          headers: await _authHeaders(),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(_extractErrorMessage(response.body));
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final groupJson = data['group_chat'] as Map<String, dynamic>;

    final group = _mapConversation(groupJson);
    _conversationCacheById[group.id] = group;

    return group;
  }

  static Future<List<Conversation>> fetchConversations() async {
    await _ensureCurrentUserLoaded();

    final response = await http
        .get(
          Uri.parse('${_baseUrl()}/chat/home'),
          headers: await _authHeaders(),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(_extractErrorMessage(response.body));
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final privateChats = (data['private_chats'] as List<dynamic>? ?? const []);

    final conversations = privateChats
        .whereType<Map<String, dynamic>>()
        .map(_mapConversation)
        .toList();

    for (final conversation in conversations) {
      _conversationCacheById[conversation.id] = conversation;
    }

    return conversations;
  }

  static Future<List<Message>> fetchDmMessages(String conversationId) async {
    await _ensureCurrentUserLoaded();

    final response = await http
        .get(
          Uri.parse(
            '${_baseUrl()}/chat/conversations/${_conversationId(conversationId)}/messages',
          ),
          headers: await _authHeaders(),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(_extractErrorMessage(response.body));
    }

    final messagesJson = jsonDecode(response.body) as List<dynamic>;
    final conversation = _conversationCacheById[conversationId];

    return messagesJson
        .whereType<Map<String, dynamic>>()
        .map((messageJson) => _mapMessage(messageJson, conversation))
        .toList();
  }

  static Future<void> sendDmMessage(
    String conversationId,
    String content,
  ) async {
    await _ensureCurrentUserLoaded();

    final trimmedContent = content.trim();
    if (trimmedContent.isEmpty) return;

    final response = await http
        .post(
          Uri.parse(
            '${_baseUrl()}/chat/conversations/${_conversationId(conversationId)}/messages',
          ),
          headers: await _authHeaders(json: true),
          body: jsonEncode({'content': trimmedContent}),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(_extractErrorMessage(response.body));
    }

    final messageJson = jsonDecode(response.body) as Map<String, dynamic>;
    final cachedConversation = _conversationCacheById[conversationId];
    if (cachedConversation != null) {
      _conversationCacheById[conversationId] = Conversation(
        id: cachedConversation.id,
        otherUserId: cachedConversation.otherUserId,
        otherUserName: cachedConversation.otherUserName,
        otherUserUnit: cachedConversation.otherUserUnit,
        lastMessage: (messageJson['content'] ?? trimmedContent).toString(),
        lastMessageAt:
            _parseDateTime(messageJson['created_at']) ?? DateTime.now(),
        unreadCount: cachedConversation.unreadCount,
        isMe: true,
      );
    }
  }

  static Future<void> sendDmImage(
    String conversationId,
    String imagePath,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  static Future<Conversation> startConversation(Resident resident) async {
    await _ensureCurrentUserLoaded();
    _residentCacheById[resident.id] = resident;

    final response = await http
        .post(
          Uri.parse('${_baseUrl()}/chat/private/open'),
          headers: await _authHeaders(json: true),
          body: jsonEncode({'target_user_id': int.parse(resident.id)}),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(_extractErrorMessage(response.body));
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final conversation = _mapConversation(data, residentOverride: resident);
    _conversationCacheById[conversation.id] = conversation;
    return conversation;
  }

  static Future<List<Resident>> fetchResidents() async {
    await _ensureCurrentUserLoaded();

    final uri = Uri.parse(
      '${_baseUrl()}/chat/search',
    ).replace(queryParameters: {'query': '@'});

    final response = await http
        .get(uri, headers: await _authHeaders())
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(_extractErrorMessage(response.body));
    }

    final residentsJson = jsonDecode(response.body) as List<dynamic>;
    final residents =
        residentsJson
            .whereType<Map<String, dynamic>>()
            .map(_mapResident)
            .toList()
          ..sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );

    for (final resident in residents) {
      _residentCacheById[resident.id] = resident;
    }

    return residents;
  }

  static Future<void> _ensureCurrentUserLoaded() async {
    // Always reload the current user from the active token.
    // This prevents the app from keeping the previous logged-in resident ID.
    await _loadCurrentUser();
  }

  static Future<void> _loadCurrentUser() async {
    final token = await AuthService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated');
    }

    final response = await http
        .get(
          Uri.parse('${_baseUrl()}/auth/whoami'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        )
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () =>
              throw Exception('Connection timed out loading user profile.'),
        );

    if (response.statusCode != 200) {
      throw Exception(_extractErrorMessage(response.body));
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    _currentUserId = (data['id'] ?? '').toString();

    debugPrint('WHOAMI => $data');
    debugPrint('MY USER ID => $_currentUserId');
    // Prefer full_name; fall back to username derived from email.
    final fullName = (data['full_name'] as String?)?.trim();
    if (fullName != null && fullName.isNotEmpty) {
      _currentUserName = fullName;
    } else {
      final email = (data['email'] ?? '').toString().trim();
      _currentUserName = email.isNotEmpty
          ? _displayNameFromEmail(email)
          : 'You';
    }

    _currentUserUnit = (data['email'] ?? '').toString().trim();
  }

  static Conversation _mapConversation(
    Map<String, dynamic> json, {
    Resident? residentOverride,
  }) {
    final otherUserId =
        '${json['other_user_id'] ?? residentOverride?.id ?? ''}';
    final cachedResident = residentOverride ?? _residentCacheById[otherUserId];

    final conversation = Conversation(
      id: '${json['id']}',
      otherUserId: otherUserId,
      otherUserName:
          (json['other_username'] ?? cachedResident?.name ?? 'Resident')
              .toString(),
      otherUserUnit: cachedResident?.unit ?? 'Resident',
      lastMessage: (json['last_message'] ?? '').toString(),
      lastMessageAt:
          _parseDateTime(json['last_message_time']) ?? DateTime.now(),
      unreadCount: 0,
      isMe: false,
    );

    if (otherUserId.isNotEmpty) {
      _residentCacheById.putIfAbsent(
        otherUserId,
        () => Resident(
          id: otherUserId,
          name: conversation.otherUserName,
          unit: conversation.otherUserUnit,
        ),
      );
    }

    return conversation;
  }

  static Message _mapMessage(
    Map<String, dynamic> json,
    Conversation? conversation,
  ) {
    final senderId = '${json['sender_id'] ?? ''}';
    final isMe = senderId.trim() == _currentUserId.trim();

    debugPrint(
      'MESSAGE MAP => senderId=$senderId | currentUserId=$_currentUserId | isMe=$isMe',
    );
    final senderName = isMe
        ? _currentUserName
        : (conversation?.otherUserName ?? 'Resident');
    final senderUnit = isMe
        ? _currentUserUnit
        : (conversation?.otherUserUnit ?? 'Resident');

    return Message(
      id: '${json['id']}',
      senderId: senderId,
      senderName: senderName,
      senderUnit: senderUnit,
      content: (json['content'] ?? '').toString(),
      type: MessageType.text,
      sentAt: _parseDateTime(json['created_at']) ?? DateTime.now(),
      isMe: isMe,
    );
  }

  static Resident _mapResident(Map<String, dynamic> json) {
    return Resident(
      id: '${json['id']}',
      name: (json['username'] ?? 'Resident').toString(),
      unit: (json['email'] ?? 'Resident').toString(),
    );
  }

  static Future<Map<String, String>> _authHeaders({bool json = false}) async {
    final token = await AuthService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Missing auth token');
    }

    return {
      'Authorization': 'Bearer $token',
      if (json) 'Content-Type': 'application/json',
    };
  }

  static String _baseUrl() {
    return AuthService.baseUrl;
  }

  static int _conversationId(String conversationId) {
    final parsed = int.tryParse(conversationId);
    if (parsed == null) {
      throw Exception('Invalid conversation id: $conversationId');
    }
    return parsed;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  static String _displayNameFromEmail(String email) {
    final localPart = email.split('@').first.trim();
    if (localPart.isEmpty) return 'You';

    final words = localPart
        .replaceAll(RegExp(r'[._-]+'), ' ')
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .toList();

    if (words.isEmpty) return 'You';
    return words.join(' ');
  }

  static String _extractErrorMessage(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map<String, dynamic>) {
        final detail = decoded['detail'];
        if (detail is String && detail.isNotEmpty) return detail;

        final message = decoded['message'];
        if (message is String && message.isNotEmpty) return message;
      }
    } catch (_) {
      // Fall back to a default message when the response is not JSON.
    }

    return 'Chat request failed';
  }

  static List<Message> _mockGroupMessages() {
    final now = DateTime.now();
    return [
      Message(
        id: 'm1',
        senderId: 'user_karim',
        senderName: 'Karim B.',
        senderUnit: 'Unit 2A',
        content: 'Good morning everyone! 👋',
        type: MessageType.text,
        sentAt: now.subtract(const Duration(hours: 2, minutes: 30)),
        isMe: false,
      ),
      Message(
        id: 'm2',
        senderId: 'user_sara',
        senderName: 'Sara M.',
        senderUnit: 'Unit 4B',
        content: 'Morning! Pool is closed until noon today.',
        type: MessageType.text,
        sentAt: now.subtract(const Duration(hours: 2, minutes: 10)),
        isMe: false,
      ),
      Message(
        id: 'm3',
        senderId: currentUserId,
        senderName: currentUserName,
        senderUnit: currentUserUnit,
        content: 'Thanks for the heads up Sara!',
        type: MessageType.text,
        sentAt: now.subtract(const Duration(hours: 2)),
        isMe: true,
      ),
      Message(
        id: 'm4',
        senderId: 'user_leila',
        senderName: 'Leila T.',
        senderUnit: 'Unit 7C',
        content: 'Does anyone know if the gym is open on weekends?',
        type: MessageType.text,
        sentAt: now.subtract(const Duration(hours: 1, minutes: 20)),
        isMe: false,
      ),
      Message(
        id: 'm5',
        senderId: 'user_karim',
        senderName: 'Karim B.',
        senderUnit: 'Unit 2A',
        content: 'Yes! 7 AM to 10 PM on weekends.',
        type: MessageType.text,
        sentAt: now.subtract(const Duration(hours: 1)),
        isMe: false,
      ),
      Message(
        id: 'm6',
        senderId: currentUserId,
        senderName: currentUserName,
        senderUnit: currentUserUnit,
        content: 'Perfect, going tomorrow morning 💪',
        type: MessageType.text,
        sentAt: now.subtract(const Duration(minutes: 30)),
        isMe: true,
      ),
      Message(
        id: 'm7',
        senderId: 'user_sara',
        senderName: 'Sara M.',
        senderUnit: 'Unit 4B',
        content: 'Has anyone seen this view from the rooftop? 😍',
        type: MessageType.text,
        sentAt: now.subtract(const Duration(minutes: 10)),
        isMe: false,
      ),
    ];
  }
}
