import '../../../../core/usecases/usecase.dart';
import '../entities/explore_plant.dart';
import '../repositories/explore_repository.dart';

class GetExplorePlantsUseCase implements UseCase<List<ExplorePlant>, GetExplorePlantsParams> {
  final ExploreRepository repository;

  GetExplorePlantsUseCase(this.repository);

  @override
  Future<Result<List<ExplorePlant>>> call(GetExplorePlantsParams params) async {
    return await repository.getExplorePlants(
      category: params.category,
      search: params.search,
    );
  }
}

class GetExplorePlantsParams {
  final String? category;
  final String? search;

  const GetExplorePlantsParams({
    this.category,
    this.search,
  });
}
