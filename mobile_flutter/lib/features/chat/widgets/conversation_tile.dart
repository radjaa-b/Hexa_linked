// ─────────────────────────────────────────────────────────────
//  CONVERSATION TILE WIDGET
//  One DM conversation row shown in the chat list.
//  Location: lib/features/chat/widgets/
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:resident_app/features/chat/models/conversation.dart';

class ConversationTile extends StatelessWidget {
  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  final Conversation conversation;
  final VoidCallback onTap;

  String _timeLabel(DateTime dt) {
    final now  = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1)  return 'now';
    if (diff.inHours   < 1)  return '${diff.inMinutes}m';
    if (diff.inHours   < 24) return '${diff.inHours}h';
    if (diff.inDays    < 7)  return '${diff.inDays}d';
    return '${dt.day}/${dt.month}';
  }

  Color _avatarColor(String name) {
    const colors = [
      Color(0xFF2A7F62), Color(0xFF5B7FA6),
      Color(0xFFB8974A), Color(0xFF7B5EA7), Color(0xFF2A5240),
    ];
    return colors[name.codeUnits.fold(0, (a, b) => a + b) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = conversation.unreadCount > 0;
    final color     = _avatarColor(conversation.otherUserName);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: const Color(0xFF1C3B2E).withOpacity(0.06),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [

            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius:          26,
                  backgroundColor: color.withOpacity(0.15),
                  child: Text(
                    conversation.otherUserName
                        .split(' ')
                        .map((p) => p.isNotEmpty ? p[0] : '')
                        .take(2)
                        .join()
                        .toUpperCase(),
                    style: TextStyle(
                      color:      color,
                      fontSize:   15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                // Unread dot
                if (hasUnread)
                  Positioned(
                    right: 0, top: 0,
                    child: Container(
                      width: 14, height: 14,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1C3B2E),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${conversation.unreadCount}',
                        style: const TextStyle(
                          color:    Color(0xFFE8D9B5),
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),

            // Name + last message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.otherUserName,
                          style: TextStyle(
                            color:      const Color(0xFF1A1A1A),
                            fontSize:   15,
                            fontWeight: hasUnread
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        _timeLabel(conversation.lastMessageAt),
                        style: TextStyle(
                          color:      hasUnread
                              ? const Color(0xFF1C3B2E)
                              : const Color(0xFF9A9A9A),
                          fontSize:   11,
                          fontWeight: hasUnread
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (conversation.isMe)
                        const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Text('You: ',
                              style: TextStyle(
                                  color: Color(0xFF9A9A9A),
                                  fontSize: 13)),
                        ),
                      Expanded(
                        child: Text(
                          conversation.lastMessage.isEmpty
                              ? 'Start a conversation'
                              : conversation.lastMessage,
                          maxLines:  1,
                          overflow:  TextOverflow.ellipsis,
                          style: TextStyle(
                            color:      hasUnread
                                ? const Color(0xFF1A1A1A)
                                : const Color(0xFF9A9A9A),
                            fontSize:   13,
                            fontWeight: hasUnread
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    conversation.otherUserUnit,
                    style: const TextStyle(
                        color: Color(0xFFB8974A),
                        fontSize: 11,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}