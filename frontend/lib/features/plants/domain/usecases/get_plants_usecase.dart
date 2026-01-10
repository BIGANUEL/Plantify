import '../../../../core/usecases/usecase.dart';
import '../entities/plant.dart';
import '../repositories/plants_repository.dart';

class GetPlantsUseCase implements UseCase<List<Plant>, NoParams> {
  final PlantsRepository repository;

  GetPlantsUseCase(this.repository);

  @override
  Future<Result<List<Plant>>> call(NoParams params) async {
    return await repository.getPlants();
  }
}

