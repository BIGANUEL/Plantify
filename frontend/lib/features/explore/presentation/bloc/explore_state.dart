import 'package:equatable/equatable.dart';
import '../../domain/entities/explore_plant.dart';
import '../../domain/entities/problem.dart';

abstract class ExploreState extends Equatable {
  const ExploreState();

  @override
  List<Object?> get props => [];
}

class ExploreInitial extends ExploreState {
  const ExploreInitial();
}

class ExploreLoading extends ExploreState {
  const ExploreLoading();
}

class ExplorePlantsLoaded extends ExploreState {
  final List<ExplorePlant> plants;

  const ExplorePlantsLoaded(this.plants);

  @override
  List<Object?> get props => [plants];
}

class ProblemsLoaded extends ExploreState {
  final List<Problem> problems;

  const ProblemsLoaded(this.problems);

  @override
  List<Object?> get props => [problems];
}

class ExploreError extends ExploreState {
  final String message;

  const ExploreError({required this.message});

  @override
  List<Object?> get props => [message];
}
