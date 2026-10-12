import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/features/trips/data/api_exceptions.dart';
import 'package:app/features/trips/data/api_trips_repository.dart';
import 'package:app/features/trips/data/trips_api.dart';

class _FailingApi extends TripsApi {
  _FailingApi(this.failure);

  final Object failure;

  @override
  Future<Response<dynamic>> getDays() => Future.error(failure);
}

DioException _dioFailure({
  DioExceptionType type = DioExceptionType.unknown,
  int? status,
  Object? data,
}) => DioException(
  requestOptions: RequestOptions(path: '/days'),
  type: type,
  response: status == null
      ? null
      : Response(
          requestOptions: RequestOptions(path: '/days'),
          statusCode: status,
          data: data,
        ),
);

void main() {
  test('maps connection failures and all timeout types', () async {
    for (final type in [
      DioExceptionType.connectionError,
      DioExceptionType.connectionTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.sendTimeout,
    ]) {
      final repository = ApiTripsRepository(
        api: _FailingApi(_dioFailure(type: type)),
      );

      await expectLater(
        repository.listDays(),
        throwsA(
          isA<TripsConnectionException>().having(
            (error) => error.message,
            'message',
            'Нет связи с сервером. Проверьте подключение и адрес сервера',
          ),
        ),
      );
    }
  });

  test('maps server messages for 409 and 422', () async {
    for (final entry in [
      (409, 'Такой id уже существует'),
      (422, 'Комиссия не может быть больше суммы'),
    ]) {
      final repository = ApiTripsRepository(
        api: _FailingApi(
          _dioFailure(
            status: entry.$1,
            data: {
              'error': {'code': 'error', 'message': entry.$2},
            },
          ),
        ),
      );

      await expectLater(
        repository.listDays(),
        throwsA(
          isA<TripsApiException>().having(
            (error) => error.message,
            'message',
            entry.$2,
          ),
        ),
      );
      await expectLater(
        repository.listDays(),
        entry.$1 == 409
            ? throwsA(isA<TripsConflictException>())
            : throwsA(isA<TripsValidationException>()),
      );
    }
  });

  test('maps unknown server failures to the generic message', () async {
    final repository = ApiTripsRepository(
      api: _FailingApi(_dioFailure(status: 500, data: {'unexpected': true})),
    );

    await expectLater(
      repository.listDays(),
      throwsA(
        isA<TripsApiException>().having(
          (error) => error.message,
          'message',
          'Что-то пошло не так',
        ),
      ),
    );
  });
}
