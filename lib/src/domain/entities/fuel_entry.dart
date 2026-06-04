class FuelEntry {
  const FuelEntry({
    required this.id,
    required this.ownerId,
    required this.vehicleId,
    required this.date,
    required this.liters,
    required this.amount,
    required this.odometerKm,
  });

  final String id;
  final String ownerId;
  final String vehicleId;
  final DateTime date;
  final double liters;
  final double amount;
  final int odometerKm;
}
