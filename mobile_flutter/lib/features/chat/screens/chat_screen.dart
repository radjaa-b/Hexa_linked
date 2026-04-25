import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:resident_app/features/chat/models/message.dart';
import 'package:resident_app/features/chat/services/chat_service.dart';
import 'package:resident_app/features/chat/widgets/message_bubble.dart';
import 'package:resident_app/features/chat/widgets/chat_input_bar.dart';
import 'package:resident_app/features/auth/services/auth_service.dart';

// ─────────────────────────────────────────────────────────────
//  CHAT SCREEN
//  Works for both group chat and private DMs.
//  Pass isGroup: true for the group chat room.
//  Pass isGroup: false for a private DM conversation.
// ─────────────────────────────────────────────────────────────
class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.title,
    required this.subtitle,
    required this.isGroup,
  });

  final String conversationId;
  final String title;
  final String subtitle;
  final bool isGroup;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _scrollCtrl = ScrollController();
  WebSocket? _socket;

  List<Message> _messages = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    _connectWebSocket();
  }

  @override
  void dispose() {
    _socket?.close();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ── Load ──────────────────────────────────────────────────────
  Future<void> _load() async {
    final msgs = await ChatService.fetchMessages(widget.conversationId);

    if (mounted) {
      setState(() {
        _messages = msgs;
        _loading = false;
      });
      _scrollToBottom(animated: false);
    }
  }

  Future<void> _connectWebSocket() async {
    final token = await AuthService.getToken();

    if (token == null || token.isEmpty) {
      debugPrint('❌ WebSocket token missing');
      return;
    }

    final baseUrl = AuthService.baseUrl;
    final wsBaseUrl = baseUrl
        .replaceFirst('http://', 'ws://')
        .replaceFirst('https://', 'wss://');

    final wsUrl =
        '$wsBaseUrl/chat/conversations/${widget.conversationId}/ws?token=$token';

    debugPrint('🔌 Connecting WebSocket: $wsUrl');

    try {
      _socket = await WebSocket.connect(wsUrl);

      _socket!.listen(
        (data) {
          final jsonData = jsonDecode(data);

          final senderId = jsonData['sender_id'].toString();
          final isMe = senderId == ChatService.currentUserId;

          final msg = Message(
            id: jsonData['id'].toString(),
            senderId: senderId,
            senderName: isMe ? ChatService.currentUserName : widget.title,
            senderUnit: isMe ? ChatService.currentUserUnit : widget.subtitle,
            content: jsonData['content'].toString(),
            type: MessageType.text,
            sentAt: DateTime.parse(jsonData['created_at']),
            isMe: isMe,
          );

          if (!mounted) return;

          setState(() {
            _messages.add(msg);
          });

          _scrollToBottom();
        },
        onError: (error) {
          debugPrint('❌ WebSocket error: $error');
        },
        onDone: () {
          debugPrint('🔌 WebSocket closed');
        },
      );
    } catch (e) {
      debugPrint('❌ WebSocket connection failed: $e');
    }
  }

  // ── Send text ─────────────────────────────────────────────────
  Future<void> _onSendText(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    HapticFeedback.lightImpact();

    try {
      _socket?.add(jsonEncode({"content": trimmed}));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  // ── Send image ────────────────────────────────────────────────
  void _onSendImage(String path) {
    HapticFeedback.lightImpact();
    setState(() {
      _messages.add(
        Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          senderId: ChatService.currentUserId,
          senderName: ChatService.currentUserName,
          senderUnit: ChatService.currentUserUnit,
          content: path,
          type: MessageType.image,
          sentAt: DateTime.now(),
          isMe: true,
        ),
      );
    });
    _scrollToBottom();

    ChatService.sendImage(path);
  }

  // ── Date separator ────────────────────────────────────────────
  Widget _dateSeparator(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDay = DateTime(date.year, date.month, date.day);
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final label = msgDay == today
        ? 'Today'
        : msgDay == today.subtract(const Duration(days: 1))
        ? 'Yesterday'
        : '${months[date.month - 1]} ${date.day}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              color: const Color(0xFFB8974A).withOpacity(0.20),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFB8974A).withOpacity(0.10),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFB8974A).withOpacity(0.25),
                width: 1,
              ),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFFB8974A),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 1,
              color: const Color(0xFFB8974A).withOpacity(0.20),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildList() {
    final items = <Widget>[];
    DateTime? last;
    for (final msg in _messages) {
      final day = DateTime(msg.sentAt.year, msg.sentAt.month, msg.sentAt.day);
      if (last == null || day != last) {
        items.add(_dateSeparator(msg.sentAt));
        last = day;
      }
      items.add(MessageBubble(message: msg));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: Column(
        children: [
          // ── App bar ────────────────────────────────────────
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF1C3B2E),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Row(
              children: [
                // Back
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8D9B5).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFFE8D9B5),
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8D9B5).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: const Color(0xFFB8974A).withOpacity(0.30),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    widget.isGroup
                        ? Icons.groups_rounded
                        : Icons.person_rounded,
                    color: const Color(0xFFE8D9B5),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Title + subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Color(0xFFE8D9B5),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        widget.subtitle,
                        style: const TextStyle(
                          color: Color(0xFF6B9E80),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Messages ───────────────────────────────────────
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFB8974A),
                      strokeWidth: 2,
                    ),
                  )
                : _messages.isEmpty
                ? _emptyState()
                : ListView(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.only(top: 8, bottom: 12),
                    children: _buildList(),
                  ),
          ),

          // ── Input ──────────────────────────────────────────
          ChatInputBar(onSendText: _onSendText, onSendImage: _onSendImage),
        ],
      ),
    );
  }

  Widget _emptyState() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFFB8974A).withOpacity(0.10),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Icon(
            Icons.chat_bubble_outline_rounded,
            color: Color(0xFFB8974A),
            size: 32,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.isGroup ? 'No messages yet' : 'Start the conversation',
          style: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          widget.isGroup ? 'Be the first to say hello!' : 'Say hi 👋',
          style: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 13),
        ),
      ],
    ),
  );
}
