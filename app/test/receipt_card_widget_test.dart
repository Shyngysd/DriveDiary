import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/core/format/money_text.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/trips/domain/day_summary.dart';
import 'package:app/features/trips/domain/trip.dart';
import 'package:app/features/trips/presentation/widgets/receipt_card.dart';

final _date = DateTime(2026, 10, 1);
final _trips = [
  Trip(
    id: 't1',
    start: TripTime.parse('2026-10-01T08:10:00+05:00'),
    end: TripTime.parse('2026-10-01T08:32:00+05:00'),
    amount: 2400,
    payment: PaymentMethod.card,
    commission: 360,
  ),
  Trip(
    id: 't2',
    start: TripTime.parse('2026-10-01T09:05:00+05:00'),
    end: TripTime.parse('2026-10-01T09:20:00+05:00'),
    amount: 1500,
    payment: PaymentMethod.cash,
    commission: 225,
  ),
];

const _summary = DaySummary(
  tripsCount: 2,
  revenue: 3900,
  commission: 585,
  net: 3315,
  cashTotal: 1500,
  cardTotal: 2400,
);

Widget _fixture(ThemeData theme) => MaterialApp(
  theme: theme,
  home: Scaffold(
    body: ReceiptCard(
      date: _date,
      trips: _trips,
      summary: _summary,
      loading: false,
    ),
  ),
);

void main() {
  testWidgets('light receipt keeps totals and ink colors', (tester) async {
    await tester.pumpWidget(_fixture(AppTheme.light()));

    final richTexts = tester
        .widgetList<RichText>(find.byType(RichText))
        .map((widget) => widget.text.toPlainText())
        .toList();
    expect(richTexts, contains('3 315 ₸'));
    expect(richTexts, contains('1 500 ₸'));
    expect(richTexts, contains('2 400 ₸'));
    expect(richTexts, contains('−585 ₸'));
    expect(
      tester.widget<Text>(find.text('08:10–08:32 карта')).style?.color,
      AppTheme.ink,
    );
  });

  testWidgets('MoneyText uses Noto Sans for the currency glyph', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MoneyText(
          amount: 3315,
          style: TextStyle(fontFamily: 'Manrope', fontSize: 40),
        ),
      ),
    );

    final richText = tester.widget<RichText>(find.byType(RichText));
    final spans = richText.text as TextSpan;
    final moneySpan = spans.children!.single as TextSpan;
    final currencySpan = moneySpan.children![1] as TextSpan;
    expect(currencySpan.text, ' ₸');
    expect(currencySpan.style?.fontFamily, 'Noto Sans');
  });

  testWidgets('dark receipt keeps paper and ink colors', (tester) async {
    await tester.pumpWidget(_fixture(AppTheme.dark()));

    expect(
      tester.widget<Text>(find.text('08:10–08:32 карта')).style?.color,
      AppTheme.ink,
    );
    expect(
      tester.widget<Text>(find.text('Поездок')).style?.color,
      AppTheme.secondaryInk,
    );
  });
}
