import 'dart:async';
import 'package:flutter/material.dart';

import 'package:resident_app/services/weather_service.dart';
import 'package:resident_app/features/home/widgets/announcement_card.dart';
import 'package:resident_app/features/home/widgets/glance_item_card.dart';
import 'package:resident_app/features/pass/screens/resident_pass_screen.dart';
import 'package:resident_app/features/consumption/widgets/consumption_preview_card.dart';

// ─────────────────────────────────────────────────────────────
//  MOCK DATA
// ─────────────────────────────────────────────────────────────
final _announcements = [
  AnnouncementModel(
    authorName: 'Radja B',
    authorUnit: 'Unit 4B',
    content:
        'Pool maintenance this Saturday 9–12 AM. Access will be restricted during that time.',
    timeAgo: '2h ago',
    accent: const Color(0xFF2A7F62),
  ),
  AnnouncementModel(
    authorName: 'Anfel B.',
    authorUnit: 'Unit 2A',
    content:
        'Lost a set of keys near the main entrance. Please contact me if found. Thank you!',
    timeAgo: '5h ago',
    accent: const Color(0xFFB8974A),
  ),
  AnnouncementModel(
    authorName: 'Management',
    authorUnit: 'Admin',
    content:
        'Elevator B will be out of service Monday for scheduled inspection. Use elevator A.',
    timeAgo: '1d ago',
    accent: const Color(0xFFC0392B),
  ),
  AnnouncementModel(
    authorName: 'fadwa T.',
    authorUnit: 'Unit 7C',
    content:
        'Organising a rooftop gathering Friday evening. All residents welcome — RSVP by Thursday!',
    timeAgo: '1d ago',
    accent: const Color(0xFF5B7FA6),
  ),
];

final _glanceItems = [
  const GlanceItemModel(
    icon: Icons.event_available_rounded,
    iconColor: Color(0xFF2A7F62),
    label: 'Next Booking',
    value: 'Gym — 6:00 PM',
    tag: 'Today',
  ),
  const GlanceItemModel(
    icon: Icons.assignment_turned_in_rounded,
    iconColor: Color(0xFFB8974A),
    label: 'Pending Request',
    value: 'Maintenance — Unit 3A',
    tag: 'In Review',
  ),
  const GlanceItemModel(
    icon: Icons.person_pin_circle_rounded,
    iconColor: Color(0xFF5B7FA6),
    label: 'Next Visitor',
    value: 'Kami benamouna. — 3:00 PM',
    tag: 'Approved',
  ),
];

// ─────────────────────────────────────────────────────────────
//  HOME SCREEN
// ─────────────────────────────────────────────────────────────
class ResidentHomeScreen extends StatefulWidget {
  const ResidentHomeScreen({super.key});

  @override
  State<ResidentHomeScreen> createState() => _ResidentHomeScreenState();
}

class _ResidentHomeScreenState extends State<ResidentHomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  late final Animation<double> _fade = CurvedAnimation(
    parent: _fadeCtrl,
    curve: Curves.easeOut,
  );

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _showAddAnnouncementSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddAnnouncementSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: FadeTransition(
        opacity: _fade,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: _GreetingHeader()),
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: 'Announcements',
                actionLabel: '+ Add',
                onAction: _showAddAnnouncementSheet,
              ),
            ),
            SliverToBoxAdapter(
              child: AnnouncementCarousel(items: _announcements),
            ),
            const SliverToBoxAdapter(
              child: _SectionHeader(title: 'Your Day at a Glance'),
            ),
            SliverToBoxAdapter(
              child: GlanceCard(items: _glanceItems),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),
            const SliverToBoxAdapter(
              child: ConsumptionPreviewCard(),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 120),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  GREETING HEADER
// ─────────────────────────────────────────────────────────────
class _GreetingHeader extends StatefulWidget {
  const _GreetingHeader();

  @override
  State<_GreetingHeader> createState() => _GreetingHeaderState();
}

