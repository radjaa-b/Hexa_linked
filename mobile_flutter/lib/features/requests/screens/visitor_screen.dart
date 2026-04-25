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
  TimeOfDay? _endTime;

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
    );
    if (picked != null) setState(() => _visitDate = picked);
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  String _formatTime(TimeOfDay? t) {
    if (t == null) return '';
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_visitDate == null || _startTime == null || _endTime == null) {
      showErrorSnack(context, 'Please select date and time');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final session = await AuthService.getStoredSession(
        requiredRole: 'resident',
      );
      if (session == null) throw Exception('User not authenticated');

      await RequestsService().submitVisitorRequest(
        token: session.accessToken,
        request: VisitorRequest(
          visitorName: _nameController.text.trim(),
          visitorPhone: _phoneController.text.trim(),
          visitorEmail: _emailController.text.trim(),
          purpose: _purpose,
          visitDate: _visitDate!,
          startTime: _formatTime(_startTime),
          endTime: _formatTime(_endTime),
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
      if (mounted) showErrorSnack(context, e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),

                        const FieldLabel('Visitor Phone'),
                        RequestTextField(
                          controller: _phoneController,
                          hint: 'e.g. +213 555 123 456',
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
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Email is required'
                              : null,
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
                        const SizedBox(height: 16),

                        const FieldLabel('Start Time'),
                        DatePickerRow(
                          selectedDate: _startTime == null
                              ? null
                              : DateTime(
                                  0,
                                  0,
                                  0,
                                  _startTime!.hour,
                                  _startTime!.minute,
                                ),
                          hint: 'Select start time',
                          onTap: () => _pickTime(isStart: true),
                        ),
                        const SizedBox(height: 16),

                        const FieldLabel('End Time'),
                        DatePickerRow(
                          selectedDate: _endTime == null
                              ? null
                              : DateTime(
                                  0,
                                  0,
                                  0,
                                  _endTime!.hour,
                                  _endTime!.minute,
                                ),
                          hint: 'Select end time',
                          onTap: () => _pickTime(isStart: false),
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
