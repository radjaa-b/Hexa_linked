import 'dart:async';

import 'package:flutter/material.dart';

import 'package:resident_app/features/auth/services/auth_service.dart';
import 'package:resident_app/features/consumption/widgets/consumption_preview_card.dart';
import 'package:resident_app/features/home/models/announcement_model.dart';
import 'package:resident_app/features/home/services/home_service.dart';
import 'package:resident_app/features/home/widgets/announcement_card.dart';
import 'package:resident_app/features/home/widgets/glance_item_card.dart';
import 'package:resident_app/features/pass/screens/resident_pass_screen.dart';
import 'package:resident_app/services/weather_service.dart';
import 'package:resident_app/features/requests/services/requests_service.dart';
import 'package:resident_app/features/requests/models/maintenance_request.dart';

class ResidentHomeScreen extends StatefulWidget {
  const ResidentHomeScreen({super.key});

  @override
  State<ResidentHomeScreen> createState() => _ResidentHomeScreenState();
}

class _ResidentHomeScreenState extends State<ResidentHomeScreen>
    with SingleTickerProviderStateMixin {
  final HomeService _homeService = const HomeService();

  late final AnimationController _fadeCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  late final Animation<double> _fade = CurvedAnimation(
    parent: _fadeCtrl,
    curve: Curves.easeOut,
  );

  List<AnnouncementModel> _announcements = const [];
  bool _loadingAnnouncements = true;
  bool _refreshingAnnouncements = false;
  bool _mutatingAnnouncements = false;
  String? _announcementsError;
  String? _currentUserId;
  String? _currentUserRole;
  MaintenanceRequest? _latestRequest;
  bool _loadingRequest = true;

  @override
  void initState() {
    super.initState();
    _initializeAnnouncements();
    _loadLatestRequest();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _initializeAnnouncements() async {
    final session = await AuthService.getStoredSession();
    if (mounted) {
      setState(() {
        _currentUserId = session?.claims.subject;
        _currentUserRole = session?.role;
      });
    }

    await _loadAnnouncements();
  }

  Future<void> _loadAnnouncements({bool showLoader = true}) async {
    if (mounted) {
      setState(() {
        if (showLoader) {
          _loadingAnnouncements = true;
          _announcementsError = null;
        } else {
          _refreshingAnnouncements = true;
        }
      });
    }

    try {
      final announcements = await _homeService.fetchAnnouncements();
      if (!mounted) return;

      setState(() {
        _announcements = announcements;
        _announcementsError = null;
      });
    } catch (error) {
      final message = _formatErrorMessage(error);
      if (!mounted) return;

      setState(() {
        if (_announcements.isEmpty || showLoader) {
          _announcementsError = message;
        }
      });

      if (!showLoader || _announcements.isNotEmpty) {
        _showSnackBar(message, isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingAnnouncements = false;
          _refreshingAnnouncements = false;
        });
      }
    }
  }

  Future<void> _loadLatestRequest() async {
    try {
      final session = await AuthService.getStoredSession(
        requiredRole: 'resident',
      );
      if (session == null) return;

      final requests = await RequestsService().getMaintenanceRequests(
        token: session.accessToken,
      );

      final active = requests
          .where((r) => r.status == 'pending' || r.status == 'in_progress')
          .toList();

      if (mounted) {
        setState(() {
          _latestRequest = active.isNotEmpty ? active.first : null;
        });
      }
    } catch (_) {
      // fail silently
    } finally {
      if (mounted) setState(() => _loadingRequest = false);
    }
  }

  Future<void> _refreshAnnouncements() async {
    await _loadAnnouncements(showLoader: false);
  }

  bool _canManageAnnouncement(AnnouncementModel announcement) {
    final isAdmin = (_currentUserRole ?? '').toLowerCase() == 'admin';
    final isOwner =
        _currentUserId != null &&
        announcement.authorId != null &&
        _currentUserId == announcement.authorId.toString();

    return isAdmin || isOwner;
  }

  Future<void> _showAnnouncementSheet({AnnouncementModel? announcement}) async {
    final didSave = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AnnouncementComposerSheet(
        homeService: _homeService,
        announcement: announcement,
      ),
    );

    if (didSave != true || !mounted) return;

    await _loadAnnouncements(showLoader: false);
    if (!mounted) return;

    _showSnackBar(
      announcement == null
          ? 'Announcement posted successfully.'
          : 'Announcement updated successfully.',
    );
  }

  Future<void> _handleDeleteAnnouncement(AnnouncementModel announcement) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete announcement?'),
          content: const Text(
            'This will permanently remove this announcement.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) return;

    setState(() => _mutatingAnnouncements = true);

    try {
      await _homeService.deleteAnnouncement(announcementId: announcement.id);
      if (!mounted) return;

      await _loadAnnouncements(showLoader: false);
      if (!mounted) return;

      _showSnackBar('Announcement deleted.');
    } catch (error) {
      if (!mounted) return;
      _showSnackBar(_formatErrorMessage(error), isError: true);
    } finally {
      if (mounted) {
        setState(() => _mutatingAnnouncements = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? const Color(0xFFB54747)
            : const Color(0xFF1C3B2E),
      ),
    );
  }

  String _formatErrorMessage(Object error) {
    final raw = error.toString().trim();
    if (raw.startsWith('Exception: ')) {
      return raw.replaceFirst('Exception: ', '');
    }
    return raw;
  }

  Widget _buildAnnouncementsSection() {
    if (_loadingAnnouncements) {
      return const _AnnouncementsStatusCard(
        child: SizedBox(
          height: 110,
          child: Center(
            child: CircularProgressIndicator(color: Color(0xFF2A5240)),
          ),
        ),
      );
    }

    if (_announcementsError != null && _announcements.isEmpty) {
      return _AnnouncementsStatusCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Unable to load announcements.',
              style: TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _announcementsError!,
              style: const TextStyle(
                color: Color(0xFF6F6A61),
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: _mutatingAnnouncements
                  ? null
                  : () => _loadAnnouncements(),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1C3B2E),
                side: const BorderSide(color: Color(0xFF1C3B2E)),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_announcements.isEmpty) {
      return const _AnnouncementsStatusCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No announcements yet',
              style: TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Be the first resident to share an update with the community.',
              style: TextStyle(
                color: Color(0xFF6F6A61),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (_refreshingAnnouncements)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: Color(0xFF2A5240),
              ),
            ),
          ),
        IgnorePointer(
          ignoring: _mutatingAnnouncements,
          child: AnnouncementCarousel(
            items: _announcements,
            canManage: _canManageAnnouncement,
            onEdit: (announcement) {
              _showAnnouncementSheet(announcement: announcement);
            },
            onDelete: _handleDeleteAnnouncement,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: RefreshIndicator(
        color: const Color(0xFF2A5240),
        backgroundColor: Colors.white,
        onRefresh: _refreshAnnouncements,
        child: FadeTransition(
          opacity: _fade,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              const SliverToBoxAdapter(child: _GreetingHeader()),
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: 'Announcements',
                  actionLabel: '+ Add',
                  onAction: _mutatingAnnouncements
                      ? null
                      : () => _showAnnouncementSheet(),
                ),
              ),
              SliverToBoxAdapter(child: _buildAnnouncementsSection()),
              const SliverToBoxAdapter(
                child: _SectionHeader(title: 'Your Day at a Glance'),
              ),
              SliverToBoxAdapter(
                child: GlanceCard(
                  items: [
                    const GlanceItemModel(
                      icon: Icons.event_available_rounded,
                      iconColor: Color(0xFF2A7F62),
                      label: 'Next Booking',
                      value: 'Gym - 6:00 PM',
                      tag: 'Today',
                    ),
                    if (_latestRequest != null)
                      GlanceItemModel(
                        icon: Icons.assignment_turned_in_rounded,
                        iconColor: const Color(0xFFB8974A),
                        label: 'Pending Request',
                        value:
                            '${_latestRequest!.category} - Unit ${_latestRequest!.unitNumber}',
                        tag: _latestRequest!.status == 'in_progress'
                            ? 'In Progress'
                            : 'In Review',
                      )
                    else if (!_loadingRequest)
                      const GlanceItemModel(
                        icon: Icons.assignment_turned_in_rounded,
                        iconColor: Color(0xFFB8974A),
                        label: 'Maintenance',
                        value: 'No active requests',
                        tag: 'All clear',
                      ),
                    const GlanceItemModel(
                      icon: Icons.person_pin_circle_rounded,
                      iconColor: Color(0xFF5B7FA6),
                      label: 'Next Visitor',
                      value: 'Kami benamouna. - 3:00 PM',
                      tag: 'Approved',
                    ),
                  ],
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
              const SliverToBoxAdapter(child: ConsumptionPreviewCard()),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        ),
      ),
    );
  }
}

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
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
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
                            ? '${_weather!.temperature.toStringAsFixed(0)} C - Indoor'
                            : '-- C - Indoor',
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
          if (!_loading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF152E22),
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
                              ? '${_weather!.temperature.toStringAsFixed(0)} deg'
                              : '-- deg',
                          style: const TextStyle(
                            color: Color(0xFFE8D9B5),
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          _weather?.description ?? 'Loading...',
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.actionLabel, this.onAction});

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
              child: Opacity(
                opacity: onAction == null ? 0.45 : 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
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
            ),
        ],
      ),
    );
  }
}

