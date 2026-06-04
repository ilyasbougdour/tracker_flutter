class VehicleConsumptionSummary {
  const VehicleConsumptionSummary({
    required this.vehicleId,
    required this.vehicleLabel,
    required this.liters,
    required this.amount,
  });

  final String vehicleId;
  final String vehicleLabel;
  final double liters;
  final double amount;
}

class DashboardSummary {
  const DashboardSummary({
    required this.vehicleCount,
    required this.fuelTotal,
    required this.maintenanceTotal,
    required this.monthlyFuelLiters,
    required this.monthlyFuelAmount,
    required this.consumptionByVehicle,
  });

  final int vehicleCount;
  final double fuelTotal;
  final double maintenanceTotal;
  final double monthlyFuelLiters;
  final double monthlyFuelAmount;
  final List<VehicleConsumptionSummary> consumptionByVehicle;

  double get totalExpenses => fuelTotal + maintenanceTotal;

  double get fuelRatio {
    if (totalExpenses == 0) {
      return 0;
    }
    return fuelTotal / totalExpenses;
  }

  double get maintenanceRatio {
    if (totalExpenses == 0) {
      return 0;
    }
    return maintenanceTotal / totalExpenses;
  }
}
