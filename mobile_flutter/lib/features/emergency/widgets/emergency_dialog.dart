import 'package:flutter/material.dart';
import 'package:resident_app/features/emergency/models/emergency_request.dart';
import 'package:resident_app/features/emergency/services/emergency_service.dart';

enum EmergencyState { idle, loading, success, error }

class EmergencyDialog extends StatefulWidget {
  const EmergencyDialog({super.key});

  @override
  State<EmergencyDialog> createState() => _EmergencyDialogState();
}

class _EmergencyDialogState extends State<EmergencyDialog> {
  EmergencyType? _selected;
  EmergencyState _state = EmergencyState.idle;
  String? _errorMessage;

  final _types = [
    (type: EmergencyType.fire,      label: 'Fire',      icon: Icons.local_fire_department, color: Colors.orange),
    (type: EmergencyType.medical,   label: 'Medical',   icon: Icons.medical_services,      color: Colors.red),
    (type: EmergencyType.intrusion, label: 'Intrusion', icon: Icons.lock_open,             color: Colors.purple),
    (type: EmergencyType.other,     label: 'Other',     icon: Icons.warning_amber,         color: Colors.grey),
  ];

  Future<void> _submit() async {
    if (_selected == null) return;

    setState(() {
      _state = EmergencyState.loading;
      _errorMessage = null;
    });

    try {
      await EmergencyService.send(
        EmergencyRequest(
          type: _selected!,
          residentId: 'mock-resident-01', // replace with real id from auth later
        ),
      );
      setState(() => _state = EmergencyState.success);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() {
        _state = EmergencyState.error;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _state == EmergencyState.loading
            ? const _LoadingView()
            : _state == EmergencyState.success
                ? const _SuccessView()
                : _IdleView(
                    types: _types,
                    selected: _selected,
                    errorMessage: _errorMessage,
                    onSelect: (t) => setState(() => _selected = t),
                    onCancel: () => Navigator.pop(context),
                    onConfirm: _submit,
                  ),
      ),
    );
  }
}

// ── Idle view ────────────────────────────────────────────────────────────────
class _IdleView extends StatelessWidget {
  final List<({EmergencyType type, String label, IconData icon, Color color})> types;
  final EmergencyType? selected;
  final String? errorMessage;
  final ValueChanged<EmergencyType> onSelect;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const _IdleView({
    required this.types,
    required this.selected,
    required this.errorMessage,
    required this.onSelect,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.warning_rounded, color: Colors.red, size: 48),
        const SizedBox(height: 8),
        const Text('Emergency Alert',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text('Select the type of emergency',
            style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 20),

        // ── Type grid ──────────────────────────────────────────
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.2,
          children: types.map((t) {
            final isSelected = selected == t.type;
            return GestureDetector(
              onTap: () => onSelect(t.type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected ? t.color.withOpacity(0.15) : Colors.grey.shade100,
                  border: Border.all(
                    color: isSelected ? t.color : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(t.icon, color: isSelected ? t.color : Colors.grey, size: 20),
                    const SizedBox(width: 6),
                    Text(t.label,
                        style: TextStyle(
                          color: isSelected ? t.color : Colors.grey.shade700,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        )),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        // ── Error message ──────────────────────────────────────
        if (errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 13),
              textAlign: TextAlign.center),
        ],

        const SizedBox(height: 24),

        // ── Buttons ────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Colors.grey),
                ),
                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: selected == null ? null : onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  disabledBackgroundColor: Colors.red.shade200,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Send Alert', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Loading view ─────────────────────────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 20),
        CircularProgressIndicator(color: Colors.red),
        SizedBox(height: 20),
        Text('Sending alert...', style: TextStyle(color: Colors.grey)),
        SizedBox(height: 20),
      ],
    );
  }
}

// ── Success view ─────────────────────────────────────────────────────────────
class _SuccessView extends StatelessWidget {
  const _SuccessView();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 20),
        Icon(Icons.check_circle_rounded, color: Colors.green, size: 64),
        SizedBox(height: 12),
        Text('Alert Sent!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('Security has been notified.',
            style: TextStyle(color: Colors.grey)),
        SizedBox(height: 20),
      ],
    );
  }
}