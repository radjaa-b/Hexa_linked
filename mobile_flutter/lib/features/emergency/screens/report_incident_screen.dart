import 'package:flutter/material.dart';
import 'package:resident_app/features/emergency/widgets/emergency_dialog.dart';

class ReportIncidentScreen extends StatelessWidget {
  const ReportIncidentScreen({super.key});

  Future<void> _openEmergencyDialog(BuildContext context) async {
    final sent = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const EmergencyDialog(),
    );

    if (sent == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incident reported successfully.'),
          backgroundColor: Color(0xFF1C3B2E),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        title: const Text('Report Incident'),
        backgroundColor: const Color(0xFFF5F0E8),
        foregroundColor: const Color(0xFF1C3B2E),
        elevation: 0,
      ),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () => _openEmergencyDialog(context),
          icon: const Icon(Icons.warning_amber_rounded),
          label: const Text('Open emergency report'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFC0392B),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),
      ),
    );
  }
}
