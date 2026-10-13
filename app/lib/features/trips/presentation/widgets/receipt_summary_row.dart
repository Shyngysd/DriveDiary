import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class ReceiptSummaryRow extends StatelessWidget {
  const ReceiptSummaryRow({
    required this.label,
    required this.value,
    super.key,
  });

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppTheme.secondaryInk,
              fontFamily: 'JetBrains Mono',
              fontSize: 12,
            ),
          ),
        ),
        value,
      ],
    ),
  );
}
