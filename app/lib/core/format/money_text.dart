import 'package:flutter/material.dart';

import 'formatters.dart';

class MoneyText extends StatelessWidget {
  const MoneyText({
    required this.amount,
    required this.style,
    super.key,
  });

  final int amount;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final currencyStyle = style.copyWith(
      fontFamily: 'Noto Sans',
      fontWeight: style.fontWeight == FontWeight.w800
          ? FontWeight.w700
          : FontWeight.w400,
    );
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: formatMoney(amount), style: style),
          TextSpan(text: '\u00a0₸', style: currencyStyle),
        ],
      ),
    );
  }
}
