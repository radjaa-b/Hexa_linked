import 'package:flutter/material.dart';

class QrCard extends StatelessWidget {
  const QrCard({
    super.key,
    required this.qrToken,
  });

  // ---------------------------------------------------------------------------
  // qrToken
  // This is the value that later should be turned into a real QR code.
  //
  // For now:
  // - we are only showing a visual placeholder
  // - the token is displayed as small helper text under the icon
  //
  // Later:
  // - replace the placeholder container content with a real QR widget
  // - example package: qr_flutter
  // - use qrToken as the data source for the QR
  // ---------------------------------------------------------------------------
  final String qrToken;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ---------------------------------------------------------------------
        // QR VISUAL CARD
        // Right now this is just a clean placeholder.
        // Later this white box should contain the real QR code widget.
        // ---------------------------------------------------------------------
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

        const SizedBox(height: 12),

        // ---------------------------------------------------------------------
        // TOKEN PREVIEW
        // Helpful in simulation so you can see that the token exists
        // and changes on refresh.
        //
        // Later:
        // - you can keep this for testing only
        // - or remove it in the final polished UI
        // ---------------------------------------------------------------------
        Text(
          qrToken,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF6B9E80),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}