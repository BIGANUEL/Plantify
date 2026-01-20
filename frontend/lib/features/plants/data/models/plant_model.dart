import '../../domain/entities/plant.dart';

class PlantModel extends Plant {
  const PlantModel({
    required super.id,
    required super.name,
    required super.type,
    required super.nextWateringDate,
    super.wateringInterval,
    super.lastWateredDate,
    super.light,
    super.humidity,
    super.careTips,
  });

  factory PlantModel.fromJson(Map<String, dynamic> json) {
    // Parse nextWateringDate - handle both ISO 8601 and yyyy-MM-dd formats
    DateTime parseDate(dynamic dateValue) {
      if (dateValue == null) return DateTime.now();
      if (dateValue is String) {
        // Try parsing as ISO 8601 first
        try {
          return DateTime.parse(dateValue);
        } catch (e) {
          // If that fails, try yyyy-MM-dd format
          try {
            return DateTime.parse('${dateValue}T00:00:00Z');
          } catch (e2) {
            throw FormatException('Invalid date format: $dateValue');
          }
        }
      } else if (dateValue is int) {
        // Handle Unix timestamp
        return DateTime.fromMillisecondsSinceEpoch(dateValue);
      } else {
        throw FormatException('Invalid date type: ${dateValue.runtimeType}');
      }
    }

    DateTime? parseNullableDate(dynamic dateValue) {
      if (dateValue == null) return null;
      return parseDate(dateValue);
    }

    return PlantModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      // Backend uses 'nextWatering' but model expects 'nextWateringDate'
      nextWateringDate: parseDate(json['nextWatering'] ?? json['nextWateringDate']),
      // Backend uses 'wateringFrequency' but model expects 'wateringInterval'
      wateringInterval: (json['wateringFrequency'] as int?) ?? (json['wateringInterval'] as int?) ?? 7,
      // Backend uses 'lastWatered' but model expects 'lastWateredDate'
      lastWateredDate: parseNullableDate(json['lastWatered'] ?? json['lastWateredDate']),
      light: json['light'] as String?,
      humidity: json['humidity'] as String?,
      // Backend uses 'careInstructions' but model expects 'careTips'
      careTips: json['careInstructions'] as String? ?? json['careTips'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'nextWateringDate': nextWateringDate.toIso8601String(),
      'wateringInterval': wateringInterval,
      if (lastWateredDate != null)
        'lastWateredDate': lastWateredDate!.toIso8601String(),
      if (light != null) 'light': light,
      if (humidity != null) 'humidity': humidity,
      if (careTips != null) 'careTips': careTips,
    };
  }
}
