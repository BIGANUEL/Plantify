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
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      authRepository: sl(),
    ),
  );

  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );

  sl.registerFactory(
    () => PlantsBloc(
      getPlantsUseCase: sl(),
      waterPlantUseCase: sl(),
      createPlantUseCase: sl(),
      updatePlantUseCase: sl(),
      deletePlantUseCase: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetPlantsUseCase(sl()));
  sl.registerLazySingleton(() => WaterPlantUseCase(sl()));
  sl.registerLazySingleton(() => CreatePlantUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePlantUseCase(sl()));
  sl.registerLazySingleton(() => DeletePlantUseCase(sl()));

  sl.registerLazySingleton<PlantsRepository>(
    () => PlantsRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<PlantsRemoteDataSource>(
    () => PlantsRemoteDataSourceImpl(
      sharedPreferences: sl(),
    ),
  );

  sl.registerFactory(
    () => ExploreBloc(
      getExplorePlantsUseCase: sl(),
      getProblemsUseCase: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetExplorePlantsUseCase(sl()));
  sl.registerLazySingleton(() => GetProblemsUseCase(sl()));

  sl.registerLazySingleton<ExploreRepository>(
    () => ExploreRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<ExploreRemoteDataSource>(
    () => ExploreRemoteDataSourceImpl(),
  );

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
}

