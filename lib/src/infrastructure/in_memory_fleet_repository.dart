import 'package:uuid/uuid.dart';

import '../domain/entities/fuel_entry.dart';
import '../domain/entities/maintenance.dart';
import '../domain/entities/maintenance_category.dart';
import '../domain/entities/vehicle.dart';
import '../domain/repositories/fleet_repository.dart';

class InMemoryFleetRepository implements FleetRepository {
  InMemoryFleetRepository() {
    _seedDemoData('driver_esisa_demo');
  }

  final Uuid _uuid = const Uuid();
  final List<Vehicle> _vehicles = <Vehicle>[];
  final List<FuelEntry> _fuelEntries = <FuelEntry>[];
  final List<Maintenance> _maintenances = <Maintenance>[];
  final List<MaintenanceCategory> _categories = <MaintenanceCategory>[];

  @override
  Future<List<Vehicle>> watchVehicles(String ownerId) async {
    return _vehicles.where((Vehicle item) => item.ownerId == ownerId).toList();
  }

  @override
  Future<List<FuelEntry>> watchFuelEntries(String ownerId) async {
    return _fuelEntries
        .where((FuelEntry item) => item.ownerId == ownerId)
        .toList();
  }

  @override
  Future<List<Maintenance>> watchMaintenances(String ownerId) async {
    return _maintenances
        .where((Maintenance item) => item.ownerId == ownerId)
        .toList();
  }

  @override
  Future<List<MaintenanceCategory>> watchMaintenanceCategories(
    String ownerId,
  ) async {
    final List<MaintenanceCategory> ownerCategories = _categories
        .where((MaintenanceCategory item) => item.ownerId == ownerId)
        .toList();

    if (ownerCategories.isEmpty) {
      _seedCategories(ownerId);
      return _categories
          .where((MaintenanceCategory item) => item.ownerId == ownerId)
          .toList();
    }

    return ownerCategories;
  }

  @override
  Future<void> addVehicle(Vehicle vehicle) async {
    _vehicles.add(vehicle);
  }

  @override
  Future<void> addFuelEntry(FuelEntry entry) async {
    _fuelEntries.add(entry);
  }

  @override
  Future<void> addMaintenance(Maintenance maintenance) async {
    _maintenances.add(maintenance);
  }

  String newId() => _uuid.v4();

  void _seedCategories(String ownerId) {
    _categories.addAll(<MaintenanceCategory>[
      MaintenanceCategory(id: _uuid.v4(), ownerId: ownerId, name: 'Vidange'),
      MaintenanceCategory(id: _uuid.v4(), ownerId: ownerId, name: 'Pneus'),
      MaintenanceCategory(id: _uuid.v4(), ownerId: ownerId, name: 'Freins'),
      MaintenanceCategory(id: _uuid.v4(), ownerId: ownerId, name: 'Moteur'),
    ]);
  }

  void _seedDemoData(String ownerId) {
    _seedCategories(ownerId);
    final Vehicle clio = Vehicle(
      id: _uuid.v4(),
      ownerId: ownerId,
      brand: 'Renault',
      model: 'Clio',
      plateNumber: '1234-A-6',
      odometerKm: 86200,
    );
    final Vehicle dacia = Vehicle(
      id: _uuid.v4(),
      ownerId: ownerId,
      brand: 'Dacia',
      model: 'Logan',
      plateNumber: '7788-B-6',
      odometerKm: 123400,
    );
    _vehicles.addAll(<Vehicle>[clio, dacia]);

    _fuelEntries.addAll(<FuelEntry>[
      FuelEntry(
        id: _uuid.v4(),
        ownerId: ownerId,
        vehicleId: clio.id,
        date: DateTime(2026, 6, 2),
        liters: 38,
        amount: 470,
        odometerKm: 86010,
      ),
      FuelEntry(
        id: _uuid.v4(),
        ownerId: ownerId,
        vehicleId: dacia.id,
        date: DateTime(2026, 6, 3),
        liters: 44,
        amount: 540,
        odometerKm: 123100,
      ),
    ]);

    _maintenances.add(
      Maintenance(
        id: _uuid.v4(),
        ownerId: ownerId,
        vehicleId: clio.id,
        categoryId: _categories.first.id,
        date: DateTime(2026, 6, 1),
        amount: 300,
        description: 'Vidange 10W40',
        odometerKm: 85800,
      ),
    );
  }
}
