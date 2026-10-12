import 'trip.dart';

class TripDraft {
  const TripDraft({
    required this.id,
    required this.start,
    required this.end,
    required this.amount,
    required this.payment,
    required this.commission,
  });

  final String id;
  final TripTime start;
  final TripTime end;
  final int? amount;
  final PaymentMethod payment;
  final int? commission;

  Map<String, String> validate() {
    final errors = <String, String>{};
    if (amount == null || amount! <= 0) {
      errors['amount'] = 'Сумма должна быть больше нуля';
    }
    if (!end.local.isAfter(start.local)) {
      errors['end'] = 'Конец должен быть позже начала';
    }
    if (commission == null || commission! < 0) {
      errors['commission'] = 'Комиссия не может быть отрицательной';
    } else if (amount != null && commission! > amount!) {
      errors['commission'] = 'Комиссия не может быть больше суммы';
    }
    return errors;
  }

  Trip toTrip() {
    final errors = validate();
    if (errors.isNotEmpty) {
      throw StateError(errors.values.first);
    }
    return Trip(
      id: id,
      start: start,
      end: end,
      amount: amount!,
      payment: payment,
      commission: commission!,
    );
  }
}
