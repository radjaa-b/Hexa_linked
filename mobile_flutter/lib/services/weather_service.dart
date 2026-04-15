import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

// ─────────────────────────────────────────────────────────────
//  WEATHER MODEL
// ─────────────────────────────────────────────────────────────
class WeatherData {
  final double temperature;
  final String description;
  final String icon;

  const WeatherData({
    required this.temperature,
    required this.description,
    required this.icon,
  });
}

// ─────────────────────────────────────────────────────────────
//  WEATHER SERVICE
// ─────────────────────────────────────────────────────────────
class WeatherService {
  static final _apiKey  = dotenv.env['WEATHER_API_KEY'] ?? '';
  static const _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  /// Fetches current weather based on the device's GPS location.
  /// Returns null if location permission is denied or the call fails.
  static Future<WeatherData?> fetchCurrent() async {
    try {
      // ── 1. Check & request location permission ──────────────
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }

      if (permission == LocationPermission.deniedForever) return null;

      // ── 2. Get device coordinates ───────────────────────────
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );

      // ── 3. Call OpenWeatherMap API ──────────────────────────
      final url = Uri.parse(
        '$_baseUrl'
        '?lat=${position.latitude}'
        '&lon=${position.longitude}'
        '&units=metric'
        '&appid=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode != 200) return null;

      // ── 4. Parse response ───────────────────────────────────
      final json        = jsonDecode(response.body) as Map<String, dynamic>;
      final temp        = (json['main']['temp'] as num).roundToDouble();
      final description = json['weather'][0]['description'] as String;
      final icon        = json['weather'][0]['icon'] as String;

      // Capitalise first letter  e.g. "clear sky" → "Clear sky"
      final formattedDesc =
          description[0].toUpperCase() + description.substring(1);

      return WeatherData(
        temperature: temp,
        description: formattedDesc,
        icon:        icon,
      );

    } catch (_) {
      return null; // silently fail — UI shows fallback
    }
  }

  /// Maps an OpenWeatherMap icon code to a Flutter IconData.
  static IconData iconFromCode(String code) {
    switch (code.substring(0, 2)) {
      case '01': return Icons.wb_sunny_rounded;
      case '02':
      case '03': return Icons.wb_cloudy_rounded;
      case '04': return Icons.cloud_rounded;
      case '09': return Icons.grain_rounded;
      case '10': return Icons.umbrella_rounded;
      case '11': return Icons.thunderstorm_rounded;
      case '13': return Icons.ac_unit_rounded;
      case '50': return Icons.blur_on_rounded;
      default:   return Icons.wb_sunny_rounded;
    }
  }
}