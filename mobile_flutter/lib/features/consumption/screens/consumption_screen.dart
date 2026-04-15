import 'dart:async';
import 'package:flutter/material.dart';
import 'package:resident_app/features/consumption/models/consumption_model.dart';
import 'package:resident_app/features/consumption/services/consumption_service.dart';
import 'package:resident_app/features/consumption/widgets/bar_chart_card.dart';
import 'package:resident_app/features/consumption/widgets/bill_card.dart';
import 'package:resident_app/features/consumption/widgets/live_meter_card.dart';
import 'package:resident_app/features/consumption/widgets/period_toggle.dart';
import 'package:resident_app/features/consumption/widgets/summary_row.dart';

class ConsumptionScreen extends StatefulWidget {
  const ConsumptionScreen({super.key});

  @override
  State<ConsumptionScreen> createState() => _ConsumptionScreenState();
}

class _ConsumptionScreenState extends State<ConsumptionScreen>
    with SingleTickerProviderStateMixin {
  final ConsumptionService _service = ConsumptionService();

  String _selectedPeriod = 'weekly';
  int _selectedTabIndex = 0;

  ConsumptionData? _electricityData;
  ConsumptionData? _waterData;
  bool _isLoading = true;

  Timer? _liveTimer;

  late final TabController _tabController =
      TabController(length: 2, vsync: this)
        ..addListener(() {
          if (!_tabController.indexIsChanging) {
            setState(() {
              _selectedTabIndex = _tabController.index;
            });
          }
        });

  @override
  void initState() {
    super.initState();
    _loadData();
    _startLiveUpdates();
  }

  @override
  void dispose() {
    _liveTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final electricity =
        await _service.getElectricityData(period: _selectedPeriod);
    final water = await _service.getWaterData(period: _selectedPeriod);

    if (!mounted) return;

    setState(() {
      _electricityData = electricity;
      _waterData = water;
      _isLoading = false;
    });
  }

  void _startLiveUpdates() {
    _liveTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;

      setState(() {
        if (_electricityData != null) {
          _electricityData = _electricityData!.copyWith(
            liveUsage: _service.generateLiveUpdate(
              currentValue: _electricityData!.liveUsage,
              minDelta: 0.1,
              maxDelta: 0.5,
            ),
          );
        }

        if (_waterData != null) {
          _waterData = _waterData!.copyWith(
            liveUsage: _service.generateLiveUpdate(
              currentValue: _waterData!.liveUsage,
              minDelta: 1.0,
              maxDelta: 4.0,
            ),
          );
        }
      });
    });
  }

  ConsumptionData? get _currentData {
    return _selectedTabIndex == 0 ? _electricityData : _waterData;
  }

  Color get _currentAccent {
    return _selectedTabIndex == 0
        ? const Color(0xFFB8974A)
        : const Color(0xFF5B7FA6);
  }

  IconData get _currentIcon {
    return _selectedTabIndex == 0
        ? Icons.bolt_rounded
        : Icons.water_drop_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final data = _currentData;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C3B2E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFE8D9B5)),
        title: const Text(
          'Resource Consumption',
          style: TextStyle(
            color: Color(0xFFE8D9B5),
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFB8974A),
          labelColor: const Color(0xFFE8D9B5),
          unselectedLabelColor: const Color(0xFF6B9E80),
          tabs: const [
            Tab(text: 'Electricity'),
            Tab(text: 'Water'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1C3B2E),
              ),
            )
          : data == null
              ? const Center(
                  child: Text('No data available'),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  color: const Color(0xFF1C3B2E),
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    children: [
                      LiveMeterCard(
                        title: '${data.resourceName} Live Meter',
                        value: data.liveUsage,
                        unit: data.unit,
                        icon: _currentIcon,
                        accentColor: _currentAccent,
                      ),
                      const SizedBox(height: 18),
                      PeriodToggle(
                        selectedPeriod: _selectedPeriod,
                        onChanged: (value) {
                          setState(() {
                            _selectedPeriod = value;
                          });
                          _loadData();
                        },
                      ),
                      const SizedBox(height: 18),
                      Container(
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
                          children: [
                            SummaryRow(
                              label: 'Total Usage',
                              value:
                                  '${data.totalUsage.toStringAsFixed(1)} ${data.unit}',
                            ),
                            const SizedBox(height: 12),
                            SummaryRow(
                              label: 'Average Usage',
                              value:
                                  '${data.averageUsage.toStringAsFixed(1)} ${data.unit}',
                            ),
                            const SizedBox(height: 12),
                            SummaryRow(
                              label: 'Highest Usage',
                              value:
                                  '${data.highestUsage.toStringAsFixed(1)} ${data.unit}',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      BarChartCard(
                        data: data.chartData,
                        barColor: _currentAccent,
                        unit: data.unit,
                      ),
                      const SizedBox(height: 18),
                      BillCard(
                        amount: data.estimatedBill,
                        resourceName: data.resourceName,
                      ),
                    ],
                  ),
                ),
    );
  }
}