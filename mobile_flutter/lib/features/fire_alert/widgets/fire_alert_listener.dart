import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:resident_app/features/auth/services/auth_service.dart';

class FireAlertListener extends StatefulWidget {
  final Widget child;

  const FireAlertListener({
    super.key,
    required this.child,
  });

  @override
  State<FireAlertListener> createState() => _FireAlertListenerState();
}

class _FireAlertListenerState extends State<FireAlertListener> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Set<int> _dismissedAlertIds = {};

  Timer? _timer;
  bool _dialogOpen = false;

  @override
  void initState() {
    super.initState();
    print('🔥 FireAlertListener started');

    _checkFireAlerts();
    _timer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _checkFireAlerts(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _checkFireAlerts() async {
    if (_dialogOpen) return;

    final session = await AuthService.getStoredSession(); 
    if (session == null) return;

    try {
      print('FIRE ALERT URL: ${AuthService.baseUrl}/alerts/me');
      final response = await http.get(
        
        Uri.parse('${AuthService.baseUrl}/alerts/me'),
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
      );

  print('FIRE ALERT CHECK STATUS: ${response.statusCode}');
print('FIRE ALERT CHECK BODY: ${response.body}');
      if (response.statusCode != 200) {
        return;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List) return;

      final fireAlerts = decoded.where((item) {
        if (item is! Map<String, dynamic>) return false;

        final id = item['id'];
        final type = item['incident_type']?.toString().toLowerCase();
        final status = item['status']?.toString().toLowerCase();

        return id is int &&
            type == 'fire' &&
            status != 'resolved' &&
            !_dismissedAlertIds.contains(id);
      }).toList();

      if (fireAlerts.isEmpty) {
        await _audioPlayer.stop();
        return;
      }

      final latest = fireAlerts.first as Map<String, dynamic>;

      if (!mounted) return;

      _showFireDialog(latest);
    } catch (_) {
      return;
    }
  }

  Future<void> _playAlarm() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(
      AssetSource('sounds/sos-mobile.mp3'),
    );
  }

  Future<void> _stopAlarm() async {
    await _audioPlayer.stop();
  }

  void _showFireDialog(Map<String, dynamic> alert) {
    final alertId = alert['id'];

    if (alertId is! int) return;

    _dialogOpen = true;
    _playAlarm();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: Dialog.fullscreen(
            backgroundColor: const Color(0xFF7F1D1D),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'FIRE EMERGENCY',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'A fire alert has been detected inside the residence.',
                      style: TextStyle(
                        color: Color(0xFFFFE4E6),
                        fontSize: 17,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3F1515),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFFFCA5A5),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _InfoLine(
                            label: 'Location',
                            value: alert['location']?.toString() ?? 'Unknown',
                          ),
                          const SizedBox(height: 10),
                          _InfoLine(
                            label: 'Description',
                            value:
                                alert['description']?.toString() ??
                                'Fire detected by IoT sensor',
                          ),
                          const SizedBox(height: 10),
                          _InfoLine(
                            label: 'Status',
                            value: alert['status']?.toString() ?? 'pending',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Safety steps',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),

                    const _SafetyStep(text: 'Stay calm and alert people nearby.'),
                    const _SafetyStep(text: 'Move away from the fire source immediately.'),
                    const _SafetyStep(text: 'Open windows only if it is safe to do so.'),
                    const _SafetyStep(text: 'Do not use elevators. Use stairs.'),
                    const _SafetyStep(text: 'Evacuate the building if the fire spreads.'),
                    const _SafetyStep(text: 'Call firefighters: 14'),

                    const Spacer(),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton(
                        onPressed: () async {
                          _dismissedAlertIds.add(alertId);
                          await _stopAlarm();

                          if (context.mounted) {
                            Navigator.pop(context);
                          }

                          _dialogOpen = false;
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Dismiss',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ).then((_) {
      _dialogOpen = false;
      _stopAlarm();
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class _InfoLine extends StatelessWidget {
  final String label;
  final String value;

  const _InfoLine({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '$label: $value',
      style: const TextStyle(
        color: Color(0xFFFFE4E6),
        fontSize: 15,
        height: 1.4,
      ),
    );
  }
}

class _SafetyStep extends StatelessWidget {
  final String text;

  const _SafetyStep({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFFFFE4E6),
                fontSize: 16,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}