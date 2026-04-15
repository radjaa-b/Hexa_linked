import 'dart:convert';

class AuthTokenClaims {
  final String subject;
  final String role;
  final DateTime expiresAtUtc;
  final Map<String, dynamic> payload;

  const AuthTokenClaims({
    required this.subject,
    required this.role,
    required this.expiresAtUtc,
    required this.payload,
  });

  bool get isExpired => DateTime.now().toUtc().isAfter(expiresAtUtc);
}

class AuthSession {
  final String accessToken;
  final String tokenType;
  final AuthTokenClaims claims;

  const AuthSession({
    required this.accessToken,
    required this.tokenType,
    required this.claims,
  });

  String get role => claims.role;

  bool get isExpired => claims.isExpired;

  bool hasRole(String expectedRole) =>
      role.trim().toLowerCase() == expectedRole.trim().toLowerCase();
}

class AuthTokenHelper {
  static AuthSession buildSession({
    required String accessToken,
    required String tokenType,
  }) {
    return AuthSession(
      accessToken: accessToken,
      tokenType: tokenType,
      claims: decodeClaims(accessToken),
    );
  }

  static AuthTokenClaims decodeClaims(String token) {
    final normalizedToken = token.trim();
    if (normalizedToken.isEmpty) {
      throw const FormatException('Access token is missing.');
    }

    final segments = normalizedToken.split('.');
    if (segments.length != 3) {
      throw const FormatException('Access token is malformed.');
    }

    final payloadJson = utf8.decode(
      base64Url.decode(base64Url.normalize(segments[1])),
    );
    final decodedPayload = jsonDecode(payloadJson);

    if (decodedPayload is! Map<String, dynamic>) {
      throw const FormatException('Access token payload is invalid.');
    }

    final subject = decodedPayload['sub']?.toString().trim();
    if (subject == null || subject.isEmpty) {
      throw const FormatException(
        'Access token is missing the subject claim.',
      );
    }

    final role = decodedPayload['role']?.toString().trim();
    if (role == null || role.isEmpty) {
      throw const FormatException('Access token is missing the role claim.');
    }

    final expiresAtUtc = _parseExpiration(decodedPayload['exp']);

    return AuthTokenClaims(
      subject: subject,
      role: role,
      expiresAtUtc: expiresAtUtc,
      payload: decodedPayload,
    );
  }

  static String extractRole(String token) => decodeClaims(token).role;

  static DateTime _parseExpiration(dynamic rawExp) {
    final expSeconds = switch (rawExp) {
      int value => value,
      double value => value.toInt(),
      String value => int.tryParse(value),
      _ => null,
    };

    if (expSeconds == null || expSeconds <= 0) {
      throw const FormatException(
        'Access token is missing a valid exp claim.',
      );
    }

    return DateTime.fromMillisecondsSinceEpoch(
      expSeconds * 1000,
      isUtc: true,
    );
  }
}
