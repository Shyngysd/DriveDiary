import 'package:flutter/material.dart';

import '../../../../core/format/formatters.dart';
import '../../../../core/format/money_text.dart';
import '../../../../core/theme/app_theme.dart';

class TotalRow extends StatelessWidget {
  const TotalRow({required this.amount, super.key});

  final int amount;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'На руки: ${formatMoneyWithCurrency(amount)}',
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Expanded(
          child: Text(
            'На руки',
            style: TextStyle(
              color: AppTheme.secondaryInk,
              fontFamily: 'JetBrains Mono',
              fontSize: 12,
            ),
          ),
        ),
        MoneyText(
          amount: amount,
          style: AppTheme.receiptMoneyLarge.copyWith(color: AppTheme.ink),
        ),
      ],
    ),
  );
}
