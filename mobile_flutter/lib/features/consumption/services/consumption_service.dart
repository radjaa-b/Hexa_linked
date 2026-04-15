import 'dart:math';
import 'package:resident_app/features/consumption/models/consumption_model.dart';

class ConsumptionService {
  final Random _random = Random();

  // ---------------------------------------------------------------------------
  // Returns simulated electricity data.
  // period can be "weekly" or "monthly"
  //
  // Later:
  // Replace this logic with a backend call like:
  // GET /consumption/electricity?period=weekly
  // ---------------------------------------------------------------------------
  Future<ConsumptionData> getElectricityData({
    required String period,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final chartData = _generateChartData(
      period: period,
      min: 8,
      max: 24,
      weeklyLabels: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      monthlyLabels: const ['W1', 'W2', 'W3', 'W4'],
    );

    final total = chartData.fold<double>(0, (sum, item) => sum + item.value);
    final average = total / chartData.length;
    final highest = chartData
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b);

    return ConsumptionData(
      resourceName: 'Electricity',
      unit: 'kWh',
      liveUsage: 1.8 + _random.nextDouble() * 2.5,
      totalUsage: total,
      averageUsage: average,
      highestUsage: highest,
      estimatedBill: total * 8.5,
      chartData: chartData,
    );
  }

  // ---------------------------------------------------------------------------
  // Returns simulated water data.
  //
  // Later:
  // Replace this with backend call like:
  // GET /consumption/water?period=weekly
  // ---------------------------------------------------------------------------
  Future<ConsumptionData> getWaterData({
    required String period,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final chartData = _generateChartData(
      period: period,
      min: 120,
      max: 420,
      weeklyLabels: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      monthlyLabels: const ['W1', 'W2', 'W3', 'W4'],
    );

    final total = chartData.fold<double>(0, (sum, item) => sum + item.value);
    final average = total / chartData.length;
    final highest = chartData
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b);

    return ConsumptionData(
      resourceName: 'Water',
      unit: 'L',
      liveUsage: 18 + _random.nextDouble() * 25,
      totalUsage: total,
      averageUsage: average,
      highestUsage: highest,
      estimatedBill: total * 0.06,
      chartData: chartData,
    );
  }

  // ---------------------------------------------------------------------------
  // Simulates a changing live meter value.
  // Later this can come from a websocket, backend polling, or IoT reading.
  // ---------------------------------------------------------------------------
  double generateLiveUpdate({
    required double currentValue,
    required double minDelta,
    required double maxDelta,
  }) {
    final delta = minDelta + _random.nextDouble() * (maxDelta - minDelta);
    return currentValue + delta;
  }

  List<ConsumptionPoint> _generateChartData({
    required String period,
    required int min,
    required int max,
    required List<String> weeklyLabels,
    required List<String> monthlyLabels,
  }) {
    final labels = period == 'weekly' ? weeklyLabels : monthlyLabels;

    return labels.map((label) {
      return ConsumptionPoint(
        label: label,
        value: (min + _random.nextInt(max - min + 1)).toDouble(),
      );
    }).toList();
  }
}