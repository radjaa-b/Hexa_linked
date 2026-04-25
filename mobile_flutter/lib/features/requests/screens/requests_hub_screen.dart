import 'package:flutter/material.dart';
import '../widgets/request_hub_card.dart';
import '../widgets/requests_design.dart';
import 'maintenance_screen.dart';
import 'visitor_screen.dart';
import 'booking_screen.dart';
import 'parking_screen.dart';
import 'package:resident_app/features/auth/services/auth_service.dart';
import '../services/requests_service.dart';
import '../models/maintenance_request.dart';
import '../models/visitor_request.dart';

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

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    RequestHubCard(
                      icon: Icons.build_outlined,
                      title: 'Maintenance Request',
                      subtitle: 'Report an issue or request a repair.',
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
                      subtitle: 'Register a visitor.',
                      accentColor: AppColors.teal,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const VisitorScreen(),
                          ),
                        );

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RequestsHubScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 14),

                    RequestHubCard(
                      icon: Icons.meeting_room_outlined,
                      title: 'Book Shared Area',
                      subtitle: 'Reserve shared spaces.',
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
                      subtitle: 'Check parking spots.',
                      accentColor: AppColors.teal,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ParkingScreen(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Activity Overview',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkGreen,
                        ),
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

class _ActivityCard extends StatefulWidget {
  const _ActivityCard();

  @override
  State<_ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<_ActivityCard> {
  int _openRequests = 0;
  bool _loading = true;

  bool _showVisitors = false;
  bool _showOpenRequests = false;

  List<VisitorRequest> _visitorRequests = [];
  List<MaintenanceRequest> _maintenanceRequests = [];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    try {
      final session = await AuthService.getStoredSession(
        requiredRole: 'resident',
      );

      if (session == null) {
        if (mounted) setState(() => _loading = false);
        return;
      }

      try {
        final maintenance = await RequestsService().getMaintenanceRequests(
          token: session.accessToken,
        );

        final open = maintenance
            .where(
              (r) =>
                  r.status.toLowerCase() == 'pending' ||
                  r.status.toLowerCase() == 'in_progress',
            )
            .length;

        if (mounted) {
          setState(() {
            _openRequests = open;
            _maintenanceRequests = maintenance;
          });
        }
      } catch (e) {
        debugPrint('Maintenance load failed: $e');
      }

      try {
        final visitors = await RequestsService().getMyVisitorRequests(
          token: session.accessToken,
        );

        if (mounted) {
          setState(() {
            _visitorRequests = visitors;
          });
        }
      } catch (e) {
        debugPrint('Visitor requests load failed: $e');
      }
    } catch (e) {
      debugPrint('Activity overview load failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      case 'PENDING':
        return Colors.orange;
      case 'ARRIVED':
        return AppColors.teal;
      case 'EXITED':
      case 'CANCELLED':
      case 'EXPIRED':
        return Colors.grey;
      default:
        return AppColors.darkGreen;
    }
  }

  Widget _miniRequestCard({
    required String title,
    required String subtitle,
    required String status,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold.withOpacity(0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.darkGreen,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.mutedGreen,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _statusColor(status).withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status.toUpperCase(),
              style: TextStyle(
                color: _statusColor(status),
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.gold.withOpacity(0.15)),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.gold,
          ),
        ),
      );
    }

    final openMaintenance = _maintenanceRequests
        .where(
          (r) =>
              r.status.toLowerCase() == 'pending' ||
              r.status.toLowerCase() == 'in_progress',
        )
        .toList();

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.gold.withOpacity(0.15)),
          ),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() => _showVisitors = !_showVisitors);
                },
                child: _ActivityStatRow(
                  icon: Icons.badge_outlined,
                  label: 'Visitor Passes',
                  value: _visitorRequests.length,
                  max: 10,
                  color: AppColors.teal,
                ),
              ),
              if (_showVisitors) ...[
                const SizedBox(height: 8),
                if (_visitorRequests.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      'No visitor requests yet',
                      style: TextStyle(color: AppColors.mutedGreen),
                    ),
                  ),
                ..._visitorRequests.map(
                  (v) => _miniRequestCard(
                    title: v.visitorName,
                    subtitle: '${v.purpose} • ${v.startTime} - ${v.endTime}',
                    status: v.status,
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 14),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.gold.withOpacity(0.15)),
          ),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() => _showOpenRequests = !_showOpenRequests);
                },
                child: _ActivityStatRow(
                  icon: Icons.assignment_outlined,
                  label: 'Open Requests',
                  value: _openRequests,
                  max: 10,
                  color: AppColors.gold,
                ),
              ),
              if (_showOpenRequests) ...[
                const SizedBox(height: 8),
                if (openMaintenance.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      'No open maintenance requests',
                      style: TextStyle(color: AppColors.mutedGreen),
                    ),
                  ),
                ...openMaintenance.map(
                  (r) => _miniRequestCard(
                    title: 'Maintenance Request',
                    subtitle: r.category,
                    status: r.status,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
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
    final double progress = max == 0 ? 0 : (value / max).clamp(0.0, 1.0);

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
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '$value / $max',
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
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
