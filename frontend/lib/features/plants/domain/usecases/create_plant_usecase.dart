import '../../../../core/usecases/usecase.dart';
import '../entities/plant.dart';
import '../repositories/plants_repository.dart';

class CreatePlantUseCase implements UseCase<Plant, CreatePlantParams> {
  final PlantsRepository repository;

  CreatePlantUseCase(this.repository);

  @override
  Future<Result<Plant>> call(CreatePlantParams params) async {
    return await repository.createPlant(
      params.name,
      params.type,
      params.nextWateringDate,
      wateringInterval: params.wateringInterval,
      light: params.light,
      humidity: params.humidity,
      careTips: params.careTips,
    );
  }
}

class CreatePlantParams {
  final String name;
  final String type;
  final DateTime nextWateringDate;
  final int wateringInterval;
  final String? light;
  final String? humidity;
  final String? careTips;

  CreatePlantParams({
    required this.name,
    required this.type,
    required this.nextWateringDate,
    this.wateringInterval = 7,
    this.light,
    this.humidity,
    this.careTips,
  });
}

