class Maintenance {
  const Maintenance({
    required this.id,
    required this.ownerId,
    required this.vehicleId,
    required this.categoryId,
    required this.date,
    required this.amount,
    required this.description,
    required this.odometerKm,
  });

  final String id;
  final String ownerId;
  final String vehicleId;
  final String categoryId;
  final DateTime date;
  final double amount;
  final String description;
  final int odometerKm;
}
