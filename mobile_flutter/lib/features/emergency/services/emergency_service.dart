import 'package:resident_app/features/emergency/models/emergency_request.dart';

class EmergencyService {
  static const bool _useMock = true;

  static Future<void> send(EmergencyRequest request) async {
    if (_useMock) return _mockSend(request);

    // TODO: real API call when backend is ready
    // final baseUrl = dotenv.env['API_BASE_URL']!;
    // await http.post(...)
  }

  static Future<void> _mockSend(EmergencyRequest request) async {
    await Future.delayed(const Duration(seconds: 2)); // simulate network
    // simulate occasional failure for testing
    // throw Exception('Network error');
  }
}