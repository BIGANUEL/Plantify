import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Result<User>> login(String email, String password) async {
    try {
      final userModel = await remoteDataSource.login(email, password);
      await localDataSource.cacheUser(userModel);
      return Result.success(userModel);
    } on ValidationException catch (e) {
      return Result.failure(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Result.failure(CacheFailure(e.message));
    } catch (e) {
      return Result.failure(UnknownFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Result<User>> register(String email, String password, String name) async {
    try {
      final userModel = await remoteDataSource.register(email, password, name);
      await localDataSource.cacheUser(userModel);
      return Result.success(userModel);
    } on ValidationException catch (e) {
      return Result.failure(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Result.failure(CacheFailure(e.message));
    } catch (e) {
      return Result.failure(UnknownFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Result<User>> signInWithGoogle() async {
    try {
      final userModel = await remoteDataSource.signInWithGoogle();
      await localDataSource.cacheUser(userModel);
      return Result.success(userModel);
    } on ValidationException catch (e) {
      return Result.failure(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Result.failure(CacheFailure(e.message));
    } catch (e) {
      return Result.failure(UnknownFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await localDataSource.clearCache();
      return Result.success(null);
    } on CacheException catch (e) {
      return Result.failure(CacheFailure(e.message));
    } catch (e) {
      return Result.failure(UnknownFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Result<User?>> getCurrentUser() async {
    try {
      final userModel = await localDataSource.getCachedUser();
      return Result.success(userModel);
    } on CacheException catch (e) {
      return Result.failure(CacheFailure(e.message));
    } catch (e) {
      return Result.failure(UnknownFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }
}

