class ResidentPass {
  // Unique id of the resident.
  // Later this should come from the backend/database.
  final String residentId;

  // Full name of the resident.
  // Example: "Radja Bennamoun"
  final String residentName;

  // Apartment / unit number of the resident.
  // Example: "Unit 4B"
  final String apartment;

  // The QR value / token that will be shown in the app.
  // For now it can be a fake string generated locally.
  // Later this should come from the backend as a secure token.
  final String qrToken;

  // Whether the pass is currently active.
  // This can be useful later if the backend disables a resident's access.
  final bool isActive;

  // Optional expiration date/time for the pass.
  // For now this can stay null in simulation.
  // Later the backend may send a real expiration timestamp.
  final DateTime? expiresAt;

  const ResidentPass({
    required this.residentId,
    required this.residentName,
    required this.apartment,
    required this.qrToken,
    required this.isActive,
    this.expiresAt,
  });

  // ---------------------------------------------------------------------------
  // fromJson()
  // Used later when the backend sends data as JSON.
  //
  // Example backend response:
  // {
  //   "resident_id": "123",
  //   "resident_name": "Radja Bennamoun",
  //   "apartment": "Unit 4B",
  //   "qr_token": "abc123xyz",
  //   "is_active": true,
  //   "expires_at": "2026-03-26T18:00:00Z"
  // }
  // ---------------------------------------------------------------------------
  factory ResidentPass.fromJson(Map<String, dynamic> json) {
    return ResidentPass(
      residentId: json['resident_id'] ?? '',
      residentName: json['resident_name'] ?? '',
      apartment: json['apartment'] ?? '',
      qrToken: json['qr_token'] ?? '',
      isActive: json['is_active'] ?? false,
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'])
          : null,
    );
  }

  // ---------------------------------------------------------------------------
  // toJson()
  // Useful if later you want to send this object back to the backend
  // or debug its content easily.
  // ---------------------------------------------------------------------------
  Map<String, dynamic> toJson() {
    return {
      'resident_id': residentId,
      'resident_name': residentName,
      'apartment': apartment,
      'qr_token': qrToken,
      'is_active': isActive,
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

  // ---------------------------------------------------------------------------
  // copyWith()
  // Helpful later if you want to update only one field
  // without rebuilding the whole object manually.
  //
  // Example:
  // pass.copyWith(qrToken: "new_token")
  // ---------------------------------------------------------------------------
  ResidentPass copyWith({
    String? residentId,
    String? residentName,
    String? apartment,
    String? qrToken,
    bool? isActive,
    DateTime? expiresAt,
  }) {
    return ResidentPass(
      residentId: residentId ?? this.residentId,
      residentName: residentName ?? this.residentName,
      apartment: apartment ?? this.apartment,
      qrToken: qrToken ?? this.qrToken,
      isActive: isActive ?? this.isActive,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}