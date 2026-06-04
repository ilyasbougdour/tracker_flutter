import '../entities/fuel_entry.dart';
import '../entities/maintenance.dart';
import '../entities/maintenance_category.dart';
import '../entities/vehicle.dart';

abstract class FleetRepository {
  Future<List<Vehicle>> watchVehicles(String ownerId);

  Future<List<FuelEntry>> watchFuelEntries(String ownerId);

  Future<List<Maintenance>> watchMaintenances(String ownerId);

  Future<List<MaintenanceCategory>> watchMaintenanceCategories(String ownerId);

  Future<void> addVehicle(Vehicle vehicle);

  Future<void> addFuelEntry(FuelEntry entry);

  Future<void> addMaintenance(Maintenance maintenance);
}
