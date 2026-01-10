import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_plants_usecase.dart';
import '../../domain/usecases/water_plant_usecase.dart';
import '../../domain/usecases/create_plant_usecase.dart';
import '../../domain/usecases/update_plant_usecase.dart';
import 'plants_event.dart';
import 'plants_state.dart';

class PlantsBloc extends Bloc<PlantsEvent, PlantsState> {
  final GetPlantsUseCase getPlantsUseCase;
  final WaterPlantUseCase waterPlantUseCase;
  final CreatePlantUseCase createPlantUseCase;
  final UpdatePlantUseCase updatePlantUseCase;

  PlantsBloc({
    required this.getPlantsUseCase,
    required this.waterPlantUseCase,
    required this.createPlantUseCase,
    required this.updatePlantUseCase,
  }) : super(const PlantsInitial()) {
    on<LoadPlants>(_onLoadPlants);
    on<PlantsRefreshed>(_onPlantsRefreshed);
    on<PlantWatered>(_onPlantWatered);
    on<PlantCreated>(_onPlantCreated);
    on<PlantUpdated>(_onPlantUpdated);
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
    result.fold(
      (failure) {
        // Revert to previous state on error
        if (currentState is PlantsLoaded) {
          emit(currentState);
        } else {
          emit(PlantsError(message: failure.message));
        }
      },
      (updatedPlant) async {
        // Refresh plants list after successful watering
        final refreshResult = await getPlantsUseCase(const NoParams());
        refreshResult.fold(
          (failure) => emit(PlantsError(message: failure.message)),
          (plants) => emit(PlantsLoaded(plants)),
        );
      },
    );
  }

  Future<void> _onPlantCreated(
    PlantCreated event,
    Emitter<PlantsState> emit,
  ) async {
    final currentState = state;
    if (currentState is PlantsLoaded) {
      // Keep current plants visible while creating
      emit(PlantsLoaded(currentState.plants));
    } else {
      emit(const PlantsLoading());
    }

    final result = await createPlantUseCase(
      CreatePlantParams(
        name: event.name,
        type: event.type,
        nextWateringDate: event.nextWateringDate,
      ),
    );

    result.fold(
      (failure) {
        // Show error state
        emit(PlantsError(message: failure.message));
      },
      (newPlant) async {
        // Refresh plants list after successful creation
        final refreshResult = await getPlantsUseCase(const NoParams());
        refreshResult.fold(
          (failure) => emit(PlantsError(message: failure.message)),
          (plants) => emit(PlantsLoaded(plants)),
        );
      },
    );
  }

  Future<void> _onPlantUpdated(
    PlantUpdated event,
    Emitter<PlantsState> emit,
  ) async {
    final currentState = state;
    if (currentState is PlantsLoaded) {
      // Keep current plants visible while updating
      emit(PlantsLoaded(currentState.plants));
    } else {
      emit(const PlantsLoading());
    }

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

    result.fold(
      (failure) {
        // Show error state
        emit(PlantsError(message: failure.message));
      },
      (updatedPlant) async {
        // Refresh plants list after successful update
        final refreshResult = await getPlantsUseCase(const NoParams());
        refreshResult.fold(
          (failure) => emit(PlantsError(message: failure.message)),
          (plants) => emit(PlantsLoaded(plants)),
        );
      },
    );
  }
}

