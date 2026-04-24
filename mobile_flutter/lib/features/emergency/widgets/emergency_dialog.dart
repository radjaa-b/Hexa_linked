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

  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  final _types = [
    (
      type: EmergencyType.fire,
      label: 'Fire',
      icon: Icons.local_fire_department,
      color: Colors.orange,
    ),
    (
      type: EmergencyType.medical,
      label: 'Medical',
      icon: Icons.medical_services,
      color: Colors.red,
    ),
    (
      type: EmergencyType.security,
      label: 'Security',
      icon: Icons.security,
      color: Colors.purple,
    ),
    (
      type: EmergencyType.noise,
      label: 'Noise',
      icon: Icons.volume_up_rounded,
      color: Colors.blueGrey,
    ),
    (
      type: EmergencyType.other,
      label: 'Other',
      icon: Icons.warning_amber,
      color: Colors.grey,
    ),
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

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
          description: _descriptionController.text.trim(),
          location: _locationController.text.trim(),
        ),
      );

      if (!mounted) return;
      setState(() => _state = EmergencyState.success);

      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _state = EmergencyState.error;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: _state == EmergencyState.loading
            ? const _LoadingView()
            : _state == EmergencyState.success
            ? const _SuccessView()
            : SingleChildScrollView(
                child: _IdleView(
                  types: _types,
                  selected: _selected,
                  errorMessage: _errorMessage,
                  descriptionController: _descriptionController,
                  locationController: _locationController,
                  onSelect: (type) => setState(() => _selected = type),
                  onCancel: () => Navigator.pop(context, false),
                  onConfirm: _submit,
                ),
              ),
      ),
    );
  }
}

class _IdleView extends StatelessWidget {
  const _IdleView({
    required this.types,
    required this.selected,
    required this.errorMessage,
    required this.descriptionController,
    required this.locationController,
    required this.onSelect,
    required this.onCancel,
    required this.onConfirm,
  });

  final List<({EmergencyType type, String label, IconData icon, Color color})>
  types;
  final EmergencyType? selected;
  final String? errorMessage;
  final TextEditingController descriptionController;
  final TextEditingController locationController;
  final ValueChanged<EmergencyType> onSelect;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.warning_rounded, color: Color(0xFFC0392B), size: 48),
        const SizedBox(height: 8),
        const Text(
          'Emergency Alert',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'Select the incident type',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 18),

        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.2,
          children: types.map((item) {
            final isSelected = selected == item.type;

            return GestureDetector(
              onTap: () => onSelect(item.type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: isSelected
                      ? item.color.withOpacity(0.15)
                      : Colors.grey.shade100,
                  border: Border.all(
                    color: isSelected ? item.color : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item.icon,
                      color: isSelected ? item.color : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: isSelected ? item.color : Colors.grey.shade700,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 16),

        TextField(
          controller: locationController,
          decoration: InputDecoration(
            labelText: 'Location optional',
            hintText: 'Example: Block A, parking, gate...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),

        const SizedBox(height: 12),

        TextField(
          controller: descriptionController,
          minLines: 2,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: 'Description optional',
            hintText: 'Add details if needed...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),

        if (errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],

        const SizedBox(height: 22),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onCancel,
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: selected == null ? null : onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC0392B),
                  disabledBackgroundColor: Colors.red.shade200,
                ),
                child: const Text(
                  'Send Alert',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 20),
        CircularProgressIndicator(color: Color(0xFFC0392B)),
        SizedBox(height: 20),
        Text('Sending alert...', style: TextStyle(color: Colors.grey)),
        SizedBox(height: 20),
      ],
    );
  }
}

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
        Text(
          'Alert Sent!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'Security has been notified.',
          style: TextStyle(color: Colors.grey),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
