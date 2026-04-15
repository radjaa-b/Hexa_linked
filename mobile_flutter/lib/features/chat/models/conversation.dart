// ─────────────────────────────────────────────────────────────
//  CONVERSATION MODEL
//  Holds the data shape of one private DM conversation.
//  Location: lib/features/chat/models/
//
//  ⚠️ RADJA — map your API JSON response to this model.
//  Your backend needs a conversations table:
//    id, participant_1_id, participant_2_id, last_message,
//    last_message_at, unread_count
// ─────────────────────────────────────────────────────────────

class Conversation {
  final String id;
  final String otherUserId;
  final String otherUserName;
  final String otherUserUnit;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;
  final bool isMe; // was the last message sent by me?

  const Conversation({
    required this.id,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserUnit,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.unreadCount,
    required this.isMe,
  });

  // TODO (Radja): replace with real JSON parsing
  // factory Conversation.fromJson(Map<String, dynamic> json, String currentUserId) {
  //   final isParticipant1 = json['participant_1_id'] == currentUserId;
  //   return Conversation(
  //     id:              json['id'],
  //     otherUserId:     isParticipant1 ? json['participant_2_id']   : json['participant_1_id'],
  //     otherUserName:   isParticipant1 ? json['participant_2_name'] : json['participant_1_name'],
  //     otherUserUnit:   isParticipant1 ? json['participant_2_unit'] : json['participant_1_unit'],
  //     lastMessage:     json['last_message'],
  //     lastMessageAt:   DateTime.parse(json['last_message_at']),
  //     unreadCount:     json['unread_count'] ?? 0,
  //     isMe:            json['last_sender_id'] == currentUserId,
  //   );
  // }
}

// ─────────────────────────────────────────────────────────────
//  RESIDENT MODEL
//  Used when browsing/searching residents to start a new DM.
//
//  ⚠️ RADJA — expose a GET /residents endpoint that returns
//  all residents except the currently logged-in user.
// ─────────────────────────────────────────────────────────────
class Resident {
  final String id;
  final String name;
  final String unit;

  const Resident({
    required this.id,
    required this.name,
    required this.unit,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  // TODO (Radja): replace with real JSON parsing
  // factory Resident.fromJson(Map<String, dynamic> json) {
  //   return Resident(
  //     id:   json['id'],
  //     name: json['name'],
  //     unit: json['unit'],
  //   );
  // }
}