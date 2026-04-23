import 'package:flutter/material.dart';
import '../widgets/auth_scaffold.dart';
import 'package:resident_app/features/auth/services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final email = TextEditingController();
  bool loading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final trimmedEmail = email.text.trim();
    if (trimmedEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email'),
          backgroundColor: Color(0xFF152E22),
        ),
      );
      return;
    }

    setState(() => loading = true);

    try {
      await AuthService.forgotPassword(trimmedEmail);
      if (!mounted) return;
      setState(() => _emailSent = true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: const Color(0xFF152E22),
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),

          // ── Back button ──
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8D9B5).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFB8974A).withOpacity(0.25),
                      width: 0.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: Color(0xFFE8D9B5),
                    size: 14,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Back',
                  style: TextStyle(color: Color(0xFF6B9E80), fontSize: 12),
                ),
              ],
            ),
          ),

          const Spacer(),

          if (_emailSent) ...[
            // ── Success state ──
            const Text(
              'CHECK YOUR EMAIL',
              style: TextStyle(
                color: Color(0xFFB8974A),
                fontSize: 11,
                letterSpacing: 2.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Email sent.',
              style: TextStyle(
                color: Color(0xFFE8D9B5),
                fontSize: 36,
                fontWeight: FontWeight.w800,
                height: 1.1,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'If this email is registered and active,\n'
              'you will receive a password reset link\n'
              'shortly. Check your inbox.',
              style: TextStyle(
                color: Color(0xFF6B9E80),
                fontSize: 12,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB8974A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Back to login',
                    style: TextStyle(
                      color: Color(0xFF1C3B2E),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
          ] else ...[
            // ── Input state ──
            const Text(
              'FORGOT PASSWORD',
              style: TextStyle(
                color: Color(0xFFB8974A),
                fontSize: 11,
                letterSpacing: 2.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Reset your\naccess.',
              style: TextStyle(
                color: Color(0xFFE8D9B5),
                fontSize: 36,
                fontWeight: FontWeight.w800,
                height: 1.1,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Enter your email and we'll send you\na reset link.",
              style: TextStyle(
                color: Color(0xFF6B9E80),
                fontSize: 12,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF152E22),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DarkField(
                    label: 'EMAIL',
                    hint: 'your@email.com',
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: loading ? null : _submit,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: loading
                              ? const Color(0xFFB8974A).withOpacity(0.5)
                              : const Color(0xFFB8974A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF1C3B2E),
                                ),
                              )
                            : const Text(
                                'Send reset link',
                                style: TextStyle(
                                  color: Color(0xFF1C3B2E),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  DARK THEMED TEXT FIELD
// ─────────────────────────────────────────────────────────────
class _DarkField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType keyboardType;

  const _DarkField({
    required this.label,
    required this.hint,
    required this.controller,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE8D9B5).withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFB8974A).withOpacity(0.25),
          width: 0.5,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6B9E80),
              fontSize: 10,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            style: const TextStyle(color: Color(0xFFE8D9B5), fontSize: 14),
            cursorColor: const Color(0xFFB8974A),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              hintText: hint,
              hintStyle: TextStyle(
                color: const Color(0xFFE8D9B5).withOpacity(0.25),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
