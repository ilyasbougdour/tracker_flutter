class FirestorePaths {
  const FirestorePaths._();

  static String driver(String ownerId) => 'drivers/$ownerId';

  static String vehicles(String ownerId) => '${driver(ownerId)}/vehicles';

  static String fuelEntries(String ownerId) => '${driver(ownerId)}/fuelEntries';

  static String maintenances(String ownerId) =>
      '${driver(ownerId)}/maintenances';

  static String maintenanceCategories(String ownerId) {
    return '${driver(ownerId)}/maintenanceCategories';
  }
}
