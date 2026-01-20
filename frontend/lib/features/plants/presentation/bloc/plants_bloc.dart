import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_plants_usecase.dart';
import '../../domain/usecases/water_plant_usecase.dart';
import '../../domain/usecases/create_plant_usecase.dart';
import '../../domain/usecases/update_plant_usecase.dart';
import '../../domain/usecases/delete_plant_usecase.dart';
import 'plants_event.dart';
import 'plants_state.dart';

class PlantsBloc extends Bloc<PlantsEvent, PlantsState> {
  final GetPlantsUseCase getPlantsUseCase;
  final WaterPlantUseCase waterPlantUseCase;
  final CreatePlantUseCase createPlantUseCase;
  final UpdatePlantUseCase updatePlantUseCase;
  final DeletePlantUseCase deletePlantUseCase;

  PlantsBloc({
    required this.getPlantsUseCase,
    required this.waterPlantUseCase,
    required this.createPlantUseCase,
    required this.updatePlantUseCase,
    required this.deletePlantUseCase,
  }) : super(const PlantsInitial()) {
    on<LoadPlants>(_onLoadPlants);
    on<PlantsRefreshed>(_onPlantsRefreshed);
    on<PlantWatered>(_onPlantWatered);
    on<PlantCreated>(_onPlantCreated);
    on<PlantUpdated>(_onPlantUpdated);
    on<PlantDeleted>(_onPlantDeleted);
  }

  Future<void> _onLoadPlants(
    LoadPlants event,
    Emitter<PlantsState> emit,
  ) async {
    emit(const PlantsLoading());
    final result = await getPlantsUseCase(const NoParams());
    result.fold(
      (failure) => emit(PlantsError(message: failure.message)),
      (plants) => emit(PlantsLoaded(plants)),
    );
  }

  Future<void> _onPlantsRefreshed(
    PlantsRefreshed event,
    Emitter<PlantsState> emit,
  ) async {
    // Keep current state if we have plants
    final currentState = state;
    if (currentState is PlantsLoaded) {
      // Show loading but keep current plants visible
      emit(PlantsLoaded(currentState.plants));
    } else {
      emit(const PlantsLoading());
    }

    final result = await getPlantsUseCase(const NoParams());
    result.fold(
      (failure) => emit(PlantsError(message: failure.message)),
      (plants) => emit(PlantsLoaded(plants)),
    );
  }

  Future<void> _onPlantWatered(
    PlantWatered event,
    Emitter<PlantsState> emit,
  ) async {
    final currentState = state;
    if (currentState is PlantsLoaded) {
      // Show watering state for the specific plant
      emit(PlantWatering(plants: currentState.plants, plantId: event.plantId));
    }

    final result = await waterPlantUseCase(WaterPlantParams(plantId: event.plantId));
    if (result.isFailure) {
      // Revert to previous state on error
      if (currentState is PlantsLoaded) {
        emit(currentState);
      } else {
        emit(PlantsError(message: result.failure.message));
      }
      return;
    }

    // Refresh plants list after successful watering
    // This fetches fresh data from the repository, ensuring a new list instance
    // which will trigger Equatable comparison and UI rebuild
    final refreshResult = await getPlantsUseCase(const NoParams());
    if (refreshResult.isFailure) {
      emit(PlantsError(message: refreshResult.failure.message));
    } else {
      // Emit with fresh list from use case to ensure state change is detected
      emit(PlantsLoaded(refreshResult.data));
    }
  }

  Future<void> _onPlantCreated(
    PlantCreated event,
    Emitter<PlantsState> emit,
  ) async {
    print('([PLANTS_BLOC] Plant creation started: ${event.name})');

    try {
      final result = await createPlantUseCase(
        CreatePlantParams(
          name: event.name,
          type: event.type,
          nextWateringDate: event.nextWateringDate,
          wateringInterval: event.wateringInterval,
          light: event.light,
          humidity: event.humidity,
          careTips: event.careTips,
        ),
      );

      if (result.isFailure) {
        print('([PLANTS_BLOC] Plant creation failed: ${result.failure.message})');
        emit(PlantsError(message: result.failure.message));
        return;
      }

      print('([PLANTS_BLOC] Plant created successfully: ${result.data.id})');
      
      // Refresh plants list after successful creation
      print('([PLANTS_BLOC] Starting refresh after plant creation)');
      final refreshResult = await getPlantsUseCase(const NoParams());
      
      if (refreshResult.isFailure) {
        print('([PLANTS_BLOC] Failed to refresh plants: ${refreshResult.failure.message})');
        emit(PlantsError(message: refreshResult.failure.message));
        return;
      }
      
      print('([PLANTS_BLOC] Plants refreshed after creation: ${refreshResult.data.length} plants)');
      print('([PLANTS_BLOC] Emitting PlantsLoaded with ${refreshResult.data.length} plants)');
      emit(PlantsLoaded(refreshResult.data));
      
    } catch (e, stackTrace) {
      print('([PLANTS_BLOC] Exception during plant creation: $e)');
      print('([PLANTS_BLOC] Stack trace: $stackTrace)');
      emit(PlantsError(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  Future<void> _onPlantUpdated(
    PlantUpdated event,
    Emitter<PlantsState> emit,
  ) async {
    // Don't emit intermediate state - keep current state to avoid triggering navigation
    // The UI will show loading via the _isLoading flag in the screen
    final currentState = state;

    final result = await updatePlantUseCase(
      UpdatePlantParams(
        id: event.id,
        name: event.name,
        type: event.type,
        wateringInterval: event.wateringInterval,
        light: event.light,
        humidity: event.humidity,
        careTips: event.careTips,
      ),
    );

    if (result.isFailure) {
      // Show error state
      emit(PlantsError(message: result.failure.message));
      return;
    }

    // Refresh plants list after successful update
    // This fetches fresh data from the repository, ensuring a new list instance
    // which will trigger Equatable comparison and UI rebuild
    // Only emit PlantsLoaded after refresh completes
    final refreshResult = await getPlantsUseCase(const NoParams());
    if (refreshResult.isFailure) {
      // Revert to previous state on refresh failure
      if (currentState is PlantsLoaded) {
        emit(currentState);
      } else {
        emit(PlantsError(message: refreshResult.failure.message));
      }
    } else {
      // Emit with fresh list from use case to ensure state change is detected
      // This is the only PlantsLoaded emission, so navigation will happen at the right time
      emit(PlantsLoaded(refreshResult.data));
    }
  }

  Future<void> _onPlantDeleted(
    PlantDeleted event,
    Emitter<PlantsState> emit,
  ) async {
    final result = await deletePlantUseCase(DeletePlantParams(plantId: event.plantId));
    
    if (result.isFailure) {
      emit(PlantsError(message: result.failure.message));
      return;
    }
    
    // Refresh plants list after successful deletion
    final refreshResult = await getPlantsUseCase(const NoParams());
    if (refreshResult.isFailure) {
      emit(PlantsError(message: refreshResult.failure.message));
    } else {
      emit(PlantsLoaded(refreshResult.data));
    }
  }
}

