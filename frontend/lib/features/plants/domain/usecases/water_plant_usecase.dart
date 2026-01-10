import '../../../../core/usecases/usecase.dart';
import '../entities/plant.dart';
import '../repositories/plants_repository.dart';

class WaterPlantUseCase implements UseCase<Plant, WaterPlantParams> {
  final PlantsRepository repository;

  WaterPlantUseCase(this.repository);

  @override
  Future<Result<Plant>> call(WaterPlantParams params) async {
    return await repository.waterPlant(params.plantId);
  }
}

class WaterPlantParams {
  final String plantId;

  WaterPlantParams({required this.plantId});
}

