import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GoogleSignInUseCase implements UseCase<User, NoParams> {
  final AuthRepository repository;

  GoogleSignInUseCase(this.repository);

  @override
  Future<Result<User>> call(NoParams params) async {
    return await repository.signInWithGoogle();
  }
}