class _AnnouncementsStatusCard extends StatelessWidget {
  const _AnnouncementsStatusCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class _AnnouncementComposerSheet extends StatefulWidget {
  const _AnnouncementComposerSheet({
    required this.homeService,
    this.announcement,
  });

  final HomeService homeService;
  final AnnouncementModel? announcement;

  bool get isEditing => announcement != null;

  @override
  State<_AnnouncementComposerSheet> createState() =>
      _AnnouncementComposerSheetState();
}

class _AnnouncementComposerSheetState
    extends State<_AnnouncementComposerSheet> {
  late final TextEditingController _contentController;
  bool _hasInput = false;
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(
      text: widget.announcement?.content ?? '',
    )..addListener(_handleInputChanged);
    _hasInput = _canSubmit;
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  bool get _canSubmit => _contentController.text.trim().isNotEmpty;

  void _handleInputChanged() {
    final nextHasInput = _canSubmit;
    if (nextHasInput != _hasInput || _errorText != null) {
      setState(() {
        _hasInput = nextHasInput;
        _errorText = null;
      });
    }
  }

  Future<void> _submit() async {
    if (!_canSubmit || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    try {
      if (widget.isEditing) {
        await widget.homeService.updateAnnouncement(
          announcementId: widget.announcement!.id,
          content: _contentController.text.trim(),
          isPinned: widget.announcement!.isPinned,
        );
      } else {
        await widget.homeService.createAnnouncement(
          content: _contentController.text.trim(),
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorText = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
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
      child: SingleChildScrollView(
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
            Text(
              widget.isEditing ? 'Edit Announcement' : 'New Announcement',
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.isEditing
                  ? 'Update your message for all residents'
                  : 'Share something with all residents',
              style: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 13),
            ),
            const SizedBox(height: 18),
            _AnnouncementFieldShell(
              child: TextField(
                controller: _contentController,
                maxLines: 5,
                minLines: 4,
                autofocus: !widget.isEditing,
                maxLength: 5000,
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 14,
                  height: 1.5,
                ),
                decoration: const InputDecoration(
                  counterText: '',
                  hintText: 'Write your announcement here...',
                  hintStyle: TextStyle(color: Color(0xFF9A9A9A)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            if (widget.announcement?.isPinned == true) ...[
              const SizedBox(height: 10),
              const Row(
                children: [
                  Icon(
                    Icons.push_pin_rounded,
                    size: 14,
                    color: Color(0xFFB8974A),
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'This announcement is pinned. Pin status is preserved here.',
                      style: TextStyle(color: Color(0xFF8C6B20), fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
            if (_errorText != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorText!,
                style: const TextStyle(
                  color: Color(0xFFB54747),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1C3B2E),
                        side: BorderSide(
                          color: const Color(0xFF1C3B2E).withOpacity(0.35),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: _hasInput
                            ? const Color(0xFF1C3B2E)
                            : const Color(0xFF9A9A9A).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextButton(
                        onPressed: (_hasInput && !_isSubmitting)
                            ? _submit
                            : null,
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Color(0xFFE8D9B5),
                                ),
                              )
                            : Text(
                                widget.isEditing
                                    ? 'Save Changes'
                                    : 'Post Announcement',
                                style: TextStyle(
                                  color: _hasInput
                                      ? const Color(0xFFE8D9B5)
                                      : const Color(0xFF9A9A9A),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AnnouncementFieldShell extends StatelessWidget {
  const _AnnouncementFieldShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F0E8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFB8974A).withOpacity(0.30),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}
