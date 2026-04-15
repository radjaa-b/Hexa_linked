import 'package:flutter/material.dart';

class BillCard extends StatelessWidget {
  const BillCard({
    super.key,
    required this.amount,
    required this.resourceName,
  });

  final double amount;
  final String resourceName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1C3B2E),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$resourceName Estimated Bill',
            style: const TextStyle(
              color: Color(0xFF6B9E80),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${amount.toStringAsFixed(2)} DZD',
            style: const TextStyle(
              color: Color(0xFFE8D9B5),
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Simulation only. Later this will come from backend or meter data.',
            style: TextStyle(
              color: Color(0xFFE8D9B5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}