import 'package:flutter/material.dart';
import 'package:resident_app/core/navigation/app_route.dart';
import '../widgets/auth_scaffold.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),

          // ── Logo mark + brand ──
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFB8974A).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFB8974A).withOpacity(0.35),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.home_work_outlined,
                  color: Color(0xFFB8974A),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'HexaGate',
                    style: TextStyle(
                      color: Color(0xFFE8D9B5),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  Text(
                    'PRIVATE LIVING',
                    style: TextStyle(
                      color: Color(0xFF6B9E80),
                      fontSize: 10,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const Spacer(),

          // ── Big headline ──
          const Text(
            'WELCOME',
            style: TextStyle(
              color: Color(0xFFB8974A),
              fontSize: 11,
              letterSpacing: 2.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Your home,\nelevated.',
            style: TextStyle(
              color: Color(0xFFE8D9B5),
              fontSize: 36,
              fontWeight: FontWeight.w800,
              height: 1.1,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Access services, announcements,\nand requests — all in one place.',
            style: TextStyle(
              color: Color(0xFF6B9E80),
              fontSize: 13,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 32),

          // ── Bottom panel ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF152E22),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your account is created by the\nresidence administration.',
                  style: TextStyle(
                    color: Color(0xFF6B9E80),
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),

                // Sign in button
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      fadeSlideRoute(const LoginScreen()),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB8974A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Sign in',
                        style: TextStyle(
                          color: Color(0xFF1C3B2E),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Divider
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 0.5,
                        color: const Color(0xFF6B9E80).withOpacity(0.2),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'HEXAGATE',
                        style: TextStyle(
                          color: Color(0xFF6B9E80),
                          fontSize: 10,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 0.5,
                        color: const Color(0xFF6B9E80).withOpacity(0.2),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Feature pills
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    'Bookings',
                    'Maintenance',
                    'Announcements',
                    'Visitors',
                  ].map((label) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B9E80).withOpacity(0.10),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF6B9E80).withOpacity(0.25),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Color(0xFF6B9E80),
                        fontSize: 10,
                      ),
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}