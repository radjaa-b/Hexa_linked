// ─────────────────────────────────────────────────────────────
//  MESSAGE MODEL
//  RADJA (backend): map your API JSON response to this model
// ─────────────────────────────────────────────────────────────

enum MessageType { text, image }

class Message {
  final String      id;
  final String      senderId;
  final String      senderName;
  final String      senderUnit;
  final String      content;     // text OR image URL
  final MessageType type;
  final DateTime    sentAt;
  final bool        isMe;

  const Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderUnit,
    required this.content,
    required this.type,
    required this.sentAt,
    required this.isMe,
  });
}