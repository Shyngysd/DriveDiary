import 'package:flutter/foundation.dart';

@immutable
class TripTime {
  const TripTime({required this.local, required this.offset});

  final DateTime local;
  final Duration offset;

  factory TripTime.parse(String value) {
    final match = RegExp(
      r'^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})(?:\.(\d+))?([+-])(\d{2}):(\d{2})$',
    ).firstMatch(value);
    if (match == null) {
      throw FormatException('Date-time must include an explicit offset');
    }
    final fraction = match.group(7);
    final microseconds = fraction == null
        ? 0
        : int.parse(fraction.padRight(6, '0').substring(0, 6));
    final offset = Duration(
      hours: int.parse(match.group(9)!),
      minutes: int.parse(match.group(10)!),
    );
    final signedOffset = match.group(8) == '+' ? offset : -offset;
    return TripTime(
      local: DateTime(
        int.parse(match.group(1)!),
        int.parse(match.group(2)!),
        int.parse(match.group(3)!),
        int.parse(match.group(4)!),
        int.parse(match.group(5)!),
        int.parse(match.group(6)!),
        microseconds ~/ 1000,
        microseconds % 1000,
      ),
      offset: signedOffset,
    );
  }

  String toIsoString() {
    String two(int value) => value.toString().padLeft(2, '0');
    final sign = offset.isNegative ? '-' : '+';
    final absolute = offset.abs();
    final fraction = local.millisecond == 0 && local.microsecond == 0
        ? ''
        : '.${local.millisecond.toString().padLeft(3, '0')}${local.microsecond.toString().padLeft(3, '0')}';
    return '${local.year.toString().padLeft(4, '0')}-${two(local.month)}-'
        '${two(local.day)}T${two(local.hour)}:${two(local.minute)}:${two(local.second)}'
        '$fraction$sign${two(absolute.inHours)}:${two(absolute.inMinutes.remainder(60))}';
  }

  @override
  bool operator ==(Object other) =>
      other is TripTime && other.local == local && other.offset == offset;

  @override
  int get hashCode => Object.hash(local, offset);
}

enum PaymentMethod {
  cash,
  card;

  static PaymentMethod fromJson(String value) {
    return PaymentMethod.values.firstWhere(
      (method) => method.name == value,
      orElse: () => throw FormatException('Unknown payment method: $value'),
    );
  }
}

@immutable
class Trip {
  const Trip({
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
  final int amount;
  final PaymentMethod payment;
  final int commission;

  factory Trip.fromJson(Map<String, dynamic> json) => Trip(
    id: json['id'] as String,
    start: TripTime.parse(json['start'] as String),
    end: TripTime.parse(json['end'] as String),
    amount: json['amount'] as int,
    payment: PaymentMethod.fromJson(json['payment'] as String),
    commission: json['commission'] as int,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'start': start.toIsoString(),
    'end': end.toIsoString(),
    'amount': amount,
    'payment': payment.name,
    'commission': commission,
  };
}
