import '../errors/failures.dart';

/// Result class that mimics Either<Failure, T> from dartz
/// Use this when dartz package is not available
class Result<T> {
  final T? _data;
  final Failure? _failure;

  const Result._(this._data, this._failure);

  /// Create a success result
  factory Result.success(T data) => Result._(data, null);

  /// Create a failure result
  factory Result.failure(Failure failure) => Result._(null, failure);

  /// Check if result is success
  bool get isSuccess => _failure == null;

  /// Check if result is failure
  bool get isFailure => _failure != null;

  /// Get data (throws if failure)
  T get data {
    if (_failure != null) {
      throw Exception('Cannot get data from failure result');
    }
    return _data as T;
  }

  /// Get failure (throws if success)
  Failure get failure {
    final failure = _failure;
    if (failure == null) {
      throw Exception('Cannot get failure from success result');
    }
    return failure;
  }

  /// Fold pattern - execute onSuccess if success, onFailure if failure
  R fold<R>(R Function(Failure failure) onFailure, R Function(T data) onSuccess) {
    if (isFailure) {
      return onFailure(_failure!);
    } else {
      return onSuccess(_data as T);
    }
  }
}

/// Base class for all use cases
/// [Type] - Return type
/// [Params] - Parameters type
abstract class UseCase<Type, Params> {
  Future<Result<Type>> call(Params params);
}

/// Use case with no parameters
class NoParams {
  const NoParams();
}
