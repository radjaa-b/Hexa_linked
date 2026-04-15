import 'package:flutter/material.dart';
import '../models/maintenance_request.dart';
import '../services/requests_service.dart';
import '../widgets/requests_design.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  final _formKey        = GlobalKey<FormState>();
  final _unitController = TextEditingController();
  final _descController = TextEditingController();

  String    _category      = 'Plumbing';
  String    _priority      = 'medium';
  DateTime? _preferredDate;
  bool      _isLoading     = false;

  final List<String> _categories = [
    'Plumbing', 'Electrical', 'HVAC', 'Appliance',
    'Structural', 'Pest Control', 'Cleaning', 'Other',
  ];

  final _priorities = [
    {'key': 'low',    'label': 'Low',    'icon': Icons.arrow_downward_rounded},
    {'key': 'medium', 'label': 'Medium', 'icon': Icons.remove_rounded},
    {'key': 'high',   'label': 'High',   'icon': Icons.arrow_upward_rounded},
  ];

  @override
  void dispose() {
    _unitController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
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
    if (picked != null) setState(() => _preferredDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await RequestsService().submitMaintenanceRequest(
        request: MaintenanceRequest(
          unitNumber:    _unitController.text.trim(),
          category:      _category,
          description:   _descController.text.trim(),
          priority:      _priority,
          preferredDate: _preferredDate,
        ),
      );
      if (mounted) {
        showSuccessSnack(context, 'Maintenance request submitted!');
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
            title:    'Maintenance Request',
            subtitle: 'Report an issue in your unit',
            icon:     Icons.build_outlined,
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [

                    FormCard(children: [
                      const FieldLabel('Unit Number'),
                      RequestTextField(
                        controller: _unitController,
                        hint: 'e.g. A-204',
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      const FieldLabel('Category'),
                      RequestDropdown(
                        value: _category,
                        items: _categories,
                        onChanged: (v) => setState(() => _category = v!),
                      ),
                    ]),
                    const SizedBox(height: 14),

                    FormCard(children: [
                      const FieldLabel('Priority'),
                      const SizedBox(height: 8),
                      Row(
                        children: _priorities.map((p) {
                          final isSelected = _priority == p['key'];
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(
                                  () => _priority = p['key'] as String),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12),
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
                                  children: [
                                    Icon(p['icon'] as IconData,
                                        size: 18,
                                        color: isSelected
                                            ? AppColors.gold
                                            : AppColors.darkGreen
                                                .withOpacity(0.35)),
                                    const SizedBox(height: 5),
                                    Text(p['label'] as String,
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected
                                                ? AppColors.parchment
                                                : AppColors.darkGreen
                                                    .withOpacity(0.50))),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ]),
                    const SizedBox(height: 14),

                    FormCard(children: [
                      const FieldLabel('Description'),
                      RequestTextField(
                        controller: _descController,
                        hint: 'Describe the issue in detail...',
                        maxLines: 4,
                        validator: (v) => v == null || v.length < 10
                            ? 'Please provide more detail'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      const FieldLabel('Preferred Date (optional)'),
                      DatePickerRow(
                        selectedDate: _preferredDate,
                        hint: 'Select a preferred date',
                        onTap: _pickDate,
                      ),
                    ]),
                    const SizedBox(height: 28),

                    SubmitButton(
                      label:     'Submit Request',
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