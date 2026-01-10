import '../../../../core/usecases/usecase.dart';
import '../entities/plant.dart';
import '../repositories/plants_repository.dart';

class UpdatePlantUseCase implements UseCase<Plant, UpdatePlantParams> {
  final PlantsRepository repository;

  UpdatePlantUseCase(this.repository);

  @override
  Future<Result<Plant>> call(UpdatePlantParams params) async {
    return await repository.updatePlant(
      params.id,
      params.name,
      params.type,
      params.wateringInterval,
      params.light,
      params.humidity,
      params.careTips,
    );
  }
}

class UpdatePlantParams {
  final String id;
  final String name;
  final String type;
  final int wateringInterval;
  final String? light;
  final String? humidity;
  final String? careTips;

  UpdatePlantParams({
    required this.id,
    required this.name,
    required this.type,
    required this.wateringInterval,
    this.light,
    this.humidity,
    this.careTips,
  });
}

