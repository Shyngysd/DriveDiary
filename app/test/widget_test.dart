import 'package:flutter_test/flutter_test.dart';

import 'package:app/features/trips/domain/day_summary.dart';
import 'package:app/features/trips/domain/trip.dart';
import 'package:app/features/trips/domain/trips_repository.dart';
import 'package:app/main.dart';

class _ReferenceRepository implements TripsRepository {
  final _date = DateTime(2026, 10, 1);
  final _trips = [
    Trip(
      id: 't1',
      start: TripTime.parse('2026-10-01T08:10:00+05:00'),
      end: TripTime.parse('2026-10-01T08:32:00+05:00'),
      amount: 1500,
      payment: PaymentMethod.cash,
      commission: 225,
    ),
    Trip(
      id: 't2',
      start: TripTime.parse('2026-10-01T09:00:00+05:00'),
      end: TripTime.parse('2026-10-01T09:25:00+05:00'),
      amount: 2400,
      payment: PaymentMethod.card,
      commission: 360,
    ),
  ];

  @override
  Future<Trip> addTrip(Trip trip) async => trip;

  @override
  Future<DaySummary> getSummary(DateTime date) async => const DaySummary(
    tripsCount: 2,
    revenue: 3900,
    commission: 585,
    net: 3315,
    cashTotal: 1500,
    cardTotal: 2400,
  );

  @override
  Future<List<DateTime>> listDays() async => [_date];

  @override
  Future<List<Trip>> listTrips(DateTime date) async => _trips;
}

void main() {
  testWidgets('reference receipt displays totals', (tester) async {
    await tester.pumpWidget(MyApp(repository: _ReferenceRepository()));
    await tester.pumpAndSettle();

    expect(find.text('3 315 ₸'), findsOneWidget);
    expect(find.text('1 500 ₸ / 2 400 ₸'), findsOneWidget);
    expect(find.text('−585 ₸'), findsOneWidget);
  });
}
