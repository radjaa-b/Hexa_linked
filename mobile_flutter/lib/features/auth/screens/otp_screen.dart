import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:resident_app/core/navigation/app_route.dart';
import '../widgets/auth_scaffold.dart';
import 'reset_password_screen.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());

  bool loading = false;

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  Future<void> _verifyOtp() async {
    if (_otpCode.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the full 6-digit code'),
          backgroundColor: Color(0xFF152E22),
        ),
      );
      return;
    }

    setState(() => loading = true);

    try {
      // TODO: await AuthService.verifyOtp(widget.email, _otpCode);
      await Future.delayed(const Duration(milliseconds: 900));

      if (!mounted) return;
      Navigator.push(
        context,
        fadeSlideRoute(
            ResetPasswordScreen(email: widget.email, otp: _otpCode)),
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

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 44,
      height: 52,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Color(0xFFE8D9B5),
        ),
        cursorColor: const Color(0xFFB8974A),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: const Color(0xFFE8D9B5).withOpacity(0.06),
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: const Color(0xFFB8974A).withOpacity(0.25),
              width: 0.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: const Color(0xFFB8974A).withOpacity(0.25),
              width: 0.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Color(0xFFB8974A),
              width: 1.5,
            ),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
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
                  style: TextStyle(
                    color: Color(0xFF6B9E80),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // ── Headline ──
          const Text(
            'VERIFICATION',
            style: TextStyle(
              color: Color(0xFFB8974A),
              fontSize: 11,
              letterSpacing: 2.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Check your\nemail.',
            style: TextStyle(
              color: Color(0xFFE8D9B5),
              fontSize: 36,
              fontWeight: FontWeight.w800,
              height: 1.1,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'We sent a 6-digit code to\n${widget.email}',
            style: const TextStyle(
              color: Color(0xFF6B9E80),
              fontSize: 12,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 28),

          // ── OTP panel ──
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
                // OTP boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, _buildOtpBox),
                ),

                const SizedBox(height: 14),

                // Resend
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      // TODO: resend OTP
                    },
                    child: const Text(
                      'Resend code',
                      style: TextStyle(
                        color: Color(0xFFB8974A),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Verify button
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: loading ? null : _verifyOtp,
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
                              'Verify',
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

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}