import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:resident_app/features/pass/services/pass_service.dart';

class ResidentPassScreen extends StatefulWidget {
  const ResidentPassScreen({super.key});

  @override
  State<ResidentPassScreen> createState() => _ResidentPassScreenState();
}

class _ResidentPassScreenState extends State<ResidentPassScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _passData;

  @override
  void initState() {
    super.initState();
    _loadPass();
  }

  Future<void> _loadPass() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await PassService.getResidentPass();

      if (!mounted) return;

      setState(() {
        _passData = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pass = _passData;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F0E8),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF1C3B2E)),
        title: const Text(
          'My Access Pass',
          style: TextStyle(
            color: Color(0xFF1C3B2E),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1C3B2E)),
            )
          : _error != null
              ? _ErrorState(message: _error!, onRetry: _loadPass)
              : pass == null
                  ? _ErrorState(
                      message: 'No resident pass found.',
                      onRetry: _loadPass,
                    )
                  : RefreshIndicator(
                      color: const Color(0xFF1C3B2E),
                      onRefresh: _loadPass,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Use this pass at the residence entrance.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF6B6B6B),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1C3B2E),
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 18,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'Resident Digital Pass',
                                    style: TextStyle(
                                      color: Color(0xFFE8D9B5),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Active Access',
                                    style: TextStyle(
                                      color: Color(0xFF6B9E80),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: QrImageView(
                                      data: pass['qr_code']?.toString() ?? '',
                                      version: QrVersions.auto,
                                      size: 220,
                                      backgroundColor: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  _InfoRow(
                                    label: 'Resident',
                                    value:
                                        (pass['full_name'] ?? pass['username'])
                                            .toString(),
                                  ),
                                  const SizedBox(height: 12),
                                  _InfoRow(
                                    label: 'Apartment',
                                    value:
                                        (pass['unit_number'] ?? 'Unknown')
                                            .toString(),
                                  ),
                                  const SizedBox(height: 12),
                                  _InfoRow(
                                    label: 'Resident ID',
                                    value: pass['resident_id'].toString(),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 54,
                              child: ElevatedButton.icon(
                                onPressed: _loadPass,
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('Refresh Pass'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFB8974A),
                                  foregroundColor: const Color(0xFF1C3B2E),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFB54747),
              size: 42,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFB54747),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1C3B2E),
                foregroundColor: const Color(0xFFE8D9B5),
              ),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label:',
          style: const TextStyle(
            color: Color(0xFF6B9E80),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFFE8D9B5),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}