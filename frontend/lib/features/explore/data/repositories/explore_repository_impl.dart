import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/explore_plant.dart';
import '../../domain/entities/problem.dart';
import '../../domain/repositories/explore_repository.dart';
import '../datasources/explore_remote_data_source.dart';

class ExploreRepositoryImpl implements ExploreRepository {
  final ExploreRemoteDataSource remoteDataSource;

  ExploreRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Result<List<ExplorePlant>>> getExplorePlants({
    String? category,
    String? search,
  }) async {
    try {
      final plants = await remoteDataSource.getExplorePlants(
        category: category,
        search: search,
      );
      return Result.success(plants);
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(e.message));
    } catch (e) {
      return Result.failure(UnknownFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Result<List<Problem>>> getProblems({
    String? category,
    String? search,
  }) async {
    try {
      final problems = await remoteDataSource.getProblems(
        category: category,
        search: search,
      );
      return Result.success(problems);
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(e.message));
    } catch (e) {
      return Result.failure(UnknownFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }
}
