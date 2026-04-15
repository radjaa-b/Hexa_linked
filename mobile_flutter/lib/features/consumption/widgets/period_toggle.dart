import 'package:flutter/material.dart';

class PeriodToggle extends StatelessWidget {
  const PeriodToggle({
    super.key,
    required this.selectedPeriod,
    required this.onChanged,
  });

  final String selectedPeriod;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1C3B2E).withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _PeriodChip(
            label: 'Weekly',
            isSelected: selectedPeriod == 'weekly',
            onTap: () => onChanged('weekly'),
          ),
          _PeriodChip(
            label: 'Monthly',
            isSelected: selectedPeriod == 'monthly',
            onTap: () => onChanged('monthly'),
          ),
        ],
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1C3B2E) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected
                  ? const Color(0xFFE8D9B5)
                  : const Color(0xFF1C3B2E),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}