import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
//  GLANCE ITEM MODEL
// ─────────────────────────────────────────────────────────────
class GlanceItemModel {
  final IconData icon;
  final Color    iconColor;
  final String   label;
  final String   value;
  final String   tag;

  const GlanceItemModel({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.tag,
  });
}

// ─────────────────────────────────────────────────────────────
//  SINGLE GLANCE ROW
// ─────────────────────────────────────────────────────────────
class GlanceItemCard extends StatelessWidget {
  const GlanceItemCard({super.key, required this.item});

  final GlanceItemModel item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [

          // ── Icon bubble ─────────────────────────────────────
          Container(
            width:  40,
            height: 40,
            decoration: BoxDecoration(
              color:        item.iconColor.withOpacity(0.20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: item.iconColor, size: 20),
          ),
          const SizedBox(width: 14),

          // ── Label + value ────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: const TextStyle(
                    color:         Color(0xFF6B9E80), // sage
                    fontSize:      11,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.value,
                  style: const TextStyle(
                    color:      Color(0xFFE8D9B5), // champagne
                    fontSize:   14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // ── Status tag ───────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color:        item.iconColor.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: item.iconColor.withOpacity(0.35),
                width: 1,
              ),
            ),
            child: Text(
              item.tag,
              style: TextStyle(
                color:         item.iconColor,
                fontSize:      10.5,
                fontWeight:    FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),

        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  FULL GLANCE CARD  (dark green container with all rows)
//  Pass a list of GlanceItemModel — renders them with dividers.
// ─────────────────────────────────────────────────────────────
class GlanceCard extends StatelessWidget {
  const GlanceCard({super.key, required this.items});

  final List<GlanceItemModel> items;

  static const _forest      = Color(0xFF1C3B2E);
  static const _forestLight = Color(0xFF2A5240);
  static const _champagne   = Color(0xFFE8D9B5);
  static const _gold        = Color(0xFFB8974A);
  static const _sage        = Color(0xFF6B9E80);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color:        _forest,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color:      _forest.withOpacity(0.25),
            blurRadius: 24,
            offset:     const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [

          // ── Header strip ────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color:        _forestLight,
              borderRadius: const BorderRadius.only(
                topLeft:  Radius.circular(26),
                topRight: Radius.circular(26),
              ),
              border: Border(
                bottom: BorderSide(
                  color: _gold.withOpacity(0.25),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.today_rounded, color: _gold, size: 18),
                const SizedBox(width: 8),
                const Text(
                  'Your Day at a Glance',
                  style: TextStyle(
                    color:         _champagne,
                    fontSize:      14,
                    fontWeight:    FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                const Spacer(),
                Text(
                  'Today',
                  style: TextStyle(
                    color:    _sage.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // ── Glance rows with dividers ────────────────────────
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Column(
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  GlanceItemCard(item: items[i]),
                  if (i < items.length - 1)
                    Divider(
                      color:   _champagne.withOpacity(0.07),
                      height:  1,
                      indent:  68,
                    ),
                ],
              ],
            ),
          ),

        ],
      ),
    );
  }
}