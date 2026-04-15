import 'package:flutter/material.dart';
import 'package:resident_app/features/chat/models/message.dart';

// ─────────────────────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────────────────────
class _C {
  static const forest    = Color(0xFF1C3B2E);
  static const champagne = Color(0xFFE8D9B5);
  static const gold      = Color(0xFFB8974A);
  static const sage      = Color(0xFF6B9E80);
  static const pageBg    = Color(0xFFF5F0E8);
  static const textDark  = Color(0xFF1A1A1A);
  static const textGray  = Color(0xFF9A9A9A);
}

// ─────────────────────────────────────────────────────────────
//  MESSAGE BUBBLE
// ─────────────────────────────────────────────────────────────
class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message});
  final Message message;

  String _time(DateTime dt) {
    final h    = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m    = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [

          // Avatar — other people only
          if (!isMe) ...[
            _Avatar(name: message.senderName),
            const SizedBox(width: 8),
          ],

          // Bubble
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [

                // Sender name + unit — other people only
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 4),
                    child: RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text: message.senderName,
                          style: const TextStyle(
                            color: _C.forest, fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: '  ${message.senderUnit}',
                          style: const TextStyle(
                            color: _C.textGray, fontSize: 11,
                          ),
                        ),
                      ]),
                    ),
                  ),

                // Bubble body
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.65,
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? _C.forest : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft:     const Radius.circular(18),
                      topRight:    const Radius.circular(18),
                      bottomLeft:  Radius.circular(isMe ? 18 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:      Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset:     const Offset(0, 2),
                      ),
                    ],
                    border: isMe
                        ? null
                        : Border.all(
                            color: _C.gold.withOpacity(0.15), width: 1),
                  ),
                  child: message.type == MessageType.image
                      ? _ImageContent(url: message.content, isMe: isMe)
                      : Text(
                          message.content,
                          style: TextStyle(
                            color:    isMe ? _C.champagne : _C.textDark,
                            fontSize: 14,
                            height:   1.4,
                          ),
                        ),
                ),

                // Timestamp
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                  child: Text(
                    _time(message.sentAt),
                    style: const TextStyle(
                        color: _C.textGray, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),

          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  AVATAR
// ─────────────────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  const _Avatar({required this.name});
  final String name;

  Color _color(String name) {
    const colors = [
      Color(0xFF2A7F62), Color(0xFF5B7FA6),
      Color(0xFFB8974A), Color(0xFF7B5EA7), Color(0xFF2A5240),
    ];
    return colors[name.codeUnits.fold(0, (a, b) => a + b) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final c = _color(name);
    return CircleAvatar(
      radius: 18,
      backgroundColor: c.withOpacity(0.15),
      child: Text(
        name[0],
        style: TextStyle(
            color: c, fontSize: 14, fontWeight: FontWeight.w700),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  IMAGE CONTENT
// ─────────────────────────────────────────────────────────────
class _ImageContent extends StatelessWidget {
  const _ImageContent({required this.url, required this.isMe});
  final String url;
  final bool   isMe;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        url,
        width:   200,
        fit:     BoxFit.cover,
        loadingBuilder: (_, child, progress) => progress == null
            ? child
            : Container(
                width: 200, height: 140,
                color: Colors.black.withOpacity(0.05),
                child: const Center(
                  child: CircularProgressIndicator(
                      color: Color(0xFFB8974A), strokeWidth: 2),
                ),
              ),
        errorBuilder: (_, __, ___) => Container(
          width: 200, height: 100,
          decoration: BoxDecoration(
            color:        Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Icon(Icons.broken_image_rounded,
                color: Color(0xFF9A9A9A), size: 32),
          ),
        ),
      ),
    );
  }
}