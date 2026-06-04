// ignore_for_file: prefer_initializing_formals

import 'package:dio/dio.dart';

import '../domain/entities/fuel_entry.dart';
import '../domain/entities/maintenance.dart';
import '../domain/entities/maintenance_category.dart';
import '../domain/entities/vehicle.dart';
import '../domain/repositories/fleet_repository.dart';
import 'firestore_paths.dart';

class FirestoreFleetRepository implements FleetRepository {
  FirestoreFleetRepository({
    required Dio dio,
    required String projectId,
    required String? Function() idTokenReader,
  }) : _dio = dio,
       _projectId = projectId,
       _idTokenReader = idTokenReader;

  final Dio _dio;
  final String _projectId;
  final String? Function() _idTokenReader;

  String get _baseUrl {
    return 'https://firestore.googleapis.com/v1/projects/$_projectId'
        '/databases/(default)/documents';
  }

  @override
  Future<List<Vehicle>> watchVehicles(String ownerId) async {
    final List<Map<String, dynamic>> documents = await _getCollection(
      FirestorePaths.vehicles(ownerId),
    );

    return documents.map((Map<String, dynamic> document) {
      final Map<String, dynamic> fields = _fields(document);
      return Vehicle(
        id: _documentId(document),
        ownerId: ownerId,
        brand: _string(fields, 'brand'),
        model: _string(fields, 'model'),
        plateNumber: _string(fields, 'plateNumber'),
        odometerKm: _int(fields, 'odometerKm'),
      );
    }).toList();
  }

  @override
  Future<List<FuelEntry>> watchFuelEntries(String ownerId) async {
    final List<Map<String, dynamic>> documents = await _getCollection(
      FirestorePaths.fuelEntries(ownerId),
    );

    return documents.map((Map<String, dynamic> document) {
      final Map<String, dynamic> fields = _fields(document);
      return FuelEntry(
        id: _documentId(document),
        ownerId: ownerId,
        vehicleId: _string(fields, 'vehicleId'),
        date: _date(fields, 'date'),
        liters: _double(fields, 'liters'),
        amount: _double(fields, 'amount'),
        odometerKm: _int(fields, 'odometerKm'),
      );
    }).toList();
  }

  @override
  Future<List<Maintenance>> watchMaintenances(String ownerId) async {
    final List<Map<String, dynamic>> documents = await _getCollection(
      FirestorePaths.maintenances(ownerId),
    );

    return documents.map((Map<String, dynamic> document) {
      final Map<String, dynamic> fields = _fields(document);
      return Maintenance(
        id: _documentId(document),
        ownerId: ownerId,
        vehicleId: _string(fields, 'vehicleId'),
        categoryId: _string(fields, 'categoryId'),
        date: _date(fields, 'date'),
        amount: _double(fields, 'amount'),
        description: _string(fields, 'description'),
        odometerKm: _int(fields, 'odometerKm'),
      );
    }).toList();
  }

  @override
  Future<List<MaintenanceCategory>> watchMaintenanceCategories(
    String ownerId,
  ) async {
    final List<Map<String, dynamic>> documents = await _getCollection(
      FirestorePaths.maintenanceCategories(ownerId),
    );

    if (documents.isEmpty) {
      await _seedMaintenanceCategories(ownerId);
      return watchMaintenanceCategories(ownerId);
    }

    return documents.map((Map<String, dynamic> document) {
      final Map<String, dynamic> fields = _fields(document);
      return MaintenanceCategory(
        id: _documentId(document),
        ownerId: ownerId,
        name: _string(fields, 'name'),
      );
    }).toList();
  }

  @override
  Future<void> addVehicle(Vehicle vehicle) {
    return _setDocument(
      '${FirestorePaths.vehicles(vehicle.ownerId)}/${vehicle.id}',
      <String, dynamic>{
        'brand': _stringValue(vehicle.brand),
        'model': _stringValue(vehicle.model),
        'plateNumber': _stringValue(vehicle.plateNumber),
        'odometerKm': _intValue(vehicle.odometerKm),
      },
    );
  }

