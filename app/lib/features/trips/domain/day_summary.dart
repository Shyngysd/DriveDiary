import 'package:flutter/foundation.dart';

@immutable
class DaySummary {
  const DaySummary({
    required this.tripsCount,
    required this.revenue,
    required this.commission,
    required this.net,
    required this.cashTotal,
    required this.cardTotal,
  });

  final int tripsCount;
  final int revenue;
  final int commission;
  final int net;
  final int cashTotal;
  final int cardTotal;

  factory DaySummary.fromJson(Map<String, dynamic> json) => DaySummary(
    tripsCount: json['trips_count'] as int,
    revenue: json['revenue'] as int,
    commission: json['commission'] as int,
    net: json['net'] as int,
    cashTotal: json['cash_total'] as int,
    cardTotal: json['card_total'] as int,
  );
}
