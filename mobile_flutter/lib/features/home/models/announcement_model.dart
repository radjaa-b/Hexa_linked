import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class AnnouncementModel {
  final String id;
  final String authorName;
  final String authorUnit;
  final String content;
  final DateTime createdAt;
  final bool isPinned;
  final String? authorUserId;

  const AnnouncementModel({
    required this.id,
    required this.authorName,
    required this.authorUnit,
    required this.content,
    required this.createdAt,
    required this.isPinned,
    this.authorUserId,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'].toString(),
      authorName: (json['author_username'] ?? json['author'] ?? 'Unknown')
          .toString(),
      authorUnit: (json['author_role'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      createdAt: DateTime.parse(json['created_at'].toString()),
      isPinned: json['is_pinned'] == true,
      authorUserId:
          json['author_user_id']?.toString() ?? json['author_id']?.toString(),
    );
  }

  String get timeAgo => timeago.format(createdAt);

  Color get accent {
    if (isPinned) return const Color(0xFF1D9E75);
    return const Color(0xFF4C7EFF);
  }

  // Compatibility getters for newer UI code
  String get author => authorName;
  int? get authorId =>
      authorUserId == null ? null : int.tryParse(authorUserId!);
}
