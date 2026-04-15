import 'package:flutter/material.dart';
import 'package:resident_app/features/requests/models/parking_spot.dart';
import 'package:resident_app/features/requests/services/requests_service.dart';

class ParkingScreen extends StatefulWidget {
  const ParkingScreen({super.key});

  @override
  State<ParkingScreen> createState() => _ParkingScreenState();
}

class _ParkingScreenState extends State<ParkingScreen> {
  List<ParkingSpot> _spots = [];
  bool _isLoading = true;
  String? _error;

  // ── Radja: replace this with the real residentId from auth token ──
  static const String _myResidentId = 'mock-resident-01';

  @override
  void initState() {
    super.initState();
    _loadSpots();
  }

  Future<void> _loadSpots() async {
    try {
      final spots = await RequestsService().fetchParkingSpots();
      setState(() {
        _spots = spots;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load parking data';
        _isLoading = false;
      });
    }
  }

  // ── Split spots into resident and visitor ─────────────────────
  List<ParkingSpot> get _residentSpots =>
      _spots.where((s) => !s.isVisitorSpot).toList();

  List<ParkingSpot> get _visitorSpots =>
      _spots.where((s) => s.isVisitorSpot).toList();

  int get _availableVisitorCount =>
      _visitorSpots.where((s) => s.status == SpotStatus.available).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D4A3E),
        foregroundColor: Colors.white,
        title: const Text('Parking Lot'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadSpots();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text(_error!,
                      style: const TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── Resident parking section ───────────────
                      _SectionHeader(
                        title: 'Resident Parking',
                        icon: Icons.home_rounded,
                        color: const Color(0xFF2D4A3E),
                      ),
                      const SizedBox(height: 8),
                      _Legend(showMySpot: true),
                      const SizedBox(height: 12),
                      _ParkingGrid(
                        spots: _residentSpots,
                        myResidentId: _myResidentId,
                      ),

                      const SizedBox(height: 24),

                      // ── Visitor parking section ────────────────
                      _SectionHeader(
                        title: 'Visitor Parking',
                        icon: Icons.directions_car_rounded,
                        color: const Color(0xFF2D4A3E),
                        badge: '$_availableVisitorCount available',
                      ),
                      const SizedBox(height: 8),
                      _Legend(showMySpot: false),
                      const SizedBox(height: 12),
                      _ParkingGrid(
                        spots: _visitorSpots,
                        myResidentId: _myResidentId,
                      ),

                    ],
                  ),
                ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String? badge;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14)),
          const Spacer(),
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(badge!,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }
}

// ── Legend ────────────────────────────────────────────────────────────────────
class _Legend extends StatelessWidget {
  final bool showMySpot;

  const _Legend({required this.showMySpot});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (showMySpot) ...[
          _LegendDot(color: Colors.blue,  label: 'Your Spot'),
          const SizedBox(width: 12),
        ],
        _LegendDot(color: Colors.green, label: 'Available'),
        const SizedBox(width: 12),
        _LegendDot(color: Colors.red,   label: 'Occupied'),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}

// ── Parking grid ──────────────────────────────────────────────────────────────
class _ParkingGrid extends StatelessWidget {
  final List<ParkingSpot> spots;
  final String myResidentId;

  const _ParkingGrid({
    required this.spots,
    required this.myResidentId,
  });

  Color _colorForSpot(ParkingSpot spot, bool isMySpot) {
    if (isMySpot) return Colors.blue;
    switch (spot.status) {
      case SpotStatus.available: return Colors.green;
      case SpotStatus.occupied:  return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    // group spots by row prefix (A, B, V...)
    final Map<String, List<ParkingSpot>> rows = {};
    for (final spot in spots) {
      final row = spot.spotId.split('-').first;
      rows.putIfAbsent(row, () => []).add(spot);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Row ${entry.key}',
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.grey)),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.4,
              ),
              itemCount: entry.value.length,
              itemBuilder: (_, i) {
                final spot = entry.value[i];
                final isMySpot = spot.residentId == myResidentId;
                final color = _colorForSpot(spot, isMySpot);

                return Container(
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    border: Border.all(color: color, width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isMySpot
                            ? Icons.star_rounded
                            : Icons.directions_car,
                        color: color,
                        size: 18,
                      ),
                      const SizedBox(height: 2),
                      Text(spot.spotId,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: color,
                          )),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }
}