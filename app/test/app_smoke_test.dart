import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app/features/trips/domain/day_summary.dart';
import 'package:app/features/trips/domain/trip.dart';
import 'package:app/features/trips/domain/trips_repository.dart';
import 'package:app/main.dart';

class _SmokeRepository implements TripsRepository {
  @override
  Future<Trip> addTrip(Trip trip) async => trip;

  @override
  Future<DaySummary> getSummary(DateTime date) async => const DaySummary(
        tripsCount: 0,
        revenue: 0,
        commission: 0,
        net: 0,
        cashTotal: 0,
        cardTotal: 0,
      );

  @override
  Future<List<DateTime>> listDays() async => [];

  @override
  Future<List<Trip>> listTrips(DateTime date) async => [];
}

void main() {
  testWidgets('root application builds', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MyApp(repository: _SmokeRepository()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MyApp), findsOneWidget);
  });
}
