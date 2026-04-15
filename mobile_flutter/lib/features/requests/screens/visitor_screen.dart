import 'package:flutter/material.dart';
import '../models/visitor_request.dart';
import '../services/requests_service.dart';
import '../widgets/requests_design.dart';

class VisitorScreen extends StatefulWidget {
  const VisitorScreen({super.key});

  @override
  State<VisitorScreen> createState() => _VisitorScreenState();
}

class _VisitorScreenState extends State<VisitorScreen> {
  final _formKey         = GlobalKey<FormState>();
  final _nameController  = TextEditingController();
  final _phoneController = TextEditingController();
  final _unitController  = TextEditingController();

  String    _purpose   = 'Personal Visit';
  DateTime? _visitDate;
  bool      _isLoading = false;

  final List<String> _purposes = [
    'Personal Visit', 'Delivery', 'Contractor / Repair',
    'Caregiver', 'Moving In/Out', 'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _unitController.dispose();
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
    if (picked != null) setState(() => _visitDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_visitDate == null) {
      showErrorSnack(context, 'Please select a visit date');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await RequestsService().submitVisitorRequest(
        request: VisitorRequest(
          visitorName:  _nameController.text.trim(),
          visitorPhone: _phoneController.text.trim(),
          visitDate:    _visitDate!,
          visitPurpose: _purpose,
          unitNumber:   _unitController.text.trim(),
        ),
      );
      if (mounted) {
        showSuccessSnack(context, 'Visitor pass registered!');
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
            title:    'Visitor Pass',
            subtitle: 'Register an expected visitor',
            icon:     Icons.badge_outlined,
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [

                    FormCard(children: [
                      const FieldLabel('Your Unit Number'),
                      RequestTextField(
                        controller: _unitController,
                        hint: 'e.g. A-204',
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                    ]),
                    const SizedBox(height: 14),

                    FormCard(children: [
                      const FieldLabel('Visitor Full Name'),
                      RequestTextField(
                        controller: _nameController,
                        hint: 'e.g. Ahmed Benali',
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      const FieldLabel('Visitor Phone Number'),
                      RequestTextField(
                        controller: _phoneController,
                        hint: 'e.g. +213 555 123 456',
                        keyboardType: TextInputType.phone,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                    ]),
                    const SizedBox(height: 14),

                    FormCard(children: [
                      const FieldLabel('Purpose of Visit'),
                      RequestDropdown(
                        value: _purpose,
                        items: _purposes,
                        onChanged: (v) => setState(() => _purpose = v!),
                      ),
                      const SizedBox(height: 16),
                      const FieldLabel('Visit Date'),
                      DatePickerRow(
                        selectedDate: _visitDate,
                        hint: 'Select visit date',
                        onTap: _pickDate,
                      ),
                    ]),
                    const SizedBox(height: 28),

                    SubmitButton(
                      label:     'Register Visitor',
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