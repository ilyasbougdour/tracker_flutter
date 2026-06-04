import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../application/app_providers.dart';
import '../../application/fleet_controller.dart';
import '../../domain/entities/fuel_entry.dart';
import '../../domain/entities/vehicle.dart';
import '../shared/empty_state.dart';
import '../shared/money_text.dart';

class FuelPage extends ConsumerWidget {
  const FuelPage({super.key});

  Future<void> _showFuelDialog(BuildContext context, WidgetRef ref) async {
    final FleetState fleet = ref.read(fleetControllerProvider);
    if (fleet.vehicles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajoutez une voiture avant un plein')),
      );
      return;
    }

    String vehicleId = fleet.vehicles.first.id;
    final TextEditingController litersController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    final TextEditingController odometerController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enregistrer plein'),
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
                      TextFormField(
                        controller: litersController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Litres',
                          prefixIcon: Icon(Icons.water_drop_outlined),
                        ),
                        validator: _positiveDouble,
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
          .addFuelEntry(
            vehicleId: vehicleId,
            date: DateTime.now(),
            liters: double.parse(litersController.text.trim()),
            amount: double.parse(amountController.text.trim()),
            odometerKm: int.parse(odometerController.text.trim()),
          );

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Plein enregistre')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FleetState fleet = ref.watch(fleetControllerProvider);
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      body: fleet.fuelEntries.isEmpty
          ? const EmptyState(
              icon: Icons.local_gas_station_outlined,
              message: 'Aucun plein de carburant enregistre',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: fleet.fuelEntries.length,
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(height: 8);
              },
              itemBuilder: (BuildContext context, int index) {
                final FuelEntry entry = fleet.fuelEntries[index];
                final Vehicle vehicle = fleet.vehicles.firstWhere(
                  (Vehicle vehicle) => vehicle.id == entry.vehicleId,
                );

                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.local_gas_station),
                    ),
                    title: Text(vehicle.label),
                    subtitle: Text(
                      '${dateFormat.format(entry.date)} - '
                      '${entry.liters.toStringAsFixed(1)} L - '
                      '${entry.odometerKm} km',
                    ),
                    trailing: MoneyText(entry.amount),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFuelDialog(context, ref),
        tooltip: 'Ajouter plein',
        child: const Icon(Icons.add),
      ),
    );
  }
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
