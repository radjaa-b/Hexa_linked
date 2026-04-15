import 'package:flutter/material.dart';
import 'package:resident_app/core/navigation/app_route.dart';
import 'package:resident_app/core/navigation/main_navigation_screen.dart';
import 'package:resident_app/features/auth/services/auth_service.dart';
import 'package:resident_app/features/auth/screens/forgot_password_screen.dart';
import '../widgets/auth_scaffold.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();

  bool rememberMe = false;
  bool loading = false;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() => loading = true);
    try {
      final session = await AuthService.login(email.text.trim(), password.text);

      if (!mounted) return;

      if (!session.hasRole(AuthService.residentRole)) {
        await AuthService.clearToken();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This mobile application is for residents only.'),
            backgroundColor: Color(0xFF152E22),
          ),
        );
        return;
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        fadeSlideRoute(const MainNavigationScreen()),
      );
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
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return AuthScaffold(
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.only(bottom: keyboardHeight + 16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight:
                MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                MediaQuery.of(context).padding.bottom -
                32,
          ),
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

              const SizedBox(height: 40),

              // ── Headline ──
              const Text(
                'SIGN IN',
                style: TextStyle(
                  color: Color(0xFFB8974A),
                  fontSize: 11,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Welcome\nback.',
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
                'Your account is provided by\nthe residence administration.',
                style: TextStyle(
                  color: Color(0xFF6B9E80),
                  fontSize: 12,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 28),

              // ── Form panel ──
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
                    const SizedBox(height: 10),

                    _DarkField(
                      label: 'PASSWORD',
                      hint: '••••••••',
                      controller: password,
                      obscure: true,
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => rememberMe = !rememberMe),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: rememberMe
                                      ? const Color(0xFFB8974A)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: const Color(
                                      0xFFB8974A,
                                    ).withOpacity(0.5),
                                    width: 1,
                                  ),
                                ),
                                child: rememberMe
                                    ? const Icon(
                                        Icons.check,
                                        color: Color(0xFF1C3B2E),
                                        size: 11,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Remember me',
                                style: TextStyle(
                                  color: Color(0xFF6B9E80),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            fadeSlideRoute(const ForgotPasswordScreen()),
                          ),
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(
                              color: Color(0xFFB8974A),
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: loading ? null : _signIn,
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
                                  'Sign in',
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

              const SizedBox(height: 12),
            ],
          ),
        ),
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
