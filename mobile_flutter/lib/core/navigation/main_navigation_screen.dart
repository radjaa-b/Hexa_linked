import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:resident_app/core/navigation/widgets/resident_bottom_bar.dart';

import 'package:resident_app/features/home/screens/resident_home_screen.dart';
import 'package:resident_app/features/chat/screens/chat_list_screen.dart';
import 'package:resident_app/features/requests/screens/requests_hub_screen.dart';
import 'package:resident_app/features/profile/screens/profile_screen.dart';
import 'package:resident_app/features/emergency/widgets/emergency_dialog.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _pageIndex = 0;

  void _openEmergencyScreen() {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const EmergencyDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      extendBody: true,
      body: IndexedStack(
        index: _pageIndex,
        children: [
          const ResidentHomeScreen(), // 0 — Home
          const ChatListScreen(), // 1 — Chat
          const RequestsHubScreen(), // 2 — Requests
          const ProfileScreen(), // 3 — Profile
        ],
      ),
      bottomNavigationBar: ResidentBottomBar(
        currentIndex: _pageIndex,
        onTabSelected: (index) => setState(() => _pageIndex = index),
        onEmergencyTap: _openEmergencyScreen,
        items: const [
          ResidentBottomBarItem(icon: Icons.home_rounded, label: 'Home'),
          ResidentBottomBarItem(icon: Icons.chat_bubble_rounded, label: 'Chat'),
          ResidentBottomBarItem(
            icon: Icons.assignment_rounded,
            label: 'Requests',
          ),
          ResidentBottomBarItem(icon: Icons.person_rounded, label: 'Profile'),
        ],
      ),
    );
  }
}
