import '../../../../core/usecases/usecase.dart';
import '../entities/problem.dart';
import '../repositories/explore_repository.dart';

class GetProblemsUseCase implements UseCase<List<Problem>, GetProblemsParams> {
  final ExploreRepository repository;

  GetProblemsUseCase(this.repository);

  @override
  Future<Result<List<Problem>>> call(GetProblemsParams params) async {
    return await repository.getProblems(
      category: params.category,
      search: params.search,
    );
  }
}

class GetProblemsParams {
  final String? category;
  final String? search;

  const GetProblemsParams({
    this.category,
    this.search,
  });
}
