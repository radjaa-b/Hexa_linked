// ─────────────────────────────────────────────────────────────
//  PROFILE SCREEN — Modern dark card style
//  Location: lib/features/profile/screens/
//  TODO (Radja): replace mock profile with GET /auth/me
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:resident_app/features/auth/services/auth_service.dart';
import 'package:resident_app/features/profile/models/resident_profile.dart';
import 'package:resident_app/features/profile/widgets/profile_header.dart';
import 'package:resident_app/features/profile/widgets/profile_info_tile.dart';
import 'package:resident_app/features/profile/widgets/logout_button.dart';
import 'package:resident_app/features/auth/screens/welcome_screen.dart';

// ── Design tokens ─────────────────────────────────────────────
class _C {
  static const bg        = Color(0xFF0F1F18); // very dark green bg
  static const card      = Color(0xFF1A2E24); // dark card surface
  static const cardLight = Color(0xFF213528); // slightly lighter card
  static const forest    = Color(0xFF1C3B2E);
  static const champagne = Color(0xFFE8D9B5);
  static const gold      = Color(0xFFB8974A);
  static const sage      = Color(0xFF6B9E80);
  static const textPrim  = Color(0xFFE8E4DC);
  static const textSec   = Color(0xFF8A9E92);
  static const divider   = Color(0xFF2A3D32);
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  // TODO (Radja): replace with real user from GET /auth/me
  final _profile = const ResidentProfile(
    id: 1,
    name: 'Selsa',
    email: 'selsa@residence.com',
    username: 'selsa',
    role: 'resident',
    isActive: true,
    unit: 'Unit 3A',
    phone: '+213 555 123 456',
  );

