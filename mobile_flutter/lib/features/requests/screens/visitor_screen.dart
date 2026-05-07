import 'package:flutter/material.dart';
import '../models/visitor_request.dart';
import '../services/requests_service.dart';
import '../widgets/requests_design.dart';
import 'package:resident_app/features/auth/services/auth_service.dart';

class VisitorScreen extends StatefulWidget {
  const VisitorScreen({super.key});

  @override
  State<VisitorScreen> createState() => _VisitorScreenState();
}

class _VisitorScreenState extends State<VisitorScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _noteController = TextEditingController();

  String _purpose = 'Personal Visit';
  DateTime? _visitDate;

  TimeOfDay? _startTime;

  bool _isLoading = false;

  final List<String> _purposes = [
    'Personal Visit',
    'Delivery',
    'Contractor / Repair',
    'Caregiver',
    'Moving In/Out',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
      setState(() => _visitDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
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
      setState(() {
        _startTime = picked;
      });
    }
  }

  String _formatTime(TimeOfDay? t) {
    if (t == null) return '';
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_visitDate == null) {
      showErrorSnack(context, 'Please select a visit date');
      return;
    }

    if (_startTime == null) {
      showErrorSnack(context, 'Please select the expected time of arrival');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final session = await AuthService.getStoredSession(
        requiredRole: 'resident',
      );

      if (session == null) {
        throw Exception('User not authenticated');
      }

      await RequestsService().submitVisitorRequest(
        token: session.accessToken,
        request: VisitorRequest(
          visitorName: _nameController.text.trim(),
          visitorPhone: _phoneController.text.trim(),
          visitorEmail: _emailController.text.trim(),
          purpose: _purpose,
          visitDate: _visitDate!,
          startTime: _formatTime(_startTime),
          endTime: _formatTime(_startTime),
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
        ),
      );

      if (mounted) {
        showSuccessSnack(context, 'Visitor request sent!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        showErrorSnack(context, e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _timePickerBox({
    required String hint,
    required TimeOfDay? time,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.access_time_rounded,
              color: AppColors.mutedGreen,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              time == null ? hint : _formatTime(time),
              style: TextStyle(
                color: time == null
                    ? AppColors.mutedGreen
                    : AppColors.darkGreen,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: [
          RequestsAppBar(
            title: 'Visitor Pass',
            subtitle: 'Register an expected visitor',
            icon: Icons.badge_outlined,
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
                        const FieldLabel('Visitor Full Name'),
                        RequestTextField(
                          controller: _nameController,
                          hint: 'Ahmed Benali',
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Name is required'
                              : null,
                        ),
                        const SizedBox(height: 16),

                        const FieldLabel('Visitor Phone'),
                        RequestTextField(
                          controller: _phoneController,
                          hint: '+213 555 123 456',
                          keyboardType: TextInputType.phone,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Phone is required'
                              : null,
                        ),
                        const SizedBox(height: 16),

                        const FieldLabel('Visitor Email'),
                        RequestTextField(
                          controller: _emailController,
                          hint: 'visitor@email.com',
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Email is required';
                            }
                            if (!v.contains('@')) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    FormCard(
                      children: [
                        const FieldLabel('Purpose'),
                        RequestDropdown(
                          value: _purpose,
                          items: _purposes,
                          onChanged: (v) => setState(() => _purpose = v!),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    FormCard(
                      children: [
                        const FieldLabel('Visit Date'),
                        DatePickerRow(
                          selectedDate: _visitDate,
                          hint: 'Select date',
                          onTap: _pickDate,
                        ),
                        if (_visitDate != null) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Selected: ${_formatDate(_visitDate)}',
                              style: const TextStyle(
                                color: AppColors.mutedGreen,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),

                        const FieldLabel('Expected Time of Arrival'),
                        _timePickerBox(
                          hint: 'Select expected arrival time',
                          time: _startTime,
                          onTap: _pickTime,
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    FormCard(
                      children: [
                        const FieldLabel('Note (optional)'),
                        RequestTextField(
                          controller: _noteController,
                          hint: 'Optional note',
                          validator: (_) => null,
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    SubmitButton(
                      label: 'Register Visitor',
                      isLoading: _isLoading,
                      onPressed: _submit,
                    ),
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
