import 'package:flutter/material.dart';

import '../../../../core/format/formatters.dart';
import '../../../../core/format/money_text.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/day_summary.dart';
import '../../domain/trip.dart';
import 'dashed_divider.dart';
import 'receipt_summary_row.dart';
import 'receipt_trip_row.dart';
import 'torn_edge_clipper.dart';
import 'total_row.dart';

class ReceiptCard extends StatelessWidget {
  const ReceiptCard({
    required this.date,
    required this.trips,
    required this.summary,
    required this.loading,
    super.key,
  });

  final DateTime date;
  final List<Trip> trips;
  final DaySummary summary;
  final bool loading;

  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: -0.01745,
    child: ClipPath(
      clipper: TornEdgeClipper(),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppTheme.receiptPaper,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 30),
          child: Column(
            children: [
              const Text(
                'Дневник смен',
                style: TextStyle(
                  color: AppTheme.ink,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formatDate(date),
                style: const TextStyle(
                  color: AppTheme.secondaryInk,
                  fontFamily: 'JetBrains Mono',
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),
              if (loading)
                const _SkeletonRows()
              else if (trips.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'Поездок нет',
                    style: TextStyle(
                      color: AppTheme.secondaryInk,
                      fontFamily: 'JetBrains Mono',
                    ),
                  ),
                )
              else
                ...trips.map(
                  (trip) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ReceiptTripRow(trip: trip),
                  ),
                ),
              const DashedDivider(),
              ReceiptSummaryRow(
                label: 'Поездок',
                value: Text(
                  summary.tripsCount.toString(),
                  style: AppTheme.receiptMoney.copyWith(color: AppTheme.ink),
                ),
              ),
              ReceiptSummaryRow(
                label: 'Выручка',
                value: MoneyText(
                  amount: summary.revenue,
                  style: AppTheme.receiptMoney.copyWith(color: AppTheme.ink),
                ),
              ),
              ReceiptSummaryRow(
                label: 'Комиссия',
                value: MoneyText(
                  amount: -summary.commission,
                  style: AppTheme.receiptMoney.copyWith(color: AppTheme.ink),
                ),
              ),
              ReceiptSummaryRow(
                label: 'Наличные / карта',
                value: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MoneyText(
                      amount: summary.cashTotal,
                      style: AppTheme.receiptMoney.copyWith(color: AppTheme.ink),
                    ),
                    const Text(' / '),
                    MoneyText(
                      amount: summary.cardTotal,
                      style: AppTheme.receiptMoney.copyWith(color: AppTheme.ink),
                    ),
                  ],
                ),
              ),
              const DashedDivider(),
              TotalRow(amount: summary.net),
            ],
          ),
        ),
      ),
    ),
  );
}

class _SkeletonRows extends StatelessWidget {
  const _SkeletonRows();

  @override
  Widget build(BuildContext context) => Column(
    children: List.generate(
      4,
      (index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Align(
          alignment: index.isEven
              ? Alignment.centerLeft
              : Alignment.centerRight,
          child: Container(
            height: 12,
            width: index.isEven ? 180 : 100,
            decoration: BoxDecoration(
              color: AppTheme.receiptMutedInk.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    ),
  );
}
