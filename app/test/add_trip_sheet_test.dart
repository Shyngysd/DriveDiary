import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/features/trips/domain/trip.dart';
import 'package:app/features/trips/presentation/widgets/add_trip_sheet.dart';

void main() {
  Future<void> pumpSheet(
    WidgetTester tester, {
    required Future<void> Function(Trip trip) onSave,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => AddTripSheet(
                  selectedDate: DateTime(2026, 10, 1),
                  onSave: onSave,
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows Russian validation for invalid amount', (tester) async {
    var calls = 0;
    await pumpSheet(tester, onSave: (_) async => calls++);

    await tester.enterText(find.byType(TextFormField).first, '0');
    await tester.tap(find.text('Сохранить'));
    await tester.pump();

    expect(find.text('Сумма должна быть больше нуля'), findsOneWidget);
    expect(calls, 0);
  });

  testWidgets('double tapping save sends one request', (tester) async {
    var calls = 0;
    await pumpSheet(
      tester,
      onSave: (_) async {
        calls++;
        await Future<void>.delayed(const Duration(milliseconds: 50));
      },
    );

    await tester.enterText(find.byType(TextFormField).first, '1000');
    await tester.enterText(find.byType(TextFormField).at(1), '100');
    final save = find.text('Сохранить');
    await tester.tap(save);
    await tester.tap(save);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(calls, 1);
  });
}
