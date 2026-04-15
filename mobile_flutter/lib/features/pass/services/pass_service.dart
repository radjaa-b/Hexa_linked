import 'package:resident_app/features/pass/models/pass_model.dart';

class PassService {
  // ---------------------------------------------------------------------------
  // getResidentPass()
  //
  // CURRENT ROLE:
  // Returns simulated resident pass data so the screen can work now
  // even without backend or hardware.
  //
  // LATER:
  // This method should call your backend API using http or dio
  // and return real pass data from the server.
  //
  // Example future backend endpoint:
  // GET /resident/pass
  // ---------------------------------------------------------------------------
  Future<ResidentPass> getResidentPass() async {
    // Simulate network delay so the UI behaves more like a real app.
    await Future.delayed(const Duration(milliseconds: 800));

    return ResidentPass(
      residentId: 'R-1024',
      residentName: 'Selsa',
      apartment: 'Unit 4B',
      qrToken: _generateSimulatedQrToken(),
      isActive: true,
      expiresAt: DateTime.now().add(const Duration(hours: 12)),
    );
  }

  // ---------------------------------------------------------------------------
  // refreshResidentPass()
  //
  // CURRENT ROLE:
  // Generates a new simulated QR token.
  // Useful to imitate a pass refresh or rotating access code.
  //
  // LATER:
  // This method can call a backend endpoint that generates a new secure token.
  //
  // Example future backend endpoint:
  // POST /resident/pass/refresh
  // ---------------------------------------------------------------------------
  Future<ResidentPass> refreshResidentPass() async {
    // Simulate a small loading delay.
    await Future.delayed(const Duration(milliseconds: 500));

    return ResidentPass(
      residentId: 'R-1024',
      residentName: 'Selsa',
      apartment: 'Unit 4B',
      qrToken: _generateSimulatedQrToken(),
      isActive: true,
      expiresAt: DateTime.now().add(const Duration(hours: 12)),
    );
  }

  // ---------------------------------------------------------------------------
  // _generateSimulatedQrToken()
  //
  // CURRENT ROLE:
  // Creates a fake token for simulation/demo purposes.
  //
  // WHY:
  // Even before backend is ready, the QR should not always look like
  // one static hardcoded string.
  //
  // LATER:
  // Replace this completely with a token sent by the backend.
  // The backend should be responsible for generating secure access tokens.
  // ---------------------------------------------------------------------------
  String _generateSimulatedQrToken() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return 'SIM_PASS_$now';
  }
}