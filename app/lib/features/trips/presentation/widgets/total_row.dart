import 'package:flutter/material.dart';

import '../../../../core/format/formatters.dart';

class TotalRow extends StatelessWidget {
  const TotalRow({required this.amount, super.key});

  final int amount;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'На руки: ${formatMoney(amount)}',
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Expanded(
          child: Text(
            'На руки',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontFamily: 'JetBrains Mono',
              fontSize: 12,
            ),
          ),
        ),
        Text(
          formatMoney(amount),
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontFamily: 'Manrope',
            fontSize: 40,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}
