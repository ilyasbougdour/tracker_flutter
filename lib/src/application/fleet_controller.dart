import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';

import '../domain/entities/fuel_entry.dart';
import '../domain/entities/maintenance.dart';
import '../domain/entities/maintenance_category.dart';
import '../domain/entities/vehicle.dart';
import '../domain/repositories/fleet_repository.dart';

class FleetState {
  const FleetState({
    this.ownerId,
    this.vehicles = const <Vehicle>[],
    this.fuelEntries = const <FuelEntry>[],
    this.maintenances = const <Maintenance>[],
    this.categories = const <MaintenanceCategory>[],
    this.isLoading = false,
  });

  final String? ownerId;
  final List<Vehicle> vehicles;
  final List<FuelEntry> fuelEntries;
  final List<Maintenance> maintenances;
  final List<MaintenanceCategory> categories;
  final bool isLoading;

  FleetState copyWith({
    String? ownerId,
    List<Vehicle>? vehicles,
    List<FuelEntry>? fuelEntries,
    List<Maintenance>? maintenances,
    List<MaintenanceCategory>? categories,
    bool? isLoading,
  }) {
    return FleetState(
      ownerId: ownerId ?? this.ownerId,
      vehicles: vehicles ?? this.vehicles,
      fuelEntries: fuelEntries ?? this.fuelEntries,
      maintenances: maintenances ?? this.maintenances,
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class FleetController extends StateNotifier<FleetState> {
  FleetController(this._repository) : super(const FleetState());

  final FleetRepository _repository;
  final Uuid _uuid = const Uuid();

  Future<void> loadForOwner(String ownerId) async {
    state = state.copyWith(ownerId: ownerId, isLoading: true);

    final List<Vehicle> vehicles = await _repository.watchVehicles(ownerId);
    final List<FuelEntry> fuelEntries = await _repository.watchFuelEntries(
      ownerId,
    );
    final List<Maintenance> maintenances = await _repository.watchMaintenances(
      ownerId,
    );
    final List<MaintenanceCategory> categories = await _repository
        .watchMaintenanceCategories(ownerId);

    state = FleetState(
      ownerId: ownerId,
      vehicles: vehicles,
      fuelEntries: fuelEntries,
      maintenances: maintenances,
      categories: categories,
    );
  }

  Future<void> addVehicle({
    required String brand,
    required String model,
    required String plateNumber,
    required int odometerKm,
  }) async {
    final String ownerId = _requireOwner();
    final Vehicle vehicle = Vehicle(
      id: _uuid.v4(),
      ownerId: ownerId,
      brand: brand,
      model: model,
      plateNumber: plateNumber,
      odometerKm: odometerKm,
    );

    await _repository.addVehicle(vehicle);
    await loadForOwner(ownerId);
  }

  Future<void> addFuelEntry({
    required String vehicleId,
    required DateTime date,
    required double liters,
    required double amount,
    required int odometerKm,
  }) async {
    final String ownerId = _requireOwner();
    final FuelEntry entry = FuelEntry(
      id: _uuid.v4(),
      ownerId: ownerId,
      vehicleId: vehicleId,
      date: date,
      liters: liters,
      amount: amount,
      odometerKm: odometerKm,
    );

    await _repository.addFuelEntry(entry);
    await loadForOwner(ownerId);
  }

  Future<void> addMaintenance({
    required String vehicleId,
    required String categoryId,
    required DateTime date,
    required double amount,
    required String description,
    required int odometerKm,
  }) async {
    final String ownerId = _requireOwner();
    final Maintenance maintenance = Maintenance(
      id: _uuid.v4(),
      ownerId: ownerId,
      vehicleId: vehicleId,
      categoryId: categoryId,
      date: date,
      amount: amount,
      description: description,
      odometerKm: odometerKm,
    );

    await _repository.addMaintenance(maintenance);
    await loadForOwner(ownerId);
  }

  String _requireOwner() {
    final String? ownerId = state.ownerId;
    if (ownerId == null) {
      throw StateError('Aucun driver connecte');
    }
    return ownerId;
  }
}
