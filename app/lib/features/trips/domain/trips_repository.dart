import 'day_summary.dart';
import 'trip.dart';

abstract interface class TripsRepository {
  Future<List<Trip>> listTrips(DateTime date);

  Future<DaySummary> getSummary(DateTime date);

  Future<List<DateTime>> listDays();

  Future<Trip> addTrip(Trip trip);
}
