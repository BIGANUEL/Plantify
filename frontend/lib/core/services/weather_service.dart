import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherData {
  final double temperature;
  final double humidity;
  final String description;
  final String weatherCode;

  WeatherData({
    required this.temperature,
    required this.humidity,
    required this.description,
    required this.weatherCode,
  });
}

class WeatherService {
  static const String baseUrl = 'https://api.open-meteo.com/v1';
  
  static IconData getWeatherIcon(String weatherCode) {
    final code = int.tryParse(weatherCode) ?? 0;
    if (code == 0) return Icons.wb_sunny_rounded;
    if (code <= 3) return Icons.wb_cloudy_rounded;
    if (code <= 49) return Icons.wb_cloudy_rounded;
    if (code <= 59) return Icons.grain_rounded;
    if (code <= 69) return Icons.umbrella_rounded;
    if (code <= 79) return Icons.ac_unit_rounded;
    if (code <= 84) return Icons.water_drop_rounded;
    if (code <= 86) return Icons.ac_unit_rounded;
    return Icons.wb_sunny_rounded;
  }
  
  static String getWeatherDescription(String weatherCode) {
    final code = int.tryParse(weatherCode) ?? 0;
    if (code == 0) return 'Clear sky';
    if (code <= 3) return 'Partly cloudy';
    if (code <= 49) return 'Foggy';
    if (code <= 59) return 'Drizzle';
    if (code <= 69) return 'Rainy';
    if (code <= 79) return 'Snowy';
    if (code <= 84) return 'Rain showers';
    if (code <= 86) return 'Snow showers';
    if (code <= 99) return 'Thunderstorm';
    return 'Unknown';
  }
  
  // Get plant care message based on weather
  static String getPlantCareMessage(String weatherCode, double temperature) {
    final code = int.tryParse(weatherCode) ?? 0;
    if (code >= 51 && code <= 69) {
      return 'Rainy day - check if plants need less water';
    }
    if (code >= 71 && code <= 86) {
      return 'Cold weather - protect sensitive plants';
    }
    if (temperature > 30) {
      return 'Hot day - ensure plants are well hydrated';
    }
    if (temperature < 10) {
      return 'Cold day - move sensitive plants indoors';
    }
    return 'Perfect day for outdoor plants!';
  }

  Future<WeatherData> getCurrentWeather({
    double? latitude,
    double? longitude,
    String cityName = 'London',
  }) async {
    try {
      double lat = latitude ?? 51.5074;
      double lon = longitude ?? -0.1278;
      
      final url = Uri.parse(
        '$baseUrl/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,weather_code&timezone=auto'
      );
      
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Weather request timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final current = data['current'];
        
        if (current != null) {
          final temp = (current['temperature_2m'] as num).toDouble();
          final humidity = (current['relative_humidity_2m'] as num).toDouble();
          final weatherCode = current['weather_code'].toString();
          
          return WeatherData(
            temperature: temp,
            humidity: humidity,
            description: getWeatherDescription(weatherCode),
            weatherCode: weatherCode,
          );
        } else {
          throw Exception('Invalid weather data format');
        }
      } else {
        throw Exception('Failed to fetch weather: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Weather service error: ${e.toString()}');
    }
  }
}
