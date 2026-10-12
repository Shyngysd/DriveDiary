import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/features/trips/domain/day_summary.dart';
import 'package:app/features/trips/domain/trip.dart';
import 'package:app/features/trips/domain/trips_repository.dart';
import 'package:app/features/trips/presentation/trips_controller.dart';

class FakeTripsRepository implements TripsRepository {
  FakeTripsRepository(this.days);

  final List<DateTime> days;
  final Map<DateTime, List<Trip>> trips = {};
  final Map<DateTime, DaySummary> summaries = {};
  final List<DateTime> loadedDates = [];

  @override
  Future<Trip> addTrip(Trip trip) async {
    final date = _date(trip.start.local);
    trips.putIfAbsent(date, () => []).add(trip);
    return trip;
  }

  @override
  Future<DaySummary> getSummary(DateTime date) async {
    loadedDates.add(_date(date));
    return summaries[_date(date)] ??
        const DaySummary(
          tripsCount: 0,
          revenue: 0,
          commission: 0,
          net: 0,
          cashTotal: 0,
          cardTotal: 0,
        );
  }

  @override
  Future<List<DateTime>> listDays() async => days;

  @override
  Future<List<Trip>> listTrips(DateTime date) async {
    loadedDates.add(_date(date));
    return trips[_date(date)] ?? [];
  }

  DateTime _date(DateTime date) => DateTime(date.year, date.month, date.day);
}

Trip sampleTrip(DateTime date) => Trip(
  id: 't1',
  start: TripTime(
    local: DateTime(date.year, date.month, date.day, 8),
    offset: const Duration(hours: 5),
  ),
  end: TripTime(
    local: DateTime(date.year, date.month, date.day, 8, 20),
    offset: const Duration(hours: 5),
  ),
  amount: 1000,
  payment: PaymentMethod.cash,
  commission: 100,
);

void main() {
  test(
    'initially selects the last server day and loads data in parallel',
    () async {
      final repository = FakeTripsRepository([
        DateTime(2026, 10, 1),
        DateTime(2026, 10, 4),
      ]);
      final container = ProviderContainer(
        overrides: [tripsRepositoryProvider.overrideWithValue(repository)],
      );
      container.read(tripsControllerProvider.notifier);

      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(container.read(tripsControllerProvider).status, TripsStatus.data);
      expect(
        container.read(tripsControllerProvider).selectedDate,
        DateTime(2026, 10, 4),
      );
      expect(repository.loadedDates, contains(DateTime(2026, 10, 4)));
      container.dispose();
    },
  );

  test('switches days and supports previous and next navigation', () async {
    final repository = FakeTripsRepository([DateTime(2026, 10, 4)]);
    final container = ProviderContainer(
      overrides: [tripsRepositoryProvider.overrideWithValue(repository)],
    );
    final controller = container.read(tripsControllerProvider.notifier);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    await controller.goToPreviousDay();
    expect(
      container.read(tripsControllerProvider).selectedDate,
      DateTime(2026, 10, 3),
    );
    await controller.goToNextDay();
    expect(
      container.read(tripsControllerProvider).selectedDate,
      DateTime(2026, 10, 4),
    );
    await controller.selectDate(DateTime(2026, 10, 6, 18));
    expect(
      container.read(tripsControllerProvider).selectedDate,
      DateTime(2026, 10, 6),
    );
    container.dispose();
  });
}
