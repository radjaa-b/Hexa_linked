import 'package:flutter/material.dart';

// ─── Colors ───────────────────────────────────────────────────
class AppColors {
  static const darkGreen  = Color(0xFF1C3B2E);
  static const parchment  = Color(0xFFE8D9B5);
  static const gold       = Color(0xFFB8974A);
  static const mutedGreen = Color(0xFF6B9E80);
  static const cream      = Color(0xFFF5F0E8);
  static const teal       = Color(0xFF4A7C6F);
}

// ─── App bar ──────────────────────────────────────────────────
class RequestsAppBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const RequestsAppBar({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top:    MediaQuery.of(context).padding.top + 12,
        left:   16, right: 16, bottom: 16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.darkGreen,
        borderRadius: BorderRadius.only(
          bottomLeft:  Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: AppColors.parchment.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.parchment, size: 16),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.parchment.withOpacity(0.12),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                  color: AppColors.gold.withOpacity(0.30), width: 1),
            ),
            child: Icon(icon, color: AppColors.parchment, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: AppColors.parchment,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                Text(subtitle,
                    style: const TextStyle(
                        color: AppColors.mutedGreen, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Form card ────────────────────────────────────────────────
class FormCard extends StatelessWidget {
  final List<Widget> children;
  const FormCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.gold.withOpacity(0.15), width: 1),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children),
    );
  }
}

// ─── Field label ──────────────────────────────────────────────
class FieldLabel extends StatelessWidget {
  final String text;
  const FieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.darkGreen)),
    );
  }
}

// ─── Text field ───────────────────────────────────────────────
class RequestTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const RequestTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
          fontSize: 14,
          color: AppColors.darkGreen,
          fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
            color: AppColors.darkGreen.withOpacity(0.30), fontSize: 14),
        filled: true,
        fillColor: AppColors.cream,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: AppColors.gold.withOpacity(0.50), width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      ),
    );
  }
}

// ─── Dropdown ─────────────────────────────────────────────────
class RequestDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final void Function(String?) onChanged;

  const RequestDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.cream,
          style: const TextStyle(
              fontSize: 14,
              color: AppColors.darkGreen,
              fontWeight: FontWeight.w500),
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.darkGreen.withOpacity(0.50)),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ─── Date picker row ──────────────────────────────────────────
class DatePickerRow extends StatelessWidget {
  final DateTime? selectedDate;
  final String hint;
  final VoidCallback onTap;

  const DatePickerRow({
    super.key,
    required this.selectedDate,
    required this.hint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 18,
                color: AppColors.darkGreen.withOpacity(0.40)),
            const SizedBox(width: 10),
            Text(
              selectedDate == null
                  ? hint
                  : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
              style: TextStyle(
                  color: selectedDate == null
                      ? AppColors.darkGreen.withOpacity(0.30)
                      : AppColors.darkGreen,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Submit button ────────────────────────────────────────────
class SubmitButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const SubmitButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkGreen,
          disabledBackgroundColor: AppColors.darkGreen.withOpacity(0.50),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.parchment))
            : Text(label,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.parchment,
                    letterSpacing: 0.2)),
      ),
    );
  }
}

// ─── Snackbars ────────────────────────────────────────────────
void showSuccessSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Row(children: [
      const Icon(Icons.check_circle_outline_rounded,
          color: Colors.white, size: 18),
      const SizedBox(width: 10),
      Text(message, style: const TextStyle(fontWeight: FontWeight.w500)),
    ]),
    backgroundColor: AppColors.teal,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.all(16),
  ));
}

void showErrorSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Row(children: [
      const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
      const SizedBox(width: 10),
      Expanded(
          child: Text(message,
              style: const TextStyle(fontWeight: FontWeight.w500))),
    ]),
    backgroundColor: Colors.redAccent.shade700,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.all(16),
  ));
}