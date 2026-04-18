import 'package:flutter/material.dart';

import '../models/announcement_model.dart';

class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({
    super.key,
    required this.item,
    required this.canManage,
    this.onEdit,
    this.onDelete,
  });

  final AnnouncementModel item;
  final bool canManage;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final authorInitial = item.author.isNotEmpty
        ? item.author[0].toUpperCase()
        : '?';

    return Container(
      width: 280,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: item.isPinned ? const Color(0xFFFFF8EA) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border(left: BorderSide(color: item.accent, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: item.accent.withOpacity(0.15),
                child: Text(
                  authorInitial,
                  style: TextStyle(
                    color: item.accent,
                    fontSize: 13,
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
                      item.author,
                      style: const TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        if (item.isPinned)
                          Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: item.accent.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Pinned',
                              style: TextStyle(
                                color: item.accent,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        Text(
                          item.timeAgo,
                          style: const TextStyle(
                            color: Color(0xFF9A9A9A),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (canManage)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit?.call();
                    } else if (value == 'delete') {
                      onDelete?.call();
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: Color(0xFF7D7D7D),
                    size: 20,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Text(
              item.content,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF5A5A5A),
                fontSize: 13,
                height: 1.5,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnnouncementCarousel extends StatelessWidget {
  const AnnouncementCarousel({
    super.key,
    required this.items,
    required this.canManage,
    this.onEdit,
    this.onDelete,
  });

  final List<AnnouncementModel> items;
  final bool Function(AnnouncementModel announcement) canManage;
  final void Function(AnnouncementModel announcement)? onEdit;
  final void Function(AnnouncementModel announcement)? onDelete;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (_, i) {
          final item = items[i];

          return AnnouncementCard(
            item: item,
            canManage: canManage(item),
            onEdit: onEdit == null ? null : () => onEdit!(item),
            onDelete: onDelete == null ? null : () => onDelete!(item),
          );
        },
      ),
    );
  }
}
