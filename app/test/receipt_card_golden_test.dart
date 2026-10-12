import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

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

Future<void> _loadFonts() async {
  await Future.wait([
    (FontLoader('JetBrains Mono')
          ..addFont(rootBundle.load('assets/fonts/JetBrainsMono-Regular.ttf')))
        .load(),
    (FontLoader(
      'Manrope',
    )..addFont(rootBundle.load('assets/fonts/Manrope-Variable.ttf'))).load(),
    (FontLoader(
      'Noto Sans',
    )..addFont(rootBundle.load('assets/fonts/NotoSans-Regular.ttf'))).load(),
  ]);
}

Widget _fixture(ThemeData theme) => MaterialApp(
  theme: theme,
  home: Scaffold(
    body: SingleChildScrollView(
      child: Center(
        child: SizedBox(
          width: 420,
          child: ReceiptCard(
            date: _date,
            trips: _trips,
            summary: _summary,
            loading: false,
          ),
        ),
      ),
    ),
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(_loadFonts);

  testWidgets('receipt card light golden', (tester) async {
    tester.view
      ..physicalSize = const Size(500, 700)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_fixture(AppTheme.light()));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/receipt_light.png'),
    );
  });

  testWidgets('receipt card dark golden keeps paper and ink colors', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(500, 700)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_fixture(AppTheme.dark()));
    await tester.pumpAndSettle();

    final tripText = tester.widget<Text>(find.text('08:10–08:32 карта'));
    expect(tripText.style?.color, AppTheme.ink);

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/receipt_dark.png'),
    );
  });
}