class _GreetingHeaderState extends State<_GreetingHeader> {
  WeatherData? _weather;
  bool _loading = true;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _loadWeather();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _loadWeather() async {
    final data = await WeatherService.fetchCurrent();
    if (mounted) {
      setState(() {
        _weather = data;
        _loading = false;
      });
    }
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      color: const Color(0xFFF5F0E8),
      padding: EdgeInsets.only(top: topPad + 16, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top bar: avatar + label + greeting + QR ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF2A5240),
                    border: Border.all(
                      color: const Color(0xFF6B9E80),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Color(0xFF6B9E80),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                // App label + greeting
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'HEXA RESIDENT',
                      style: TextStyle(
                        color: Color(0xFF6B9E80),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      '$_greeting, Selsa',
                      style: const TextStyle(
                        color: Color(0xFF6B9E80),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // QR code button
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ResidentPassScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B9E80).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFB8974A).withOpacity(0.30),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.qr_code,
                      color: Color(0xFFE8D9B5),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Secure Habitat status card ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF152E22),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shield icon + label
                  Row(
                    children: [
                      const Icon(
                        Icons.shield_outlined,
                        color: Color(0xFF6B9E80),
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'SECURE HABITAT',
                        style: TextStyle(
                          color: Color(0xFF6B9E80),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  const Text(
                    'Your home is secure\n& climate-controlled.',
                    style: TextStyle(
                      color: Color(0xFFE8D9B5),
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      _buildPill(
                        icon: Icons.thermostat_rounded,
                        label: _weather != null
                            ? '${_weather!.temperature.toStringAsFixed(0)}°C  •  Indoor'
                            : '--°C  •  Indoor',
                      ),
                      _buildPill(
                        icon: Icons.check_circle_outline_rounded,
                        label: 'No alerts',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Weather floating card ──
          if (!_loading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                color: const Color(0xFF152E22), // same as status card
                    borderRadius: BorderRadius.circular(16),
            ),
                child: Row(
                  children: [
                    Icon(
                      _weather != null
                          ? WeatherService.iconFromCode(_weather!.icon)
                          : Icons.wb_sunny_rounded,
                      color: const Color(0xFFB8974A),
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _weather != null
                              ? '${_weather!.temperature.toStringAsFixed(0)}°'
                              : '--°',
                          style: const TextStyle(
                            color: Color(0xFFE8D9B5),
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          _weather?.description ?? 'Loading…',
                          style: const TextStyle(
                            color: Color(0xFF6B9E80),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Text(
                      'FORECAST',
                      style: TextStyle(
                        color: Color(0xFF6B9E80),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPill({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE8D9B5).withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF6B9E80).withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF6B9E80), size: 13),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFE8D9B5),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  SECTION HEADER
// ─────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFFB8974A),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C3B2E),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  actionLabel!,
                  style: const TextStyle(
                    color: Color(0xFFE8D9B5),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  ADD ANNOUNCEMENT BOTTOM SHEET
// ─────────────────────────────────────────────────────────────
class _AddAnnouncementSheet extends StatefulWidget {
  const _AddAnnouncementSheet();

  @override
  State<_AddAnnouncementSheet> createState() => _AddAnnouncementSheetState();
}

class _AddAnnouncementSheetState extends State<_AddAnnouncementSheet> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(
      () => setState(() => _hasText = _controller.text.trim().isNotEmpty),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF9A9A9A).withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'New Announcement',
            style: TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Share something with all residents',
            style: TextStyle(
              color: Color(0xFF9A9A9A),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F0E8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFB8974A).withOpacity(0.30),
                width: 1,
              ),
            ),
            child: TextField(
              controller: _controller,
              maxLines: 4,
              autofocus: true,
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 14,
                height: 1.5,
              ),
              decoration: const InputDecoration(
                hintText: 'Write your announcement here…',
                hintStyle: TextStyle(color: Color(0xFF9A9A9A)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: _hasText
                    ? const Color(0xFF1C3B2E)
                    : const Color(0xFF9A9A9A).withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextButton(
                onPressed: _hasText ? () => Navigator.pop(context) : null,
                child: Text(
                  'Post Announcement',
                  style: TextStyle(
                    color: _hasText
                        ? const Color(0xFFE8D9B5)
                        : const Color(0xFF9A9A9A),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}