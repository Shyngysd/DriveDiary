import 'package:dio/dio.dart';

import '../domain/day_summary.dart';
import '../domain/trip.dart';
import '../domain/trips_repository.dart';
import 'api_exceptions.dart';
import 'trips_api.dart';

class ApiTripsRepository implements TripsRepository {
  ApiTripsRepository({TripsApi? api}) : _api = api ?? TripsApi();

  final TripsApi _api;

  @override
  Future<List<Trip>> listTrips(DateTime date) async {
    final response = await _request(() => _api.getTrips(_date(date)));
    return (response.data as List<dynamic>)
        .map((item) => Trip.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<DaySummary> getSummary(DateTime date) async {
    final response = await _request(() => _api.getSummary(_date(date)));
    return DaySummary.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<DateTime>> listDays() async {
    final response = await _request(_api.getDays);
    return (response.data as List<dynamic>)
        .map((item) => DateTime.parse(item as String))
        .toList();
  }

  @override
  Future<Trip> addTrip(Trip trip) async {
    final response = await _request(() => _api.postTrip(trip.toJson()));
    return Trip.fromJson(response.data as Map<String, dynamic>);
  }

  String _date(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Future<Response<dynamic>> _request(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      return await request();
    } on DioException catch (error) {
      final response = error.response;
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        throw const TripsConnectionException(
          'Нет связи с сервером. Проверьте подключение и адрес сервера',
        );
      }

      final body = response?.data;
      final errorBody = body is Map<String, dynamic> ? body['error'] : null;
      final message = errorBody is Map<String, dynamic>
          ? errorBody['message'] as String? ?? 'Что-то пошло не так'
          : 'Что-то пошло не так';
      final code = errorBody is Map<String, dynamic>
          ? errorBody['code'] as String?
          : null;
      if (response?.statusCode == 409) {
        throw TripsConflictException(message, code: code);
      }
      if (response?.statusCode == 422) {
        throw TripsValidationException(message, code: code);
      }
      throw TripsApiException(message, code: code);
    }
  }
}
