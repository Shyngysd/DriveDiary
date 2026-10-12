class TripsApiException implements Exception {
  const TripsApiException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

class TripsValidationException extends TripsApiException {
  const TripsValidationException(super.message, {super.code});
}

class TripsConflictException extends TripsApiException {
  const TripsConflictException(super.message, {super.code});
}

class TripsConnectionException extends TripsApiException {
  const TripsConnectionException(super.message);
}

String tripsErrorMessage(Object error) {
  if (error is TripsApiException) return error.message;
  return 'Что-то пошло не так';
}
