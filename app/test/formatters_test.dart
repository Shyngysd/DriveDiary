import 'package:flutter_test/flutter_test.dart';

import 'package:app/core/format/formatters.dart';
import 'package:app/features/trips/domain/trip.dart';

void main() {
  test('formats money with non-breaking spaces and real minus', () {
    expect(formatMoney(2400), '2\u00a0400');
    expect(formatMoney(-585), '\u2212585');
    expect(formatMoneyWithCurrency(0), '0\u00a0₸');
  });

  test('formats trip local time range', () {
    final trip = Trip(
      id: 'test',
      start: TripTime.parse('2026-10-01T08:10:00+05:00'),
      end: TripTime.parse('2026-10-01T08:32:00+05:00'),
      amount: 1,
      payment: PaymentMethod.cash,
      commission: 0,
    );
    expect(formatTimeRange(trip), '08:10–08:32');
  });
}
