import 'package:flutter/material.dart';

import '../../../../core/format/formatters.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/trip.dart';

class ReceiptTripRow extends StatelessWidget {
  const ReceiptTripRow({required this.trip, super.key});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final method = trip.payment == PaymentMethod.cash ? 'нал.' : 'карта';
    return Semantics(
      label: '${formatTimeRange(trip)}, $method, ${formatMoney(trip.amount)}',
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${formatTimeRange(trip)} $method',
              style: const TextStyle(
                color: AppTheme.ink,
                fontFamily: 'JetBrains Mono',
                fontSize: 12,
              ),
            ),
          ),
          Text(
            formatMoney(trip.amount),
            style: const TextStyle(
              color: AppTheme.ink,
              fontFamily: 'JetBrains Mono',
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
