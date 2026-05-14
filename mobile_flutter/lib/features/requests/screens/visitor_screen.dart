import 'package:flutter/material.dart';
import '../models/visitor_request.dart';
import '../services/requests_service.dart';
import '../widgets/requests_design.dart';
import 'package:resident_app/features/auth/services/auth_service.dart';
import 'package:resident_app/l10n/app_localizations.dart';

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

  String _purposeLabel(AppLocalizations t, String purpose) {
    switch (purpose) {
      case 'Personal Visit':
        return t.personalVisit;
      case 'Delivery':
        return t.delivery;
      case 'Contractor / Repair':
        return t.contractorRepair;
      case 'Caregiver':
        return t.caregiver;
      case 'Moving In/Out':
        return t.movingInOut;
      case 'Other':
        return t.other;
      default:
        return purpose;
    }
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
    final t = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) return;

    if (_visitDate == null) {
      showErrorSnack(context, t.selectVisitDate);
      return;
    }

    if (_startTime == null) {
      showErrorSnack(context, t.selectExpectedArrivalTime);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final session = await AuthService.getStoredSession(
        requiredRole: 'resident',
      );

      if (session == null) {
        throw Exception(t.userNotAuthenticated);
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
        showSuccessSnack(context, t.visitorRequestSent);
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
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: [
          RequestsAppBar(
            title: t.visitorPass,
            subtitle: t.registerExpectedVisitor,
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
                        FieldLabel(t.visitorFullName),
                        RequestTextField(
                          controller: _nameController,
                          hint: 'Ahmed Benali',
                          validator: (v) => v == null || v.trim().isEmpty
                              ? t.nameRequired
                              : null,
                        ),
                        const SizedBox(height: 16),

                        FieldLabel(t.visitorPhone),
                        RequestTextField(
                          controller: _phoneController,
                          hint: '+213 555 123 456',
                          keyboardType: TextInputType.phone,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? t.phoneRequired
                              : null,
                        ),
                        const SizedBox(height: 16),

                        FieldLabel(t.visitorEmail),
                        RequestTextField(
                          controller: _emailController,
                          hint: 'visitor@email.com',
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return t.emailRequired;
                            }
                            if (!v.contains('@')) {
                              return t.validEmailRequired;
                            }
                            return null;
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    FormCard(
                      children: [
                        FieldLabel(t.purpose),
                        RequestDropdown(
                          value: _purposeLabel(t, _purpose),
                          items: _purposes
                              .map((p) => _purposeLabel(t, p))
                              .toList(),
                          onChanged: (v) {
                            if (v == null) return;

                            final original = _purposes.firstWhere(
                              (p) => _purposeLabel(t, p) == v,
                              orElse: () => 'Personal Visit',
                            );

                            setState(() => _purpose = original);
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    FormCard(
                      children: [
                        FieldLabel(t.visitDate),
                        DatePickerRow(
                          selectedDate: _visitDate,
                          hint: t.selectDate,
                          onTap: _pickDate,
                        ),
                        if (_visitDate != null) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${t.selected}: ${_formatDate(_visitDate)}',
                              style: const TextStyle(
                                color: AppColors.mutedGreen,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),

                        FieldLabel(t.expectedTimeOfArrival),
                        _timePickerBox(
                          hint: t.selectExpectedArrivalTime,
                          time: _startTime,
                          onTap: _pickTime,
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    FormCard(
                      children: [
                        FieldLabel(t.noteOptional),
                        RequestTextField(
                          controller: _noteController,
                          hint: t.optionalNote,
                          validator: (_) => null,
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    SubmitButton(
                      label: t.registerVisitor,
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
