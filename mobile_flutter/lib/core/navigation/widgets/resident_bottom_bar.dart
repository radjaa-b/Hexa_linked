import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

// ─────────────────────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────────────────────
class _C {
  static const barBg    = Color(0xFF1C3B2E);
  static const active   = Color(0xFFE8D9B5);
  static const inactive = Color(0xFF6B9E80);
  static const pillBg   = Color(0x28E8D9B5);
  static const gold     = Color(0xFFB8974A);
  static const sos      = Color(0xFFC0392B);
  static const sosGlow  = Color(0x55C0392B);
  static const pageBg   = Color(0xFFF5F0E8);
}

// ─────────────────────────────────────────────────────────────
//  DATA MODEL
// ─────────────────────────────────────────────────────────────
class ResidentBottomBarItem {
  final IconData icon;
  final String label;
  const ResidentBottomBarItem({required this.icon, required this.label});
}

// ─────────────────────────────────────────────────────────────
//  FLOATING BUBBLE NAV BAR
//
//  Expects exactly 4 items:
//    index 0 — Home      (left)
//    index 1 — Chat      (left)
//    index 2 — Requests  (right)   ← was index 3 in the old 5-tab layout
//    index 3 — Profile   (right)
//
//  The SOS FAB sits in the centre gap and is NOT a tab index.
// ─────────────────────────────────────────────────────────────
class ResidentBottomBar extends StatelessWidget {
  const ResidentBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onEmergencyTap,
    this.items = const [],
  });

  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onEmergencyTap;
  final List<ResidentBottomBarItem> items;

  static const double _barHeight   = 68;
  static const double _fabDiameter = 56;
  static const double _hPad        = 20;
  static const double _bPad        = 20;
  static const double _fabRaise    = 20;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    // ── Split: first 2 go left, last 2 go right ──────────────
    final leftItems  = items.sublist(0, math.min(2, items.length));
    final rightItems = items.length > 2 ? items.sublist(2) : <ResidentBottomBarItem>[];

    final totalHeight = _barHeight + _fabRaise + _bPad + bottomPad;

    return SizedBox(
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [

          // ── Floating pill ────────────────────────────────────
          Positioned(
            left:   _hPad,
            right:  _hPad,
            bottom: _bPad + bottomPad,
            child: SizedBox(
              height: _barHeight,
              child: CustomPaint(
                painter: _BubbleBarPainter(
                  color:     _C.barBg,
                  goldColor: _C.gold,
                  radius:    _barHeight / 2,
                ),
                child: Row(
                  children: [
                    // Left tabs — Home (0), Chat (1)
                    ...List.generate(leftItems.length, (i) => _TabItem(
                      icon:     leftItems[i].icon,
                      label:    leftItems[i].label,
                      isActive: i == currentIndex,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onTabSelected(i);
                      },
                    )),

                    // Centre gap for FAB
                    SizedBox(width: _fabDiameter + 28),

                    // Right tabs — Requests (2), Profile (3)
                    ...List.generate(rightItems.length, (i) => _TabItem(
                      icon:     rightItems[i].icon,
                      label:    rightItems[i].label,
                      isActive: (i + 2) == currentIndex,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onTabSelected(i + 2);
                      },
                    )),
                  ],
                ),
              ),
            ),
          ),

          // ── Emergency FAB (centre, raised) ───────────────────
          Positioned(
            bottom: _bPad + bottomPad + _barHeight / 2 - _fabDiameter / 2 + _fabRaise * 0.5,
            child: _EmergencyFab(
              diameter: _fabDiameter,
              onTap:    onEmergencyTap,
            ),
          ),

        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  TAB ITEM  (unchanged)
// ─────────────────────────────────────────────────────────────
class _TabItem extends StatefulWidget {
  const _TabItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });
  final IconData     icon;
  final String       label;
  final bool         isActive;
  final VoidCallback onTap;

  @override
  State<_TabItem> createState() => _TabItemState();
}

class _TabItemState extends State<_TabItem>
    with SingleTickerProviderStateMixin {

  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  late final Animation<double> _spring = CurvedAnimation(
    parent: _ctrl, curve: Curves.easeOutBack,
  );

  @override
  void initState() {
    super.initState();
    if (widget.isActive) _ctrl.value = 1.0;
  }

  @override
  void didUpdateWidget(_TabItem old) {
    super.didUpdateWidget(old);
    widget.isActive ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: Tween(begin: 1.0, end: 1.2).animate(_spring),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.isActive ? _C.pillBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  widget.icon,
                  size: 21,
                  color: widget.isActive ? _C.active : _C.inactive,
                ),
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize:      widget.isActive ? 10.0 : 9.0,
                fontWeight:    widget.isActive ? FontWeight.w600 : FontWeight.w400,
                color:         widget.isActive ? _C.active : _C.inactive,
                letterSpacing: 0.3,
              ),
              child: Text(widget.label, maxLines: 1),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  EMERGENCY FAB  (unchanged)
// ─────────────────────────────────────────────────────────────
class _EmergencyFab extends StatefulWidget {
  const _EmergencyFab({required this.diameter, required this.onTap});
  final double       diameter;
  final VoidCallback onTap;

  @override
  State<_EmergencyFab> createState() => _EmergencyFabState();
}

class _EmergencyFabState extends State<_EmergencyFab>
    with SingleTickerProviderStateMixin {

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat(reverse: true);

  @override
  void dispose() { _pulse.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (_, child) => Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width:  widget.diameter + 12 + _pulse.value * 10,
              height: widget.diameter + 12 + _pulse.value * 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _C.sosGlow
                    .withOpacity(0.20 * (1 - _pulse.value * 0.5)),
              ),
            ),
            Container(
              width:  widget.diameter + 5,
              height: widget.diameter + 5,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: _C.pageBg,
              ),
            ),
            child!,
          ],
        ),
        child: Container(
          width:  widget.diameter,
          height: widget.diameter,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _C.sos,
            boxShadow: [
              BoxShadow(
                color:        _C.sos.withOpacity(0.45),
                blurRadius:   18,
                spreadRadius: 1,
                offset:       const Offset(0, 5),
              ),
            ],
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 22),
              SizedBox(height: 1),
              Text(
                'SOS',
                style: TextStyle(
                  color:         Colors.white,
                  fontSize:      8.0,
                  fontWeight:    FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  CUSTOM PAINTER  (unchanged)
// ─────────────────────────────────────────────────────────────
class _BubbleBarPainter extends CustomPainter {
  const _BubbleBarPainter({
    required this.color,
    required this.goldColor,
    required this.radius,
  });

  final Color  color;
  final Color  goldColor;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect  = Rect.fromLTWH(0, 0, size.width, size.height);
    final rRect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.translate(0, 8), Radius.circular(radius)),
      Paint()
        ..color      = Colors.black.withOpacity(0.16)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.translate(0, 14), Radius.circular(radius)),
      Paint()
        ..color      = const Color(0xFF1C3B2E).withOpacity(0.10)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 32),
    );

    canvas.drawRRect(rRect, Paint()..color = color);

    canvas.drawRRect(
      rRect,
      Paint()
        ..style       = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..shader      = LinearGradient(
          begin:  Alignment.topLeft,
          end:    Alignment.bottomRight,
          colors: [
            goldColor.withOpacity(0.10),
            goldColor.withOpacity(0.55),
            goldColor.withOpacity(0.85),
            goldColor.withOpacity(0.55),
            goldColor.withOpacity(0.10),
          ],
          stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_BubbleBarPainter old) =>
      old.color     != color     ||
      old.goldColor != goldColor ||
      old.radius    != radius;
}