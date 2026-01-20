import '../../../../core/usecases/usecase.dart';
import '../repositories/plants_repository.dart';

class DeletePlantUseCase implements UseCase<void, DeletePlantParams> {
  final PlantsRepository repository;

  DeletePlantUseCase(this.repository);

  @override
  Future<Result<void>> call(DeletePlantParams params) async {
    return await repository.deletePlant(params.plantId);
  }
}

class DeletePlantParams {
  final String plantId;

  DeletePlantParams({required this.plantId});
}
