import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
//  ANNOUNCEMENT MODEL
//  Place this in your models/ folder if you prefer, or keep it
//  here and import it wherever needed.
// ─────────────────────────────────────────────────────────────
class AnnouncementModel {
  final String authorName;
  final String authorUnit;
  final String content;
  final String timeAgo;
  final Color  accent;

  const AnnouncementModel({
    required this.authorName,
    required this.authorUnit,
    required this.content,
    required this.timeAgo,
    required this.accent,
  });
}

// ─────────────────────────────────────────────────────────────
//  ANNOUNCEMENT CARD WIDGET
// ─────────────────────────────────────────────────────────────
class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({super.key, required this.item});

  final AnnouncementModel item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width:   260,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset:     const Offset(0, 6),
          ),
        ],
        border: Border(
          left: BorderSide(color: item.accent, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Author row ──────────────────────────────────────
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: item.accent.withOpacity(0.15),
                child: Text(
                  item.authorName[0],
                  style: TextStyle(
                    color:      item.accent,
                    fontSize:   13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.authorName,
                      style: const TextStyle(
                        color:      Color(0xFF1A1A1A),
                        fontSize:   13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      item.authorUnit,
                      style: const TextStyle(
                        color:    Color(0xFF9A9A9A),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                item.timeAgo,
                style: const TextStyle(
                  color:    Color(0xFF9A9A9A),
                  fontSize: 11,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Content ─────────────────────────────────────────
          Expanded(
            child: Text(
              item.content,
              maxLines:  3,
              overflow:  TextOverflow.ellipsis,
              style: const TextStyle(
                color:         Color(0xFF5A5A5A),
                fontSize:      13,
                height:        1.5,
                letterSpacing: 0.1,
              ),
            ),
          ),

        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  ANNOUNCEMENT CAROUSEL
//  A ready-to-use horizontal list of AnnouncementCards.
//  Drop this directly into your screen's widget tree.
// ─────────────────────────────────────────────────────────────
class AnnouncementCarousel extends StatelessWidget {
  const AnnouncementCarousel({super.key, required this.items});

  final List<AnnouncementModel> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 172,
      child: ListView.separated(
        scrollDirection:  Axis.horizontal,
        physics:          const BouncingScrollPhysics(),
        padding:          const EdgeInsets.symmetric(horizontal: 24),
        itemCount:        items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder:      (_, i)  => AnnouncementCard(item: items[i]),
      ),
    );
  }
}