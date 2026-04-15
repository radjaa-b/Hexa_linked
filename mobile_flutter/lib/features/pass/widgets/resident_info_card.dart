import 'package:flutter/material.dart';
import 'package:resident_app/features/pass/models/pass_model.dart';

class ResidentInfoCard extends StatelessWidget {
  const ResidentInfoCard({
    super.key,
    required this.pass,
  });

  // ---------------------------------------------------------------------------
  // pass
  // Full resident pass object used to display the resident information.
  //
  // Why pass instead of separate strings?
  // - keeps the widget easier to reuse
  // - if backend fields change later, the screen stays cleaner
  // ---------------------------------------------------------------------------
  final ResidentPass pass;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE8D9B5).withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFB8974A).withOpacity(0.20),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _InfoRow(
            label: 'Resident',
            value: pass.residentName,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Apartment',
            value: pass.apartment,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Resident ID',
            value: pass.residentId,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Status',
            value: pass.isActive ? 'Active' : 'Inactive',
            valueColor: pass.isActive ? const Color(0xFF6B9E80) : Colors.redAccent,
          ),
          if (pass.expiresAt != null) ...[
            const SizedBox(height: 12),
            _InfoRow(
              label: 'Valid Until',
              value: _formatDateTime(pass.expiresAt!),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helper for formatting date/time
  // Later, if your app already has a shared date formatter utility,
  // move this logic there and reuse it across screens.
  // ---------------------------------------------------------------------------
  static String _formatDateTime(DateTime dateTime) {
    final int hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final String minute = dateTime.minute.toString().padLeft(2, '0');
    final String amPm = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '${dateTime.day}/${dateTime.month}/${dateTime.year} - $hour:$minute $amPm';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor = const Color(0xFFE8D9B5),
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label:',
          style: const TextStyle(
            color: Color(0xFF6B9E80),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: valueColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}