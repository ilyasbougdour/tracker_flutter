class Vehicle {
  const Vehicle({
    required this.id,
    required this.ownerId,
    required this.brand,
    required this.model,
    required this.plateNumber,
    required this.odometerKm,
  });

  final String id;
  final String ownerId;
  final String brand;
  final String model;
  final String plateNumber;
  final int odometerKm;

  String get label => '$brand $model';

  Vehicle copyWith({
    String? id,
    String? ownerId,
    String? brand,
    String? model,
    String? plateNumber,
    int? odometerKm,
  }) {
    return Vehicle(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      plateNumber: plateNumber ?? this.plateNumber,
      odometerKm: odometerKm ?? this.odometerKm,
    );
  }
}
