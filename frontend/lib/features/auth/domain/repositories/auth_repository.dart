import '../entities/user.dart';
import '../../../../core/usecases/usecase.dart';

abstract class AuthRepository {
  Future<Result<User>> login(String email, String password);
  Future<Result<User>> register(String email, String password, String name);
  Future<Result<User>> signInWithGoogle();
  Future<Result<void>> logout();
  Future<Result<User?>> getCurrentUser();
}

