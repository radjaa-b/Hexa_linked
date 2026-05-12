import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:resident_app/features/auth/services/auth_service.dart';
import 'package:resident_app/features/chat/models/message.dart';
import 'package:resident_app/features/chat/services/chat_service.dart';
import 'package:resident_app/features/chat/widgets/chat_input_bar.dart';
import 'package:resident_app/features/chat/widgets/message_bubble.dart';

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
  bool _socketConnected = false;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

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

  // ─── Data loading ─────────────────────────────────────────────────────────

  Future<void> _load() async {
    try {
      // Ensure currentUserId is loaded BEFORE we start comparing sender IDs.
      await ChatService.ensureUserLoaded();

      final msgs = await ChatService.fetchMessages(widget.conversationId);

      if (!mounted) return;

      setState(() {
        _messages = msgs;
        _loading = false;
      });

      _scrollToBottom(animated: false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  // ─── WebSocket ────────────────────────────────────────────────────────────

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

    // conversationId is a String in the widget; the backend expects an int path
    // segment — that's fine, the string digits work correctly in the URL.
    final wsUrl =
        '$wsBaseUrl/chat/conversations/${widget.conversationId}/ws?token=$token';

    debugPrint('🔌 Connecting WebSocket: $wsUrl');

    try {
      _socket = await WebSocket.connect(wsUrl);

      if (!mounted) return;

      setState(() => _socketConnected = true);
      debugPrint('✅ WebSocket connected');

      _socket!.listen(
        _onSocketData,
        onError: (error) {
          debugPrint('❌ WebSocket error: $error');
        },
        onDone: () {
          debugPrint('🔌 WebSocket closed');
          if (!mounted) return;
          setState(() => _socketConnected = false);
        },
      );
    } catch (e) {
      debugPrint('❌ WebSocket connection failed: $e');
      if (!mounted) return;
      setState(() => _socketConnected = false);
    }
  }

  void _onSocketData(dynamic data) {
    debugPrint('📩 WebSocket received: $data');

    try {
      final jsonData = jsonDecode(data as String) as Map<String, dynamic>;

      // ── Key fix: compare as strings to avoid int/string type mismatch ──
      final senderId = jsonData['sender_id'].toString();
      final messageId = jsonData['id'].toString();
      final isMe = senderId == ChatService.currentUserId;

      final senderNameRaw =
          (jsonData['sender_name'] ?? jsonData['sender_username'])
              ?.toString()
              .trim();

      final msg = Message(
        id: messageId,
        senderId: senderId,
        senderName: isMe
            ? ChatService.currentUserName
            : (senderNameRaw != null && senderNameRaw.isNotEmpty
                  ? senderNameRaw
                  : widget.title),
        senderUnit: isMe ? ChatService.currentUserUnit : widget.subtitle,
        content: (jsonData['content'] ?? '').toString(),
        type: MessageType.text,
        sentAt:
            DateTime.tryParse(jsonData['created_at'].toString()) ??
            DateTime.now(),
        isMe: isMe,
      );

      if (!mounted) return;

      // Deduplicate: ignore if we already have this message ID.
      if (_messages.any((m) => m.id == msg.id)) {
        debugPrint('⚠️ Duplicate WS message ignored: ${msg.id}');
        return;
      }

      setState(() {
        _messages.add(msg);
      });

      _scrollToBottom();
    } catch (e, st) {
      debugPrint('❌ Failed to handle WebSocket message: $e\n$st');
    }
  }

  // ─── Sending ──────────────────────────────────────────────────────────────

  Future<void> _onSendText(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    HapticFeedback.lightImpact();

    // ── Key fix: send through WebSocket, NOT REST ──────────────────────────
    // The backend WebSocket handler saves the message AND broadcasts to every
    // connected client (including the sender), so both phones update instantly.
    if (_socket != null && _socketConnected) {
      try {
        _socket!.add(jsonEncode({'content': trimmed}));
        // Do NOT append locally — wait for the echo from broadcast so the
        // message gets its real DB id and created_at timestamp.
        return;
      } catch (e) {
        debugPrint('⚠️ WS send failed, falling back to REST: $e');
      }
    }

    // ── Fallback: REST (only when socket is down) ──────────────────────────
    // sendMessage() returns void, so we optimistically append a local message
    // so the sender sees it immediately (no real DB id available here).
    debugPrint('⚠️ Sending via REST fallback');
    try {
      await ChatService.sendMessage(widget.conversationId, trimmed);
      if (!mounted) return;

      // Optimistic local append — use a temporary id so the dedup check
      // won't clash with a real DB id arriving later via WebSocket.
      final tempMsg = Message(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        senderId: ChatService.currentUserId,
        senderName: ChatService.currentUserName,
        senderUnit: ChatService.currentUserUnit,
        content: trimmed,
        type: MessageType.text,
        sentAt: DateTime.now(),
        isMe: true,
      );

      setState(() => _messages.add(tempMsg));
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  void _onSendImage(String path) {
    HapticFeedback.lightImpact();

    final msg = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: ChatService.currentUserId,
      senderName: ChatService.currentUserName,
      senderUnit: ChatService.currentUserUnit,
      content: path,
      type: MessageType.image,
      sentAt: DateTime.now(),
      isMe: true,
    );

    setState(() => _messages.add(msg));
    _scrollToBottom();
    ChatService.sendImage(path);
  }

  // ─── Scroll ───────────────────────────────────────────────────────────────

  void _scrollToBottom({bool animated = true}) {
    // We need two frames:
    //   Frame 1: setState has been processed, ListView rebuilds.
    //   Frame 2: the new items have been laid out and maxScrollExtent is final.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_scrollCtrl.hasClients) return;

        final maxExtent = _scrollCtrl.position.maxScrollExtent;

        if (animated) {
          _scrollCtrl.animateTo(
            maxExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else {
          _scrollCtrl.jumpTo(maxExtent);
        }
      });
    });
  }

  // ─── Build helpers ────────────────────────────────────────────────────────

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

  // ─── UI ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: Column(
        children: [
          _buildHeader(context),
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
          ChatInputBar(onSendText: _onSendText, onSendImage: _onSendImage),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
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
              widget.isGroup ? Icons.groups_rounded : Icons.person_rounded,
              color: const Color(0xFFE8D9B5),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
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
                  _socketConnected
                      ? widget.subtitle
                      : '${widget.subtitle} • connecting...',
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
