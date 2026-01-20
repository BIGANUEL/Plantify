import 'package:equatable/equatable.dart';

class Plant extends Equatable {
  final String id;
  final String name;
  final String type;
  final DateTime nextWateringDate;
  final int wateringInterval; // in days
  final DateTime? lastWateredDate;
  final String? light;
  final String? humidity;
  final String? careTips;

  const Plant({
    required this.id,
    required this.name,
    required this.type,
    required this.nextWateringDate,
    this.wateringInterval = 7,
    this.lastWateredDate,
    this.light,
    this.humidity,
    this.careTips,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        nextWateringDate,
        wateringInterval,
        lastWateredDate,
        light,
        humidity,
        careTips,
      ];
}

