import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_explore_plants_usecase.dart';
import '../../domain/usecases/get_problems_usecase.dart';
import 'explore_event.dart';
import 'explore_state.dart';

class ExploreBloc extends Bloc<ExploreEvent, ExploreState> {
  final GetExplorePlantsUseCase getExplorePlantsUseCase;
  final GetProblemsUseCase getProblemsUseCase;

  ExploreBloc({
    required this.getExplorePlantsUseCase,
    required this.getProblemsUseCase,
  }) : super(const ExploreInitial()) {
    on<LoadExplorePlants>(_onLoadExplorePlants);
    on<LoadProblems>(_onLoadProblems);
  }

  Future<void> _onLoadExplorePlants(
    LoadExplorePlants event,
    Emitter<ExploreState> emit,
  ) async {
    emit(const ExploreLoading());
    final result = await getExplorePlantsUseCase(
      GetExplorePlantsParams(
        category: event.category,
        search: event.search,
      ),
    );
    result.fold(
      (failure) => emit(ExploreError(message: failure.message)),
      (plants) => emit(ExplorePlantsLoaded(plants)),
    );
  }

  Future<void> _onLoadProblems(
    LoadProblems event,
    Emitter<ExploreState> emit,
  ) async {
    emit(const ExploreLoading());
    final result = await getProblemsUseCase(
      GetProblemsParams(
        category: event.category,
        search: event.search,
      ),
    );
    result.fold(
      (failure) => emit(ExploreError(message: failure.message)),
      (problems) => emit(ProblemsLoaded(problems)),
    );
  }
}
