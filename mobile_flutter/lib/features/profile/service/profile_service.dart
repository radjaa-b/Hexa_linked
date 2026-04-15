import 'package:resident_app/features/auth/services/auth_service.dart';
import 'package:resident_app/features/profile/models/resident_profile.dart';

class ProfileService {
  static Future<ResidentProfile> fetchProfile() async {
    return AuthService.whoami();
  }
}