  bool _notificationsOn = true;
  String _language = 'English';
  bool _rulesExpanded = false;
  bool _termsExpanded = false;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.easeOut,
    );
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    await AuthService.clearToken();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ─────────────────────────────────────
              ProfileHeader(profile: _profile),

              // ── Personal info ───────────────────────────────
              _label('Personal Information'),
              _darkCard(
                child: Column(
                  children: [
                    ProfileInfoTile(
                      icon: Icons.person_outline_rounded,
                      label: 'FULL NAME',
                      value: _profile.name,
                    ),
                    _divider(),
                    ProfileInfoTile(
                      icon: Icons.home_outlined,
                      label: 'UNIT',
                      value: _profile.unit ?? 'Not assigned',
                    ),
                    _divider(),
                    ProfileInfoTile(
                      icon: Icons.email_outlined,
                      label: 'EMAIL',
                      value: _profile.email,
                    ),
                    _divider(),
                    ProfileInfoTile(
                      icon: Icons.phone_outlined,
                      label: 'PHONE',
                      value: _profile.phone ?? 'Not provided',
                      isLast: true,
                    ),
                  ],
                ),
              ),

              // ── Settings ────────────────────────────────────
              _label('Settings'),
              _darkCard(
                child: Column(
                  children: [
                    _settingRow(
                      icon: Icons.notifications_outlined,
                      label: 'Push notifications',
                      trailing: Switch(
                        value: _notificationsOn,
                        onChanged: (v) => setState(() => _notificationsOn = v),
                        activeColor: _C.gold,
                        activeTrackColor: _C.gold.withOpacity(0.25),
                        inactiveThumbColor: _C.textSec,
                        inactiveTrackColor: _C.divider,
                      ),
                    ),
                    _divider(),
                    _settingRow(
                      icon: Icons.language_rounded,
                      label: 'Language',
                      trailing: GestureDetector(
                        onTap: _showLanguagePicker,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _language,
                              style: const TextStyle(
                                color: _C.textSec,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: _C.textSec,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Residence Rules ─────────────────────────────
              _label('Legal'),
              _expandableCard(
                icon: Icons.gavel_rounded,
                title: 'Residence Rules',
                expanded: _rulesExpanded,
                onTap: () => setState(() => _rulesExpanded = !_rulesExpanded),
                content: _rulesText,
              ),
              const SizedBox(height: 10),
              _expandableCard(
                icon: Icons.privacy_tip_outlined,
                title: 'Terms & Privacy',
                expanded: _termsExpanded,
                onTap: () => setState(() => _termsExpanded = !_termsExpanded),
                content: _termsText,
              ),

              // ── Logout ──────────────────────────────────────
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: LogoutButton(onLogout: _handleLogout),
              ),

              // Version
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    'Residence App v1.0.0',
                    style: TextStyle(
                      color: Color(0xFF3A5244),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Section label ────────────────────────────────────────────
  Widget _label(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
            color: _C.textSec,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.4,
          ),
        ),
      );

  // ── Dark card ────────────────────────────────────────────────
  Widget _darkCard({required Widget child}) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          decoration: BoxDecoration(
            color: _C.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _C.divider, width: 1),
          ),
          child: child,
        ),
      );

  // ── Divider ──────────────────────────────────────────────────
  Widget _divider() => const Divider(
        height: 1,
        thickness: 1,
        color: _C.divider,
      );

  // ── Setting row ──────────────────────────────────────────────
  Widget _settingRow({
    required IconData icon,
    required String label,
    required Widget trailing,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _C.gold.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: _C.gold, size: 17),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: _C.textPrim,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            trailing,
          ],
        ),
      );

  // ── Expandable card ──────────────────────────────────────────
  Widget _expandableCard({
    required IconData icon,
    required String title,
    required bool expanded,
    required VoidCallback onTap,
    required String content,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          decoration: BoxDecoration(
            color: _C.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _C.divider, width: 1),
          ),
          child: Column(
            children: [
              GestureDetector(
                onTap: onTap,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _C.gold.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, color: _C.gold, size: 17),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: _C.textPrim,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 250),
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: _C.textSec,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox(width: double.infinity),
                secondChild: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(height: 1, color: _C.divider),
                      const SizedBox(height: 14),
                      Text(
                        content,
                        style: const TextStyle(
                          color: _C.textSec,
                          fontSize: 13,
                          height: 1.7,
                        ),
                      ),
                    ],
                  ),
                ),
                crossFadeState: expanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 250),
              ),
            ],
          ),
        ),
      );

  // ── Language picker ──────────────────────────────────────────
  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _C.divider),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Language',
              style: TextStyle(
                color: _C.textPrim,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            ...['English', 'Français', 'العربية'].map((lang) {
              final selected = _language == lang;
              return GestureDetector(
                onTap: () {
                  setState(() => _language = lang);
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: selected ? _C.gold.withOpacity(0.12) : _C.cardLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected
                          ? _C.gold.withOpacity(0.40)
                          : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          lang,
                          style: TextStyle(
                            color: selected ? _C.gold : _C.textPrim,
                            fontSize: 15,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (selected)
                        const Icon(
                          Icons.check_rounded,
                          color: _C.gold,
                          size: 18,
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ── Texts ────────────────────────────────────────────────────
  static const String _rulesText = '''1. Quiet Hours
Residents must maintain quiet between 10:00 PM and 8:00 AM. Loud music, parties, or disruptive noise during these hours is strictly prohibited.

2. Common Areas
All shared spaces (gym, pool, rooftop, lobby) must be kept clean. Residents are responsible for cleaning up after themselves.

3. Visitors
Visitors must be registered in the app before arrival. Each resident may have a maximum of 3 visitors at a time in common areas.

4. Parking
Each unit is assigned one parking space. Unauthorized parking in other spaces will result in the vehicle being towed at the owner's expense.

5. Pets
Pets are allowed in private units only. Pets are not permitted in common areas unless they are service animals.

6. Waste Management
Residents must sort waste according to the building's recycling policy. Bulk waste must be scheduled through management.

7. Maintenance
All maintenance requests must be submitted through the app. Residents must not attempt to repair common area equipment themselves.''';

  static const String _termsText = '''1. Acceptance of Terms
By using this application, you agree to be bound by these terms. If you do not agree, please discontinue use of the app immediately.

2. User Accounts
You are responsible for maintaining the confidentiality of your account credentials. You must notify management immediately of any unauthorized use of your account.

3. Data Collection
We collect personal information including your name, unit number, email, and phone number for the purpose of managing your residency and providing app services.

4. Data Usage
Your data will never be sold to third parties. It is used solely for residence management purposes including bookings, maintenance requests, and visitor management.

5. Privacy
All personal data is stored securely and processed in accordance with applicable data protection laws.

6. Limitation of Liability
The app is provided as a convenience tool. Management is not liable for technical issues that may temporarily affect access to services.

7. Changes to Terms
Management reserves the right to update these terms at any time. Continued use of the app constitutes acceptance of any revised terms.''';
}
