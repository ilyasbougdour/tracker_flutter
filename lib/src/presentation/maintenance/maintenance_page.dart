import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../application/app_providers.dart';
import '../../application/fleet_controller.dart';
import '../../domain/entities/maintenance.dart';
import '../../domain/entities/maintenance_category.dart';
import '../../domain/entities/vehicle.dart';
import '../shared/empty_state.dart';
import '../shared/money_text.dart';

class MaintenancePage extends ConsumerStatefulWidget {
  const MaintenancePage({super.key});

  @override
  ConsumerState<MaintenancePage> createState() => _MaintenancePageState();
}

class _MaintenancePageState extends ConsumerState<MaintenancePage> {
  String? _filterVehicleId;
  DateTime? _filterDate;

  Future<void> _showMaintenanceDialog(BuildContext context) async {
    final FleetState fleet = ref.read(fleetControllerProvider);
    if (fleet.vehicles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ajoutez une voiture avant la maintenance'),
        ),
      );
      return;
    }

    String vehicleId = fleet.vehicles.first.id;
    String categoryId = fleet.categories.first.id;
    final TextEditingController amountController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController odometerController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Operation maintenance'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setDialogState) {
              return SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      DropdownButtonFormField<String>(
                        initialValue: vehicleId,
                        decoration: const InputDecoration(
                          labelText: 'Voiture',
                          prefixIcon: Icon(Icons.directions_car_outlined),
                        ),
                        items: fleet.vehicles.map((Vehicle vehicle) {
                          return DropdownMenuItem<String>(
                            value: vehicle.id,
                            child: Text(vehicle.label),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          setDialogState(() {
                            vehicleId = value ?? vehicleId;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: categoryId,
                        decoration: const InputDecoration(
                          labelText: 'Categorie',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        items: fleet.categories.map((
                          MaintenanceCategory category,
                        ) {
                          return DropdownMenuItem<String>(
                            value: category.id,
                            child: Text(category.name),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          setDialogState(() {
                            categoryId = value ?? categoryId;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          prefixIcon: Icon(Icons.description_outlined),
                        ),
                        validator: _required,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Montant',
                          prefixIcon: Icon(Icons.payments_outlined),
                        ),
                        validator: _positiveDouble,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: odometerController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Kilometrage',
                          prefixIcon: Icon(Icons.speed_outlined),
                        ),
                        validator: _positiveInt,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            FilledButton.icon(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context, true);
                }
              },
              icon: const Icon(Icons.save),
              label: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await ref
          .read(fleetControllerProvider.notifier)
          .addMaintenance(
            vehicleId: vehicleId,
            categoryId: categoryId,
            date: DateTime.now(),
            amount: double.parse(amountController.text.trim()),
            description: descriptionController.text.trim(),
            odometerKm: int.parse(odometerController.text.trim()),
          );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maintenance enregistree')),
        );
      }
    }
  }

  Future<void> _pickFilterDate() async {
    final DateTime now = DateTime.now();
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _filterDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
    );

    if (date != null) {
      setState(() {
        _filterDate = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final FleetState fleet = ref.watch(fleetControllerProvider);
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
    final List<Maintenance> items = fleet.maintenances.where((
      Maintenance maintenance,
    ) {
      final bool vehicleMatches =
          _filterVehicleId == null || maintenance.vehicleId == _filterVehicleId;
      final bool dateMatches =
          _filterDate == null ||
          maintenance.date.year == _filterDate!.year &&
              maintenance.date.month == _filterDate!.month &&
              maintenance.date.day == _filterDate!.day;

      return vehicleMatches && dateMatches;
    }).toList();

    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: <Widget>[
                DropdownButtonFormField<String>(
                  initialValue: _filterVehicleId ?? 'all',
                  decoration: const InputDecoration(
                    labelText: 'Filtrer par vehicule',
                    prefixIcon: Icon(Icons.directions_car_outlined),
                  ),
                  items: <DropdownMenuItem<String>>[
                    const DropdownMenuItem<String>(
                      value: 'all',
                      child: Text('Tous les vehicules'),
                    ),
                    ...fleet.vehicles.map((Vehicle vehicle) {
                      return DropdownMenuItem<String>(
                        value: vehicle.id,
                        child: Text(vehicle.label),
                      );
                    }),
                  ],
                  onChanged: (String? value) {
                    setState(() {
                      _filterVehicleId = value == 'all' ? null : value;
                    });
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickFilterDate,
                        icon: const Icon(Icons.filter_alt_outlined),
                        label: Text(
                          _filterDate == null
                              ? 'Filtrer par date'
                              : dateFormat.format(_filterDate!),
                        ),
                      ),
                    ),
                    if (_filterDate != null) ...<Widget>[
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: 'Retirer filtre date',
                        onPressed: () {
                          setState(() {
                            _filterDate = null;
                          });
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ],
                ),
                if (_filterVehicleId != null ||
                    _filterDate != null) ...<Widget>[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _filterVehicleId = null;
                          _filterDate = null;
                        });
                      },
                      icon: const Icon(Icons.filter_alt_off_outlined),
                      label: const Text('Reinitialiser les filtres'),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? const EmptyState(
                    icon: Icons.build_outlined,
                    message: 'Aucune maintenance trouvee',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    itemCount: items.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(height: 8);
                    },
                    itemBuilder: (BuildContext context, int index) {
                      final Maintenance maintenance = items[index];
                      final Vehicle vehicle = fleet.vehicles.firstWhere(
                        (Vehicle vehicle) =>
                            vehicle.id == maintenance.vehicleId,
                      );
                      final MaintenanceCategory category = fleet.categories
                          .firstWhere((MaintenanceCategory category) {
                            return category.id == maintenance.categoryId;
                          });

                      return Card(
                        child: ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.build)),
                          title: Text('${vehicle.label} - ${category.name}'),
                          subtitle: Text(
                            '${dateFormat.format(maintenance.date)} - '
                            '${maintenance.description} - '
                            '${maintenance.odometerKm} km',
                          ),
                          trailing: MoneyText(maintenance.amount),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMaintenanceDialog(context),
        tooltip: 'Ajouter maintenance',
        child: const Icon(Icons.add),
      ),
    );
  }
}

String? _required(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Champ obligatoire';
  }
  return null;
}

String? _positiveDouble(String? value) {
  final double? number = double.tryParse(value ?? '');
  if (number == null || number <= 0) {
    return 'Nombre invalide';
  }
  return null;
}

String? _positiveInt(String? value) {
  final int? number = int.tryParse(value ?? '');
  if (number == null || number < 0) {
    return 'Nombre invalide';
  }
  return null;
}
