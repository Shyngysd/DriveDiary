import 'package:flutter_test/flutter_test.dart';

import 'package:app/features/trips/domain/trip.dart';
import 'package:app/features/trips/domain/trip_draft.dart';

TripDraft draft({
  int? amount = 1000,
  int? commission = 100,
  DateTime? start,
  DateTime? end,
}) {
  final startLocal = start ?? DateTime(2026, 10, 1, 8);
  final endLocal = end ?? DateTime(2026, 10, 1, 8, 20);
  return TripDraft(
    id: 'draft',
    start: TripTime(local: startLocal, offset: const Duration(hours: 5)),
    end: TripTime(local: endLocal, offset: const Duration(hours: 5)),
    amount: amount,
    payment: PaymentMethod.cash,
    commission: commission,
  );
}

void main() {
  test('TripDraft validates and builds Trip', () {
    final trip = draft().toTrip();

    expect(trip.id, 'draft');
    expect(trip.amount, 1000);
    expect(
      draft(amount: 0).validate()['amount'],
      'Сумма должна быть больше нуля',
    );
    expect(
      draft(commission: 1001).validate()['commission'],
      'Комиссия не может быть больше суммы',
    );
  });

  test('TripDraft validates end before start', () {
    final errors = draft(
      start: DateTime(2026, 10, 1, 9),
      end: DateTime(2026, 10, 1, 8),
    ).validate();

    expect(errors['end'], 'Конец должен быть позже начала');
  });
}
