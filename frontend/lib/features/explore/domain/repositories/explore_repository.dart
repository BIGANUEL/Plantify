import '../../../../core/usecases/usecase.dart';
import '../entities/explore_plant.dart';
import '../entities/problem.dart';

abstract class ExploreRepository {
  Future<Result<List<ExplorePlant>>> getExplorePlants({
    String? category,
    String? search,
  });
  Future<Result<List<Problem>>> getProblems({
    String? category,
    String? search,
  });
}
