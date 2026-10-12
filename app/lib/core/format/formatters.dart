import 'package:app/features/trips/domain/trip.dart';

String formatMoney(int amount) {
  final sign = amount < 0 ? '\u2212' : '';
  final digits = amount.abs().toString();
  final groups = <String>[];
  for (var index = digits.length; index > 0; index -= 3) {
    final start = index - 3 < 0 ? 0 : index - 3;
    groups.insert(0, digits.substring(start, index));
  }
  return '$sign${groups.join('\u00a0')}\u00a0₸';
}

String formatTimeRange(Trip trip) =>
    '${_time(trip.start.local)}–${_time(trip.end.local)}';

String formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';

String _time(DateTime time) =>
    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
