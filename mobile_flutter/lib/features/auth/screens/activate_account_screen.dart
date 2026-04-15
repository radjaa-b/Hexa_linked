import 'dart:async';

import 'package:flutter/material.dart';
import 'package:resident_app/features/auth/services/auth_service.dart';

import '../widgets/auth_scaffold.dart';

class ActivateAccountScreen extends StatefulWidget {
  final String? token;

  const ActivateAccountScreen({
    super.key,
    required this.token,
  });

  @override
  State<ActivateAccountScreen> createState() => _ActivateAccountScreenState();
}

class _ActivateAccountScreenState extends State<ActivateAccountScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _validating = true;
  bool _tokenValid = false;
  bool _submitting = false;
  bool _completed = false;

  String? _email;
  String? _username;
  String? _validationError;
  String? _submitError;
  Timer? _redirectTimer;

  String? get _normalizedToken {
    final token = widget.token?.trim();
    if (token == null || token.isEmpty) return null;
    return token;
  }

  @override
  void initState() {
    super.initState();
    _validateToken();
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _validateToken() async {
    final activationToken = _normalizedToken;
    if (activationToken == null) {
      setState(() {
        _validating = false;
        _tokenValid = false;
        _validationError =
            'This activation link is missing a token. Please request a new one from the residence administration.';
      });
      return;
    }

    setState(() {
      _validating = true;
      _tokenValid = false;
      _validationError = null;
    });

    try {
      final result = await AuthService.validateActivationToken(activationToken);
      if (!mounted) return;
      setState(() {
        _validating = false;
        _tokenValid = true;
        _email = result.email;
        _username = result.username;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _validating = false;
        _tokenValid = false;
        _validationError = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _submit() async {
    final activationToken = _normalizedToken;
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    setState(() {
      _submitError = null;
    });

    if (activationToken == null) {
      setState(() {
        _tokenValid = false;
        _validationError =
            'This activation link is invalid. Please request a new activation email.';
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _submitError = 'Please enter your password.';
      });
      return;
    }

    if (confirmPassword.isEmpty) {
      setState(() {
        _submitError = 'Please confirm your password.';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _submitError = 'Passwords do not match.';
      });
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      await AuthService.completeAccount(
        token: activationToken,
        password: password,
        confirmPassword: confirmPassword,
      );

      if (!mounted) return;
      setState(() {
        _completed = true;
      });

      _redirectTimer?.cancel();
      _redirectTimer = Timer(const Duration(seconds: 2), _goToLogin);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitError = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  void _goToLogin() {
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            GestureDetector(
              onTap: _goToLogin,
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
                    'Back to login',
                    style: TextStyle(
                      color: Color(0xFF6B9E80),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'ACTIVATE ACCOUNT',
              style: TextStyle(
                color: Color(0xFFB8974A),
                fontSize: 11,
                letterSpacing: 2,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Finish setting\nup your access.',
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
              _completed
                  ? 'Your account is ready. We will take you to the normal sign-in screen.'
                  : 'Validate your invitation link, choose a password, and then sign in with your email.',
              style: const TextStyle(
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
              child: _buildPanel(),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildPanel() {
    if (_validating) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Checking your activation link',
            style: TextStyle(
              color: Color(0xFFE8D9B5),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Please wait while we validate your token with the backend.',
            style: TextStyle(
              color: Color(0xFF6B9E80),
              fontSize: 12,
              height: 1.5,
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFFB8974A),
              ),
            ),
          ),
        ],
      );
    }

    if (_completed) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account activated',
            style: TextStyle(
              color: Color(0xFFE8D9B5),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _email == null || _email!.isEmpty
                ? 'Your password has been set successfully.'
                : 'Your password has been set for $_email.',
            style: const TextStyle(
              color: Color(0xFF6B9E80),
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: _goToLogin,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFB8974A),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Go to login',
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
      );
    }

    if (!_tokenValid) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This link cannot be used',
            style: TextStyle(
              color: Color(0xFFE8D9B5),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _validationError ??
                'This activation link is invalid or expired. Please request a new activation email.',
            style: const TextStyle(
              color: Color(0xFF6B9E80),
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _validateToken();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8D9B5).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFB8974A).withOpacity(0.25),
                        width: 0.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Retry',
                      style: TextStyle(
                        color: Color(0xFFE8D9B5),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: _goToLogin,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB8974A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Go to login',
                      style: TextStyle(
                        color: Color(0xFF1C3B2E),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Create your password',
          style: TextStyle(
            color: Color(0xFFE8D9B5),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'This link is valid. Choose the password you will use on the regular login screen.',
          style: TextStyle(
            color: Color(0xFF6B9E80),
            fontSize: 12,
            height: 1.5,
          ),
        ),
        if (_email != null && _email!.isNotEmpty) ...[
          const SizedBox(height: 18),
          _ReadOnlyInfoTile(
            label: 'EMAIL',
            value: _email!,
          ),
        ],
        if (_username != null && _username!.isNotEmpty) ...[
          const SizedBox(height: 10),
          _ReadOnlyInfoTile(
            label: 'USERNAME',
            value: _username!,
          ),
        ],
        const SizedBox(height: 16),
        _DarkField(
          label: 'PASSWORD',
          hint: 'Enter your password',
          controller: _passwordController,
          obscure: !_showPassword,
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                _showPassword = !_showPassword;
              });
            },
            icon: Icon(
              _showPassword ? Icons.visibility_off : Icons.visibility,
              color: const Color(0xFF6B9E80),
              size: 18,
            ),
          ),
        ),
        const SizedBox(height: 10),
        _DarkField(
          label: 'CONFIRM PASSWORD',
          hint: 'Repeat your password',
          controller: _confirmPasswordController,
          obscure: !_showConfirmPassword,
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                _showConfirmPassword = !_showConfirmPassword;
              });
            },
            icon: Icon(
              _showConfirmPassword ? Icons.visibility_off : Icons.visibility,
              color: const Color(0xFF6B9E80),
              size: 18,
            ),
          ),
        ),
        if (_submitError != null && _submitError!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            _submitError!,
            style: const TextStyle(
              color: Color(0xFFE8A6A6),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: GestureDetector(
            onTap: _submitting
                ? null
                : () {
                    _submit();
                  },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _submitting
                    ? const Color(0xFFB8974A).withOpacity(0.5)
                    : const Color(0xFFB8974A),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF1C3B2E),
                      ),
                    )
                  : const Text(
                      'Set password and continue',
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
    );
  }
}

class _ReadOnlyInfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _ReadOnlyInfoTile({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8D9B5).withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFB8974A).withOpacity(0.25),
          width: 0.5,
        ),
      ),
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
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFE8D9B5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _DarkField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscure;
  final Widget? suffixIcon;

  const _DarkField({
    required this.label,
    required this.hint,
    required this.controller,
    this.obscure = false,
    this.suffixIcon,
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
            style: const TextStyle(
              color: Color(0xFFE8D9B5),
              fontSize: 14,
            ),
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
              suffixIcon: suffixIcon,
            ),
          ),
        ],
      ),
    );
  }
}
