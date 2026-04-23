class ResidentProfile {
  final int? id;
  final String name;
  final String email;
  final String? username;
  final String? role;
  final bool? isActive;
  final String? unit;
  final String? phone;

  const ResidentProfile({
    this.id,
    required this.name,
    required this.email,
    this.username,
    this.role,
    this.isActive,
    this.unit,
    this.phone,
  });

  factory ResidentProfile.fromJson(Map<String, dynamic> json) {
    return ResidentProfile(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse('${json['id'] ?? ''}'),
      name: _stringOrFallback(
        json['full_name'],
        fallback: _stringOrFallback(
          json['name'],
          fallback: _stringOrFallback(json['username']),
        ),
      ),
      email: _stringOrFallback(json['email']),
      username: _nullableString(json['username']),
      role: _nullableString(json['role']),
      isActive: json['is_active'] is bool
          ? json['is_active'] as bool
          : _nullableString(json['is_active'])?.toLowerCase() == 'true',
      unit:
          _nullableString(json['unit_number']) ?? _nullableString(json['unit']),
      phone:
          _nullableString(json['phone_number']) ??
          _nullableString(json['phone']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': name,
      'email': email,
      'username': username,
      'role': role,
      'is_active': isActive,
      'unit_number': unit,
      'phone_number': phone,
    };
  }

  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) return 'R';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  static String _stringOrFallback(dynamic value, {String fallback = ''}) {
    final parsed = _nullableString(value);
    if (parsed == null || parsed.isEmpty) return fallback;
    return parsed;
  }

  static String? _nullableString(dynamic value) {
    final parsed = value?.toString().trim();
    if (parsed == null || parsed.isEmpty) return null;
    return parsed;
  }
}
