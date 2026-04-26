import 'package:flutter/material.dart';

import '../models/booking_request.dart';
import '../services/requests_service.dart';
import '../widgets/requests_design.dart';
import 'package:resident_app/features/auth/services/auth_service.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _unitController = TextEditingController();
  final _notesController = TextEditingController();
  final _guestCountController = TextEditingController(text: '1');

  String _selectedArea = 'Gym';
  String _startTime = '08:00';
  String _endTime = '09:00';
  DateTime? _bookingDate;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _areas = [
    {'name': 'Gym', 'icon': Icons.fitness_center_outlined},
    {'name': 'Pool', 'icon': Icons.pool_outlined},
    {'name': 'Rooftop', 'icon': Icons.roofing_outlined},
    {'name': 'BBQ Area', 'icon': Icons.outdoor_grill_outlined},
    {'name': 'Meeting Room', 'icon': Icons.meeting_room_outlined},
    {'name': 'Kids Room', 'icon': Icons.child_care_outlined},
  ];

  final List<String> _timeSlots = [
    '06:00',
    '07:00',
    '08:00',
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
    '18:00',
    '19:00',
    '20:00',
    '21:00',
    '22:00',
  ];

  @override
  void dispose() {
    _unitController.dispose();
    _notesController.dispose();
    _guestCountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.darkGreen,
            onPrimary: AppColors.parchment,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() => _bookingDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_bookingDate == null) {
      showErrorSnack(context, 'Please select a booking date');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final session = await AuthService.getStoredSession(
        requiredRole: 'resident',
      );

      if (session == null) {
        if (mounted) {
          showErrorSnack(context, 'Session expired. Please login again.');
        }
        return;
      }

      await RequestsService().submitBookingRequest(
        token: session.accessToken,
        request: BookingRequest(
          unitNumber: _unitController.text.trim(),
          areaName: _selectedArea,
          bookingDate: _bookingDate!,
          startTime: _startTime,
          endTime: _endTime,
          guestCount: int.tryParse(_guestCountController.text) ?? 1,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        ),
      );

      if (mounted) {
        showSuccessSnack(context, 'Booking confirmed!');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        showErrorSnack(context, e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: [
          RequestsAppBar(
            title: 'Book Shared Area',
            subtitle: 'Reserve a facility in your building',
            icon: Icons.meeting_room_outlined,
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    FormCard(
                      children: [
                        const FieldLabel('Your Unit Number'),
                        RequestTextField(
                          controller: _unitController,
                          hint: 'e.g. A-204',
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    FormCard(
                      children: [
                        const FieldLabel('Select Area'),
                        const SizedBox(height: 10),
                        GridView.count(
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.05,
                          children: _areas.map((area) {
                            final isSelected = _selectedArea == area['name'];

                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedArea = area['name']),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.darkGreen
                                      : AppColors.cream,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.gold.withOpacity(0.40)
                                        : Colors.transparent,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      area['icon'] as IconData,
                                      size: 22,
                                      color: isSelected
                                          ? AppColors.gold
                                          : AppColors.darkGreen.withOpacity(
                                              0.40,
                                            ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      area['name'],
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? AppColors.parchment
                                            : AppColors.darkGreen.withOpacity(
                                                0.55,
                                              ),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    FormCard(
                      children: [
                        const FieldLabel('Booking Date'),
                        DatePickerRow(
                          selectedDate: _bookingDate,
                          hint: 'Select date',
                          onTap: _pickDate,
                        ),
                        const SizedBox(height: 16),
                        const FieldLabel('Time Slot'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _TimeSelectColumn(
                                label: 'From',
                                value: _startTime,
                                slots: _timeSlots,
                                onChanged: (v) {
                                  if (v != null) {
                                    setState(() => _startTime = v);
                                  }
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 16,
                                left: 10,
                                right: 10,
                              ),
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                size: 18,
                                color: AppColors.darkGreen.withOpacity(0.40),
                              ),
                            ),
                            Expanded(
                              child: _TimeSelectColumn(
                                label: 'To',
                                value: _endTime,
                                slots: _timeSlots,
                                onChanged: (v) {
                                  if (v != null) {
                                    setState(() => _endTime = v);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    FormCard(
                      children: [
                        const FieldLabel('Number of Guests'),
                        RequestTextField(
                          controller: _guestCountController,
                          hint: '1',
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            final n = int.tryParse(v ?? '');
                            if (n == null || n < 1) {
                              return 'Enter a valid number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        const FieldLabel('Notes (optional)'),
                        RequestTextField(
                          controller: _notesController,
                          hint: 'Any special requirements...',
                          maxLines: 3,
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    SubmitButton(
                      label: 'Confirm Booking',
                      isLoading: _isLoading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeSelectColumn extends StatelessWidget {
  final String label;
  final String value;
  final List<String> slots;
  final void Function(String?) onChanged;

  const _TimeSelectColumn({
    required this.label,
    required this.value,
    required this.slots,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.darkGreen.withOpacity(0.45),
          ),
        ),
        const SizedBox(height: 4),
        _TimeDropdown(value: value, slots: slots, onChanged: onChanged),
      ],
    );
  }
}

class _TimeDropdown extends StatelessWidget {
  final String value;
  final List<String> slots;
  final void Function(String?) onChanged;

  const _TimeDropdown({
    required this.value,
    required this.slots,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.cream,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.darkGreen,
            fontWeight: FontWeight.w500,
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.darkGreen.withOpacity(0.50),
          ),
          items: slots
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
