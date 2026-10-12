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

class TripsNetworkException extends TripsApiException {
  const TripsNetworkException(super.message);
}
