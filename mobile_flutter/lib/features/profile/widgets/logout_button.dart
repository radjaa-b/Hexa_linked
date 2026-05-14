import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:resident_app/l10n/app_localizations.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key, required this.onLogout});

  final VoidCallback onLogout;

  void _confirm(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A2E24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

        title: Text(
          t.logOutQuestion,
          style: const TextStyle(
            color: Color(0xFFE8E4DC),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),

        content: Text(
          t.logOutMessage,
          style: const TextStyle(color: Color(0xFF8A9E92), fontSize: 14),
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              t.cancel,
              style: const TextStyle(color: Color(0xFF6B9E80), fontSize: 14),
            ),
          ),

          TextButton(
            onPressed: () {
              HapticFeedback.mediumImpact();

              Navigator.pop(context);

              onLogout();
            },
            child: Text(
              t.logout,
              style: const TextStyle(
                color: Color(0xFFE05252),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () => _confirm(context),
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFFE05252).withOpacity(0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE05252).withOpacity(0.30),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.logout_rounded,
              color: Color(0xFFE05252),
              size: 18,
            ),

            const SizedBox(width: 8),

            Text(
              t.logout,
              style: const TextStyle(
                color: Color(0xFFE05252),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
