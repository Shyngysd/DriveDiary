import 'package:dio/dio.dart';

class TripsApi {
  TripsApi({Dio? dio, String? apiUrl})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 5),
              receiveTimeout: const Duration(seconds: 10),
              sendTimeout: const Duration(seconds: 10),
              baseUrl:
                  apiUrl ??
                  const String.fromEnvironment(
                    'API_URL',
                    defaultValue: 'http://localhost:8000',
                  ),
              headers: {'Content-Type': 'application/json'},
            ),
          );

  final Dio _dio;

  Future<Response<dynamic>> getTrips(String date) =>
      _dio.get('/trips', queryParameters: {'date': date});

  Future<Response<dynamic>> getSummary(String date) =>
      _dio.get('/summary', queryParameters: {'date': date});

  Future<Response<dynamic>> getDays() => _dio.get('/days');

  Future<Response<dynamic>> postTrip(Map<String, dynamic> trip) =>
      _dio.post('/trips', data: trip);
}