  @override
  Future<void> addFuelEntry(FuelEntry entry) {
    return _setDocument(
      '${FirestorePaths.fuelEntries(entry.ownerId)}/${entry.id}',
      <String, dynamic>{
        'vehicleId': _stringValue(entry.vehicleId),
        'date': _timestampValue(entry.date),
        'liters': _doubleValue(entry.liters),
        'amount': _doubleValue(entry.amount),
        'odometerKm': _intValue(entry.odometerKm),
      },
    );
  }

  @override
  Future<void> addMaintenance(Maintenance maintenance) {
    return _setDocument(
      '${FirestorePaths.maintenances(maintenance.ownerId)}/${maintenance.id}',
      <String, dynamic>{
        'vehicleId': _stringValue(maintenance.vehicleId),
        'categoryId': _stringValue(maintenance.categoryId),
        'date': _timestampValue(maintenance.date),
        'amount': _doubleValue(maintenance.amount),
        'description': _stringValue(maintenance.description),
        'odometerKm': _intValue(maintenance.odometerKm),
      },
    );
  }

  Future<List<Map<String, dynamic>>> _getCollection(String path) async {
    try {
      final Response<Map<String, dynamic>> response = await _dio
          .get<Map<String, dynamic>>(
            '$_baseUrl/$path',
            options: Options(headers: _headers()),
          );
      final List<dynamic> documents =
          response.data?['documents'] as List<dynamic>? ?? <dynamic>[];
      return documents.cast<Map<String, dynamic>>();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return <Map<String, dynamic>>[];
      }
      rethrow;
    }
  }

  Future<void> _setDocument(String path, Map<String, dynamic> fields) async {
    await _dio.patch<Map<String, dynamic>>(
      '$_baseUrl/$path',
      data: <String, dynamic>{'fields': fields},
      options: Options(headers: _headers()),
    );
  }

  Future<void> _seedMaintenanceCategories(String ownerId) async {
    const List<String> names = <String>['Vidange', 'Pneus', 'Freins', 'Moteur'];

    for (final String name in names) {
      final String id = name.toLowerCase();
      await _setDocument(
        '${FirestorePaths.maintenanceCategories(ownerId)}/$id',
        <String, dynamic>{'name': _stringValue(name)},
      );
    }
  }

  Map<String, String> _headers() {
    final String? token = _idTokenReader();
    if (token == null || token == 'demo-token') {
      throw StateError(
        'Firestore REST demande un token Firebase Auth valide. '
        'Configurez FIREBASE_API_KEY avec FIREBASE_PROJECT_ID.',
      );
    }

    return <String, String>{
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }
}

Map<String, dynamic> _fields(Map<String, dynamic> document) {
  return document['fields'] as Map<String, dynamic>? ?? <String, dynamic>{};
}

String _documentId(Map<String, dynamic> document) {
  final String name = document['name'] as String? ?? '';
  return name.split('/').last;
}

String _string(Map<String, dynamic> fields, String key) {
  return fields[key]?['stringValue'] as String? ?? '';
}

int _int(Map<String, dynamic> fields, String key) {
  final Object? value = fields[key]?['integerValue'];
  if (value is int) {
    return value;
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _double(Map<String, dynamic> fields, String key) {
  final Object? value =
      fields[key]?['doubleValue'] ?? fields[key]?['integerValue'];
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime _date(Map<String, dynamic> fields, String key) {
  final String? value = fields[key]?['timestampValue'] as String?;
  return DateTime.tryParse(value ?? '') ?? DateTime.now();
}

Map<String, String> _stringValue(String value) {
  return <String, String>{'stringValue': value};
}

Map<String, String> _intValue(int value) {
  return <String, String>{'integerValue': value.toString()};
}

Map<String, double> _doubleValue(double value) {
  return <String, double>{'doubleValue': value};
}

Map<String, String> _timestampValue(DateTime value) {
  return <String, String>{'timestampValue': value.toUtc().toIso8601String()};
}
