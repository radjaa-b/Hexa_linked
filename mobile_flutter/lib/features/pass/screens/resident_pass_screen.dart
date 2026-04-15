import 'package:flutter/material.dart';
import 'package:resident_app/features/pass/models/pass_model.dart';

class ResidentPassScreen extends StatelessWidget {
  const ResidentPassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // -------------------------------------------------------------------------
    // TEMPORARY SIMULATED DATA
    // For now we create a fake resident pass directly inside the screen
    // so the UI can be tested without backend connection.
    //
    // Later:
    // - remove this hardcoded object
    // - get the pass data from PassService
    // - PassService itself will call the backend API
    // -------------------------------------------------------------------------
    final ResidentPass pass = ResidentPass(
      residentId: 'R-1024',
      residentName: 'Selsa',
      apartment: 'Unit 4B',
      qrToken: 'SIMULATED_QR_TOKEN_123456',
      isActive: true,
      expiresAt: DateTime.now().add(const Duration(hours: 12)),
    );

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
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // -----------------------------------------------------------------
            // TOP INFO TEXT
            // Small explanation for the resident.
            // -----------------------------------------------------------------
            const Text(
              'Use this pass at the residence entrance.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF6B6B6B),
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 24),

            // -----------------------------------------------------------------
            // MAIN PASS CARD
            // Contains QR placeholder + resident information
            // -----------------------------------------------------------------
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
                  // -------------------------------------------------------------
                  // PASS TITLE
                  // -------------------------------------------------------------
                  const Text(
                    'Resident Digital Pass',
                    style: TextStyle(
                      color: Color(0xFFE8D9B5),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    pass.isActive ? 'Active Access' : 'Inactive Access',
                    style: TextStyle(
                      color: pass.isActive
                          ? const Color(0xFF6B9E80)
                          : Colors.redAccent,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // -------------------------------------------------------------
                  // QR PLACEHOLDER
                  // For now this is just a visual placeholder.
                  // Later:
                  // - replace this container with a real QR widget
                  // - example package: qr_flutter
                  // - value should be pass.qrToken
                  // -------------------------------------------------------------
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.qr_code_2_rounded,
                        size: 120,
                        color: Color(0xFF1C3B2E),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // -------------------------------------------------------------
                  // RESIDENT INFO
                  // These values are taken from the ResidentPass model.
                  // Later they will come from backend data.
                  // -------------------------------------------------------------
                  _InfoRow(
                    label: 'Resident',
                    value: pass.residentName,
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    label: 'Apartment',
                    value: pass.apartment,
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    label: 'Resident ID',
                    value: pass.residentId,
                  ),

                  const SizedBox(height: 16),

                  if (pass.expiresAt != null)
                    _InfoRow(
                      label: 'Valid Until',
                      value: _formatDateTime(pass.expiresAt!),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // -----------------------------------------------------------------
            // ACTION BUTTON
            // For now:
            // - can simulate refreshing the pass later
            // - currently just shows a snackbar
            //
            // Later:
            // - call PassService.refreshPass()
            // - request a new QR token from backend
            // -----------------------------------------------------------------
            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pass refresh simulation coming next'),
                    ),
                  );
                },
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
    );
  }

  // ---------------------------------------------------------------------------
  // Helper method to format expiration date/time
  // Keeping it simple for now.
  // Later you can move formatting helpers to a shared utils file if needed.
  // ---------------------------------------------------------------------------
  static String _formatDateTime(DateTime dateTime) {
    final int hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final String minute = dateTime.minute.toString().padLeft(2, '0');
    final String amPm = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '${dateTime.day}/${dateTime.month}/${dateTime.year} - $hour:$minute $amPm';
  }
}

// -----------------------------------------------------------------------------
// SMALL REUSABLE INFO ROW
// Keeps the resident info section cleaner.
// Later this can stay here or be moved to widgets/ if reused elsewhere.
// -----------------------------------------------------------------------------
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