import 'package:equatable/equatable.dart';
import '../../domain/entities/plant.dart';

abstract class PlantsState extends Equatable {
  const PlantsState();

  @override
  List<Object?> get props => [];
}

class PlantsInitial extends PlantsState {
  const PlantsInitial();
}

class PlantsLoading extends PlantsState {
  const PlantsLoading();
}

class PlantsLoaded extends PlantsState {
  final List<Plant> plants;

  const PlantsLoaded(this.plants);

  @override
  List<Object?> get props => [plants];
}

class PlantsError extends PlantsState {
  final String message;

  const PlantsError({required this.message});

  @override
  List<Object?> get props => [message];
}

class PlantWatering extends PlantsState {
  final List<Plant> plants;
  final String plantId;

  const PlantWatering({required this.plants, required this.plantId});

  @override
  List<Object?> get props => [plants, plantId];
}

