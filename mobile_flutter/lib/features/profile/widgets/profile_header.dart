import 'package:flutter/material.dart';
import 'package:resident_app/features/profile/models/resident_profile.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.profile});

  final ResidentProfile profile;

  @override
  Widget build(BuildContext context) {
    final displayName = profile.name.trim().isEmpty ? 'Resident' : profile.name;
    final displayInitials = profile.initials;
    final displayRole = _formatRole(profile.role);

    return SizedBox(
      width: double.infinity,
      height: 280,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 260,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D2318),
                  Color(0xFF1C3B2E),
                  Color(0xFF2A5240),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
              child: CustomPaint(painter: _PatternPainter()),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 104,
                          height: 104,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFB8974A).withOpacity(0.25),
                              width: 8,
                            ),
                          ),
                        ),
                        Container(
                          width: 92,
                          height: 92,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFB8974A).withOpacity(0.60),
                              width: 2,
                            ),
                            color: const Color(0xFFB8974A).withOpacity(0.15),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            displayInitials,
                            style: const TextStyle(
                              color: Color(0xFFE8D9B5),
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      displayName,
                      style: const TextStyle(
                        color: Color(0xFFE8D9B5),
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB8974A).withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFB8974A).withOpacity(0.45),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        displayRole,
                        style: const TextStyle(
                          color: Color(0xFFB8974A),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatRole(String? role) {
    final raw = (role ?? 'resident').trim();
    if (raw.isEmpty) return 'Resident';

    return raw
        .replaceAll('_', ' ')
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}

class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE8D9B5).withOpacity(0.04)
      ..style = PaintingStyle.fill;

    const spacing = 28.0;
    const radius = 1.8;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }

    final circlePaint = Paint()
      ..color = const Color(0xFFB8974A).withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.15),
      80,
      circlePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.85),
      60,
      circlePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.15),
      120,
      circlePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
