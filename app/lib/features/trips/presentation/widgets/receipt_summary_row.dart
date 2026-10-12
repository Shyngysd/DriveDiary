import 'package:flutter/material.dart';

class ReceiptSummaryRow extends StatelessWidget {
  const ReceiptSummaryRow({
    required this.label,
    required this.value,
    super.key,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontFamily: 'JetBrains Mono',
              fontSize: 12,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 12),
        ),
      ],
    ),
  );
}
