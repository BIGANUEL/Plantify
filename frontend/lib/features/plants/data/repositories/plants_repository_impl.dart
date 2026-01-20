import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/plant.dart';
import '../../domain/repositories/plants_repository.dart';
import '../datasources/plants_remote_data_source.dart';

class PlantsRepositoryImpl implements PlantsRepository {
  final PlantsRemoteDataSource remoteDataSource;

  PlantsRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Result<List<Plant>>> getPlants() async {
    try {
      final plants = await remoteDataSource.getPlants();
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
  Future<Result<Plant>> waterPlant(String plantId) async {
    try {
      final plant = await remoteDataSource.waterPlant(plantId);
      return Result.success(plant);
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(e.message));
    } catch (e) {
      return Result.failure(UnknownFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Result<Plant>> createPlant(
    String name,
    String type,
    DateTime nextWateringDate, {
    int wateringInterval = 7,
    String? light,
    String? humidity,
    String? careTips,
  }) async {
    try {
      final plant = await remoteDataSource.createPlant(
        name,
        type,
        nextWateringDate,
        wateringInterval: wateringInterval,
        light: light,
        humidity: humidity,
        careTips: careTips,
      );
      return Result.success(plant);
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(e.message));
    } catch (e) {
      return Result.failure(UnknownFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Result<Plant>> updatePlant(
    String id,
    String name,
    String type,
    int wateringInterval,
    String? light,
    String? humidity,
    String? careTips,
  ) async {
    try {
      final plant = await remoteDataSource.updatePlant(
        id,
        name,
        type,
        wateringInterval,
        light,
        humidity,
        careTips,
      );
      return Result.success(plant);
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(e.message));
    } catch (e) {
      return Result.failure(UnknownFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void>> deletePlant(String plantId) async {
    try {
      await remoteDataSource.deletePlant(plantId);
      return Result.success(null);
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(e.message));
    } catch (e) {
      return Result.failure(UnknownFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }
}

