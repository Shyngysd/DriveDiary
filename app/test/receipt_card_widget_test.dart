import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/trips/domain/day_summary.dart';
import 'package:app/features/trips/domain/trip.dart';
import 'package:app/features/trips/presentation/widgets/receipt_card.dart';

final _date = DateTime(2026, 10, 1);
final _trips = [
  Trip(
    id: 't1',
    start: TripTime.parse('2026-10-01T08:10:00+05:00'),
    end: TripTime.parse('2026-10-01T08:32:00+05:00'),
    amount: 2400,
    payment: PaymentMethod.card,
    commission: 360,
  ),
  Trip(
    id: 't2',
    start: TripTime.parse('2026-10-01T09:05:00+05:00'),
    end: TripTime.parse('2026-10-01T09:20:00+05:00'),
    amount: 1500,
    payment: PaymentMethod.cash,
    commission: 225,
  ),
];

const _summary = DaySummary(
  tripsCount: 2,
  revenue: 3900,
  commission: 585,
  net: 3315,
  cashTotal: 1500,
  cardTotal: 2400,
);

Widget _fixture(ThemeData theme) => MaterialApp(
  theme: theme,
  home: Scaffold(
    body: ReceiptCard(
      date: _date,
      trips: _trips,
      summary: _summary,
      loading: false,
    ),
  ),
);

void main() {
  testWidgets('light receipt keeps totals and ink colors', (tester) async {
    await tester.pumpWidget(_fixture(AppTheme.light()));

    expect(find.text('3 315 ₸'), findsOneWidget);
    expect(find.text('1 500 ₸ / 2 400 ₸'), findsOneWidget);
    expect(find.text('−585 ₸'), findsOneWidget);
    expect(
      tester.widget<Text>(find.text('08:10–08:32 карта')).style?.color,
      AppTheme.ink,
    );
  });

  testWidgets('dark receipt keeps paper and ink colors', (tester) async {
    await tester.pumpWidget(_fixture(AppTheme.dark()));

    expect(
      tester.widget<Text>(find.text('08:10–08:32 карта')).style?.color,
      AppTheme.ink,
    );
    expect(
      tester.widget<Text>(find.text('Поездок')).style?.color,
      AppTheme.secondaryInk,
    );
  });
}
