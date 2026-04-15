class ConsumptionPoint {
  // Label shown in the chart.
  // Example: Mon, Tue, Wed... or Week 1, Week 2...
  final String label;

  // Numeric usage value for that point.
  final double value;

  const ConsumptionPoint({
    required this.label,
    required this.value,
  });
}

class ConsumptionData {
  // Type of resource shown on screen.
  // Example: "Electricity" or "Water"
  final String resourceName;

  // Unit displayed in the UI.
  // Example: "kWh" for electricity, "L" for water
  final String unit;

  // Current simulated live usage.
  final double liveUsage;

  // Total usage for the selected period.
  final double totalUsage;

  // Average usage for the selected period.
  final double averageUsage;

  // Highest recorded usage in the selected period.
  final double highestUsage;

  // Estimated bill for the selected period.
  final double estimatedBill;

  // Points used to build the chart.
  final List<ConsumptionPoint> chartData;

  const ConsumptionData({
    required this.resourceName,
    required this.unit,
    required this.liveUsage,
    required this.totalUsage,
    required this.averageUsage,
    required this.highestUsage,
    required this.estimatedBill,
    required this.chartData,
  });

  ConsumptionData copyWith({
    String? resourceName,
    String? unit,
    double? liveUsage,
    double? totalUsage,
    double? averageUsage,
    double? highestUsage,
    double? estimatedBill,
    List<ConsumptionPoint>? chartData,
  }) {
    return ConsumptionData(
      resourceName: resourceName ?? this.resourceName,
      unit: unit ?? this.unit,
      liveUsage: liveUsage ?? this.liveUsage,
      totalUsage: totalUsage ?? this.totalUsage,
      averageUsage: averageUsage ?? this.averageUsage,
      highestUsage: highestUsage ?? this.highestUsage,
      estimatedBill: estimatedBill ?? this.estimatedBill,
      chartData: chartData ?? this.chartData,
    );
  }

  // ---------------------------------------------------------------------------
  // Later, when backend is ready, this model can be built from API JSON.
  // Keep field names aligned with your backend response if possible.
  // ---------------------------------------------------------------------------
  factory ConsumptionData.fromJson(Map<String, dynamic> json) {
    return ConsumptionData(
      resourceName: json['resource_name'] ?? '',
      unit: json['unit'] ?? '',
      liveUsage: (json['live_usage'] ?? 0).toDouble(),
      totalUsage: (json['total_usage'] ?? 0).toDouble(),
      averageUsage: (json['average_usage'] ?? 0).toDouble(),
      highestUsage: (json['highest_usage'] ?? 0).toDouble(),
      estimatedBill: (json['estimated_bill'] ?? 0).toDouble(),
      chartData: (json['chart_data'] as List<dynamic>? ?? [])
          .map(
            (item) => ConsumptionPoint(
              label: item['label'] ?? '',
              value: (item['value'] ?? 0).toDouble(),
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resource_name': resourceName,
      'unit': unit,
      'live_usage': liveUsage,
      'total_usage': totalUsage,
      'average_usage': averageUsage,
      'highest_usage': highestUsage,
      'estimated_bill': estimatedBill,
      'chart_data': chartData
          .map((point) => {'label': point.label, 'value': point.value})
          .toList(),
    };
  }
}