import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../domain/entities/dashboard_summary.dart';
import '../domain/entities/fuel_entry.dart';
import '../domain/entities/maintenance.dart';
import '../domain/entities/vehicle.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/fleet_repository.dart';
import '../infrastructure/firebase_auth_backend_service.dart';
import '../infrastructure/firebase_auth_repository.dart';
import '../infrastructure/firestore_fleet_repository.dart';
import 'auth_controller.dart';
import 'fleet_controller.dart';

final Provider<Dio> dioProvider = Provider<Dio>((Ref ref) {
  return Dio(BaseOptions(connectTimeout: const Duration(seconds: 10)));
});

final Provider<AuthRepository> authRepositoryProvider =
    Provider<AuthRepository>((Ref ref) {
      return FirebaseAuthRepository(
        FirebaseAuthBackendService(ref.watch(dioProvider)),
      );
    });

final Provider<FleetRepository> fleetRepositoryProvider =
    Provider<FleetRepository>((Ref ref) {
      const String projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
      if (projectId.isEmpty) {
        throw StateError(
          'Firestore non configure. '
          'Ajoutez FIREBASE_PROJECT_ID avec --dart-define.',
        );
      }

      return FirestoreFleetRepository(
        dio: ref.watch(dioProvider),
        projectId: projectId,
        idTokenReader: () => ref.read(authControllerProvider).user?.token,
      );
    });

final StateNotifierProvider<AuthController, AuthState> authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((Ref ref) {
      return AuthController(ref.watch(authRepositoryProvider));
    });

final StateNotifierProvider<FleetController, FleetState>
fleetControllerProvider = StateNotifierProvider<FleetController, FleetState>((
  Ref ref,
) {
  return FleetController(ref.watch(fleetRepositoryProvider));
});

final Provider<DashboardSummary> dashboardSummaryProvider =
    Provider<DashboardSummary>((Ref ref) {
      final FleetState fleet = ref.watch(fleetControllerProvider);
      final DateTime now = DateTime.now();

      final List<FuelEntry> monthlyFuel = fleet.fuelEntries
          .where((FuelEntry item) => _sameMonth(item.date, now))
          .toList();
      final List<Maintenance> monthlyMaintenance = fleet.maintenances
          .where((Maintenance item) => _sameMonth(item.date, now))
          .toList();

      final double fuelTotal = monthlyFuel.fold<double>(
        0,
        (double sum, FuelEntry item) => sum + item.amount,
      );
      final double maintenanceTotal = monthlyMaintenance.fold<double>(
        0,
        (double sum, Maintenance item) => sum + item.amount,
      );
      final double monthlyFuelLiters = monthlyFuel.fold<double>(
        0,
        (double sum, FuelEntry item) => sum + item.liters,
      );

      return DashboardSummary(
        vehicleCount: fleet.vehicles.length,
        fuelTotal: fuelTotal,
        maintenanceTotal: maintenanceTotal,
        monthlyFuelLiters: monthlyFuelLiters,
        monthlyFuelAmount: fuelTotal,
        consumptionByVehicle: _consumptionByVehicle(
          fleet.vehicles,
          monthlyFuel,
        ),
      );
    });

List<VehicleConsumptionSummary> _consumptionByVehicle(
  List<Vehicle> vehicles,
  List<FuelEntry> entries,
) {
  return vehicles.map((Vehicle vehicle) {
    final Iterable<FuelEntry> vehicleEntries = entries.where(
      (FuelEntry entry) => entry.vehicleId == vehicle.id,
    );
    return VehicleConsumptionSummary(
      vehicleId: vehicle.id,
      vehicleLabel: vehicle.label,
      liters: vehicleEntries.fold<double>(
        0,
        (double sum, FuelEntry item) => sum + item.liters,
      ),
      amount: vehicleEntries.fold<double>(
        0,
        (double sum, FuelEntry item) => sum + item.amount,
      ),
    );
  }).toList();
}

bool _sameMonth(DateTime left, DateTime right) {
  return left.year == right.year && left.month == right.month;
}
