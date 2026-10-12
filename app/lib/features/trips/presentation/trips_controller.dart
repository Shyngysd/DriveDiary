import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api_trips_repository.dart';
import '../domain/day_summary.dart';
import '../domain/trip.dart';
import '../domain/trips_repository.dart';

enum TripsStatus { loading, data, error }

class TripsState {
  const TripsState({
    required this.status,
    required this.selectedDate,
    this.trips = const [],
    this.summary,
    this.error,
  });

  factory TripsState.loading(DateTime date) =>
      TripsState(status: TripsStatus.loading, selectedDate: date);

  final TripsStatus status;
  final DateTime selectedDate;
  final List<Trip> trips;
  final DaySummary? summary;
  final Object? error;

  TripsState copyWith({
    TripsStatus? status,
    DateTime? selectedDate,
    List<Trip>? trips,
    DaySummary? summary,
    Object? error,
  }) => TripsState(
    status: status ?? this.status,
    selectedDate: selectedDate ?? this.selectedDate,
    trips: trips ?? this.trips,
    summary: summary ?? this.summary,
    error: error,
  );
}

final tripsRepositoryProvider = Provider<TripsRepository>((ref) {
  return ApiTripsRepository();
});

final tripsControllerProvider = NotifierProvider<TripsController, TripsState>(
  TripsController.new,
);

class TripsController extends Notifier<TripsState> {
  late TripsRepository repository;

  @override
  TripsState build() {
    repository = ref.read(tripsRepositoryProvider);
    final initial = TripsState.loading(_today());
    Future<void>.microtask(loadInitial);
    return initial;
  }

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  Future<void> loadInitial() async {
    state = TripsState.loading(state.selectedDate);
    try {
      final days = await repository.listDays();
      final selected = days.isEmpty
          ? _today()
          : DateTime(days.last.year, days.last.month, days.last.day);
      await _loadDate(selected);
    } catch (error) {
      state = state.copyWith(status: TripsStatus.error, error: error);
    }
  }

  Future<void> selectDate(DateTime date) => _loadDate(_dateOnly(date));

  Future<void> goToPreviousDay() =>
      selectDate(state.selectedDate.subtract(const Duration(days: 1)));

  Future<void> goToNextDay() =>
      selectDate(state.selectedDate.add(const Duration(days: 1)));

  Future<void> addTrip(Trip trip) async {
    await repository.addTrip(trip);
    await _loadDate(state.selectedDate);
  }

  Future<void> _loadDate(DateTime date) async {
    state = TripsState.loading(date);
    try {
      final results = await Future.wait<Object>([
        repository.listTrips(date),
        repository.getSummary(date),
      ]);
      state = TripsState(
        status: TripsStatus.data,
        selectedDate: date,
        trips: results[0] as List<Trip>,
        summary: results[1] as DaySummary,
      );
    } catch (error) {
      state = TripsState(
        status: TripsStatus.error,
        selectedDate: date,
        error: error,
      );
    }
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
