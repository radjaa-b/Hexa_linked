import 'package:flutter/material.dart';
import 'package:resident_app/features/consumption/models/consumption_model.dart';

class BarChartCard extends StatelessWidget {
  const BarChartCard({
    super.key,
    required this.data,
    required this.barColor,
    required this.unit,
  });

  final List<ConsumptionPoint> data;
  final Color barColor;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final maxValue = data.isEmpty
        ? 1.0
        : data.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Usage Overview',
            style: TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 220,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((point) {
                final heightFactor = point.value / maxValue;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          point.value.toStringAsFixed(0),
                          style: const TextStyle(
                            color: Color(0xFF6B6B6B),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 140 * heightFactor.clamp(0.0, 1.0),
                          decoration: BoxDecoration(
                            color: barColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          point.label,
                          style: const TextStyle(
                            color: Color(0xFF7A7A7A),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Unit: $unit',
            style: const TextStyle(
              color: Color(0xFF7A7A7A),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}