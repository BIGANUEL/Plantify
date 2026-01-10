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
    );
  }
}

class CreatePlantParams {
  final String name;
  final String type;
  final DateTime nextWateringDate;

  CreatePlantParams({
    required this.name,
    required this.type,
    required this.nextWateringDate,
  });
}

