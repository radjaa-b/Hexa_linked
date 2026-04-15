import 'package:flutter/material.dart';
import '../widgets/request_hub_card.dart';
import '../widgets/requests_design.dart';
import 'maintenance_screen.dart';
import 'visitor_screen.dart';
import 'booking_screen.dart';
import 'parking_screen.dart';

class RequestsHubScreen extends StatelessWidget {
  const RequestsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── App bar / Header ─────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: const BoxDecoration(
                  color: AppColors.darkGreen,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.parchment.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: AppColors.gold.withOpacity(0.30),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.assignment_rounded,
                        color: AppColors.parchment,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Requests',
                            style: TextStyle(
                              color: AppColors.parchment,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Submit & track your requests',
                            style: TextStyle(
                              color: AppColors.mutedGreen,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Body ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),

                    RequestHubCard(
                      icon: Icons.build_outlined,
                      title: 'Maintenance Request',
                      subtitle:
                          'Report an issue or request a repair in your unit or common areas.',
                      accentColor: AppColors.gold,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MaintenanceScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    RequestHubCard(
                      icon: Icons.badge_outlined,
                      title: 'Visitor Pass',
                      subtitle:
                          'Register an expected visitor and generate a one-time entry pass.',
                      accentColor: AppColors.teal,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const VisitorScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    RequestHubCard(
                      icon: Icons.meeting_room_outlined,
                      title: 'Book Shared Area',
                      subtitle:
                          'Reserve the gym, pool, rooftop, or other shared facilities.',
                      accentColor: AppColors.darkGreen,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BookingScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    RequestHubCard(
                      icon: Icons.local_parking_rounded,
                      title: 'Parking Lot',
                      subtitle:
                          'Check available and occupied parking spots in the residence.',
                      accentColor: AppColors.teal,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ParkingScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Activity Overview ─────────────────────
                    const Text(
                      'Activity Overview',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 12),

                    const _ActivityCard(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard();

  @override
  Widget build(BuildContext context) {
    const int bookings = 2;
    const int bookingsMax = 5;
    const int requests = 1;
    const int requestsMax = 4;
    const int visitors = 3;
    const int visitorsMax = 6;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.gold.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: const Column(
        children: [
          _ActivityStatRow(
            icon: Icons.calendar_month_rounded,
            label: 'Active Bookings',
            value: bookings,
            max: bookingsMax,
            color: AppColors.gold,
          ),
          SizedBox(height: 18),
          _ActivityStatRow(
            icon: Icons.assignment_outlined,
            label: 'Open Requests',
            value: requests,
            max: requestsMax,
            color: Color(0xFF5B9BD5),
          ),
          SizedBox(height: 18),
          _ActivityStatRow(
            icon: Icons.people_outline_rounded,
            label: 'Visitor Passes',
            value: visitors,
            max: visitorsMax,
            color: AppColors.teal,
          ),
        ],
      ),
    );
  }
}

class _ActivityStatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final int max;
  final Color color;

  const _ActivityStatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.max,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = value / max;

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.darkGreen,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '$value / $max',
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: AppColors.parchment,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}