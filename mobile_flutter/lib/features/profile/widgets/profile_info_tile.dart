// ─────────────────────────────────────────────────────────────
//  PROFILE INFO TILE WIDGET — Dark theme
//  One single info row used for name, email, phone, unit.
//  Location: lib/features/profile/widgets/
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

class ProfileInfoTile extends StatelessWidget {
  const ProfileInfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String   label;
  final String   value;
  final bool     isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [

          // Icon
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color:        const Color(0xFFB8974A).withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFFB8974A), size: 17),
          ),
          const SizedBox(width: 14),

          // Label + value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color:         Color(0xFF8A9E92),
                    fontSize:      10,
                    fontWeight:    FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color:      Color(0xFFE8E4DC),
                    fontSize:   15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Read only lock
          const Icon(
            Icons.lock_outline_rounded,
            color: Color(0xFF3A5244),
            size:  15,
          ),
        ],
      ),
    );
  }
}