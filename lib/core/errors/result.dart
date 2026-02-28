import 'failure.dart';

class Result<T> {
  const Result._({required bool isSuccess, this.data, this.failure})
    : _isSuccess = isSuccess;

  final T? data;
  final Failure? failure;
  final bool _isSuccess;

  bool get isSuccess => _isSuccess;

  static Result<T> success<T>([T? data]) =>
      Result._(isSuccess: true, data: data);

  static Result<T> error<T>(Failure failure) =>
      Result._(isSuccess: false, failure: failure);
}
