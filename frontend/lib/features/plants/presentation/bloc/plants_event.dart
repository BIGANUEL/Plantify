import 'package:equatable/equatable.dart';

abstract class PlantsEvent extends Equatable {
  const PlantsEvent();

  @override
  List<Object?> get props => [];
}

class LoadPlants extends PlantsEvent {
  const LoadPlants();
}

class PlantsRefreshed extends PlantsEvent {
  const PlantsRefreshed();
}

class PlantWatered extends PlantsEvent {
  final String plantId;

  const PlantWatered({required this.plantId});

  @override
  List<Object?> get props => [plantId];
}

class PlantCreated extends PlantsEvent {
  final String name;
  final String type;
  final DateTime nextWateringDate;

  const PlantCreated({
    required this.name,
    required this.type,
    required this.nextWateringDate,
  });

  @override
  List<Object?> get props => [name, type, nextWateringDate];
}

class PlantUpdated extends PlantsEvent {
  final String id;
  final String name;
  final String type;
  final int wateringInterval;
  final String? light;
  final String? humidity;
  final String? careTips;

  const PlantUpdated({
    required this.id,
    required this.name,
    required this.type,
    required this.wateringInterval,
    this.light,
    this.humidity,
    this.careTips,
  });

  @override
  List<Object?> get props => [id, name, type, wateringInterval, light, humidity, careTips];
}

