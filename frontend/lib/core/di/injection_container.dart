import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/plants/data/datasources/plants_remote_data_source.dart';
import '../../features/plants/data/repositories/plants_repository_impl.dart';
import '../../features/plants/domain/repositories/plants_repository.dart';
import '../../features/plants/domain/usecases/get_plants_usecase.dart';
import '../../features/plants/domain/usecases/water_plant_usecase.dart';
import '../../features/plants/domain/usecases/create_plant_usecase.dart';
import '../../features/plants/domain/usecases/update_plant_usecase.dart';
import '../../features/plants/domain/usecases/delete_plant_usecase.dart';
import '../../features/plants/presentation/bloc/plants_bloc.dart';
import '../../features/explore/data/datasources/explore_remote_data_source.dart';
import '../../features/explore/data/repositories/explore_repository_impl.dart';
import '../../features/explore/domain/repositories/explore_repository.dart';
import '../../features/explore/domain/usecases/get_explore_plants_usecase.dart';
import '../../features/explore/domain/usecases/get_problems_usecase.dart';
import '../../features/explore/presentation/bloc/explore_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Features - Auth
  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      authRepository: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // Features - Plants
  // Bloc
  sl.registerFactory(
    () => PlantsBloc(
      getPlantsUseCase: sl(),
      waterPlantUseCase: sl(),
      createPlantUseCase: sl(),
      updatePlantUseCase: sl(),
      deletePlantUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetPlantsUseCase(sl()));
  sl.registerLazySingleton(() => WaterPlantUseCase(sl()));
  sl.registerLazySingleton(() => CreatePlantUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePlantUseCase(sl()));
  sl.registerLazySingleton(() => DeletePlantUseCase(sl()));

  // Repository
  sl.registerLazySingleton<PlantsRepository>(
    () => PlantsRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<PlantsRemoteDataSource>(
    () => PlantsRemoteDataSourceImpl(
      sharedPreferences: sl(),
    ),
  );

  // Features - Explore
  // Bloc
  sl.registerFactory(
    () => ExploreBloc(
      getExplorePlantsUseCase: sl(),
      getProblemsUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetExplorePlantsUseCase(sl()));
  sl.registerLazySingleton(() => GetProblemsUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ExploreRepository>(
    () => ExploreRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<ExploreRemoteDataSource>(
    () => ExploreRemoteDataSourceImpl(),
  );

  // Core
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
}

