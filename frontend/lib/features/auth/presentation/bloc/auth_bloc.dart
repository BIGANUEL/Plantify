import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final AuthRepository authRepository;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.authRepository,
  }) : super(const AuthUnauthenticated(isLoginMode: true)) {
    on<AuthInitialized>(_onAuthInitialized);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<AuthModeToggled>(_onAuthModeToggled);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onAuthInitialized(
    AuthInitialized event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await authRepository.getCurrentUser();
    result.fold(
      (failure) => emit(const AuthUnauthenticated(isLoginMode: true)),
      (user) {
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(const AuthUnauthenticated(isLoginMode: true));
        }
      },
    );
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await loginUseCase(
      LoginParams(
        email: event.email,
        password: event.password,
      ),
    );
    result.fold(
      (failure) {
        developer.log(
          'AuthBloc: Login failed',
          name: 'AuthBloc',
          error: failure,
        );
        emit(AuthError(
          message: failure.message,
          isLoginMode: true,
        ));
      },
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await registerUseCase(
      RegisterParams(
        email: event.email,
        password: event.password,
        name: event.name,
      ),
    );
    result.fold(
      (failure) {
        developer.log(
          'AuthBloc: Registration failed',
          name: 'AuthBloc',
          error: failure,
        );
        emit(AuthError(
          message: failure.message,
          isLoginMode: false,
        ));
      },
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  void _onAuthModeToggled(
    AuthModeToggled event,
    Emitter<AuthState> emit,
  ) {
    final currentState = state;
    if (currentState is AuthUnauthenticated) {
      emit(AuthUnauthenticated(isLoginMode: !currentState.isLoginMode));
    } else if (currentState is AuthError) {
      emit(AuthError(
        message: currentState.message,
        isLoginMode: !currentState.isLoginMode,
      ));
    } else {
      emit(const AuthUnauthenticated(isLoginMode: true));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await logoutUseCase(const NoParams());
    result.fold(
      (failure) => emit(AuthError(
        message: failure.message,
        isLoginMode: true,
      )),
      (_) => emit(const AuthUnauthenticated(isLoginMode: true)),
    );
  }
}

