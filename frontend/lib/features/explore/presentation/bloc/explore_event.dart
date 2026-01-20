import 'package:equatable/equatable.dart';

abstract class ExploreEvent extends Equatable {
  const ExploreEvent();

  @override
  List<Object?> get props => [];
}

class LoadExplorePlants extends ExploreEvent {
  final String? category;
  final String? search;

  const LoadExplorePlants({
    this.category,
    this.search,
  });

  @override
  List<Object?> get props => [category, search];
}

class LoadProblems extends ExploreEvent {
  final String? category;
  final String? search;

  const LoadProblems({
    this.category,
    this.search,
  });

  @override
  List<Object?> get props => [category, search];
}
