import 'package:flutter_test/flutter_test.dart';

import 'package:app/features/trips/domain/trip.dart';

void main() {
  test('parses and preserves local time and offset', () {
    final time = TripTime.parse('2026-10-01T08:10:00+05:00');

    expect(time.local.hour, 8);
    expect(time.local.minute, 10);
    expect(time.offset, const Duration(hours: 5));
    expect(time.toIsoString(), '2026-10-01T08:10:00+05:00');
  });

  test('serializes trip with explicit offset', () {
    final trip = Trip(
      id: 't1',
      start: TripTime.parse('2026-10-01T08:10:00+05:00'),
      end: TripTime.parse('2026-10-01T08:32:00+05:00'),
      amount: 1500,
      payment: PaymentMethod.cash,
      commission: 225,
    );

    expect(trip.toJson()['start'], '2026-10-01T08:10:00+05:00');
    expect(trip.toJson()['end'], '2026-10-01T08:32:00+05:00');
  });
}
