import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app/features/trips/domain/day_summary.dart';
import 'package:app/features/trips/domain/trip.dart';
import 'package:app/features/trips/domain/trips_repository.dart';
import 'package:app/features/trips/data/api_exceptions.dart';
import 'package:app/features/trips/presentation/trips_controller.dart';

class _RaceRepository implements TripsRepository {
  final days = [DateTime(2026, 10, 1)];
  final tripsCompleters = <DateTime, Completer<List<Trip>>>{};
  final summaryCompleters = <DateTime, Completer<DaySummary>>{};
  var failDaysOnce = true;

  @override
  Future<Trip> addTrip(Trip trip) => Future.value(trip);

  @override
  Future<DaySummary> getSummary(DateTime date) =>
      (summaryCompleters[_date(date)] ??= Completer<DaySummary>()).future;

  @override
  Future<List<DateTime>> listDays() {
    if (failDaysOnce) {
      failDaysOnce = false;
      return Future.error(
        const TripsApiException(
          'Нет связи с сервером. Проверьте подключение и адрес сервера',
        ),
      );
    }
    return Future.value(days);
  }

  @override
  Future<List<Trip>> listTrips(DateTime date) =>
      (tripsCompleters[_date(date)] ??= Completer<List<Trip>>()).future;

  void complete(DateTime date) {
    final normalized = _date(date);
    tripsCompleters[normalized]!.complete(const []);
    summaryCompleters[normalized]!.complete(
      const DaySummary(
        tripsCount: 0,
        revenue: 0,
        commission: 0,
        net: 0,
        cashTotal: 0,
        cardTotal: 0,
      ),
    );
  }

  DateTime _date(DateTime date) => DateTime(date.year, date.month, date.day);
}

void main() {
  test('stale date responses cannot replace the latest selection', () async {
    final repository = _RaceRepository();
    final container = ProviderContainer(
      overrides: [tripsRepositoryProvider.overrideWithValue(repository)],
    );
    final controller = container.read(tripsControllerProvider.notifier);
    await Future<void>.delayed(Duration.zero);

    final first = controller.selectDate(DateTime(2026, 10, 2));
    final second = controller.selectDate(DateTime(2026, 10, 3));
    repository.complete(DateTime(2026, 10, 3));
    await Future<void>.delayed(Duration.zero);
    repository.complete(DateTime(2026, 10, 2));
    await Future.wait([first, second]);

    expect(
      container.read(tripsControllerProvider).selectedDate,
      DateTime(2026, 10, 3),
    );
    container.dispose();
  });

  test('loadInitial can be retried after GET /days fails', () async {
    final repository = _RaceRepository();
    final container = ProviderContainer(
      overrides: [tripsRepositoryProvider.overrideWithValue(repository)],
    );
    final controller = container.read(tripsControllerProvider.notifier);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(tripsControllerProvider).status, TripsStatus.error);

    final retry = controller.loadInitial();
    await Future<void>.delayed(Duration.zero);
    repository.complete(DateTime(2026, 10, 1));
    await retry;

    expect(container.read(tripsControllerProvider).status, TripsStatus.data);
    expect(
      container.read(tripsControllerProvider).selectedDate,
      DateTime(2026, 10, 1),
    );
    container.dispose();
  });
}
