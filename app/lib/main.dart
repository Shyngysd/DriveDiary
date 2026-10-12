import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/trips/domain/day_summary.dart';
import 'features/trips/domain/trips_repository.dart';
import 'features/trips/presentation/trips_controller.dart';
import 'features/trips/presentation/widgets/day_switcher.dart';
import 'features/trips/presentation/widgets/add_trip_sheet.dart';
import 'features/trips/presentation/widgets/receipt_card.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({this.repository, super.key});

  final TripsRepository? repository;

  @override
  Widget build(BuildContext context) => ProviderScope(
    overrides: [
      if (repository != null)
        tripsRepositoryProvider.overrideWithValue(repository!),
    ],
    child: MaterialApp(
      title: 'Дневник смен',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const TripsHomePage(),
    ),
  );
}

class TripsHomePage extends ConsumerWidget {
  const TripsHomePage({super.key});

  static const _emptySummary = DaySummary(
    tripsCount: 0,
    revenue: 0,
    commission: 0,
    net: 0,
    cashTotal: 0,
    cardTotal: 0,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tripsControllerProvider);
    final controller = ref.read(tripsControllerProvider.notifier);
    final summary = state.summary ?? _emptySummary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Дневник смен'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            DaySwitcher(
              date: state.selectedDate,
              onPrevious: controller.goToPreviousDay,
              onNext: controller.goToNextDay,
              onSelect: controller.selectDate,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.loadInitial,
                child: state.status == TripsStatus.error
                    ? _ErrorContent(
                        onRetry: controller.loadInitial,
                        error: state.error,
                      )
                    : _ReceiptViewport(
                        state: state,
                        summary: summary,
                        onSwipeLeft: controller.goToNextDay,
                        onSwipeRight: controller.goToPreviousDay,
                      ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddTripSheet(context, controller),
        icon: const Icon(Icons.add),
        label: const Text('Добавить поездку'),
      ),
    );
  }

  Future<void> _openAddTripSheet(
    BuildContext context,
    TripsController controller,
  ) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFFF8E1),
      builder: (_) => AddTripSheet(
        selectedDate: controller.selectedDate,
        onSave: controller.addTrip,
      ),
    );
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Поездка добавлена')));
    }
  }
}

class _ReceiptViewport extends StatelessWidget {
  const _ReceiptViewport({
    required this.state,
    required this.summary,
    required this.onSwipeLeft,
    required this.onSwipeRight,
  });

  final TripsState state;
  final DaySummary summary;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                final velocity = details.primaryVelocity ?? 0;
                if (velocity < -100) onSwipeLeft();
                if (velocity > 100) onSwipeRight();
              },
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: ReceiptCard(
                  key: ValueKey(state.selectedDate),
                  date: state.selectedDate,
                  trips: state.trips,
                  summary: summary,
                  loading: state.status == TripsStatus.loading,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _ErrorContent extends StatelessWidget {
  const _ErrorContent({required this.onRetry, required this.error});

  final VoidCallback onRetry;
  final Object? error;

  @override
  Widget build(BuildContext context) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.all(32),
    children: [
      const SizedBox(height: 80),
      const Icon(Icons.cloud_off, size: 48),
      const SizedBox(height: 16),
      Text(
        'Не удалось загрузить данные',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      if (error != null)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(error.toString(), textAlign: TextAlign.center),
        ),
      const SizedBox(height: 16),
      Center(
        child: FilledButton(onPressed: onRetry, child: const Text('Повторить')),
      ),
    ],
  );
}
