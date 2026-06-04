import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/app_providers.dart';
import '../../application/fleet_controller.dart';
import '../../domain/entities/vehicle.dart';
import '../shared/empty_state.dart';

class VehiclesPage extends ConsumerWidget {
  const VehiclesPage({super.key});

  Future<void> _showVehicleDialog(BuildContext context, WidgetRef ref) async {
    final TextEditingController brandController = TextEditingController();
    final TextEditingController modelController = TextEditingController();
    final TextEditingController plateController = TextEditingController();
    final TextEditingController odometerController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ajouter voiture'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: brandController,
                    decoration: const InputDecoration(labelText: 'Marque'),
                    validator: _required,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: modelController,
                    decoration: const InputDecoration(labelText: 'Modele'),
                    validator: _required,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: plateController,
                    decoration: const InputDecoration(labelText: 'Matricule'),
                    validator: _required,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: odometerController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Kilometrage'),
                    validator: _positiveInt,
                  ),
                ],
              ),
            ),
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
              icon: const Icon(Icons.add),
              label: const Text('Ajouter'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await ref
            .read(fleetControllerProvider.notifier)
            .addVehicle(
              brand: brandController.text.trim(),
              model: modelController.text.trim(),
              plateNumber: plateController.text.trim(),
              odometerKm: int.parse(odometerController.text.trim()),
            );

        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Voiture ajoutee')));
        }
      } catch (error) {
        if (context.mounted) {
          await showDialog<void>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Erreur ajout voiture'),
                content: Text(_friendlyError(error)),
                actions: <Widget>[
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FleetState fleet = ref.watch(fleetControllerProvider);

    return Scaffold(
      body: fleet.vehicles.isEmpty
          ? const EmptyState(
              icon: Icons.directions_car_outlined,
              message: 'Ajoutez votre premiere voiture',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: fleet.vehicles.length,
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(height: 8);
              },
              itemBuilder: (BuildContext context, int index) {
                final Vehicle vehicle = fleet.vehicles[index];
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.directions_car),
                    ),
                    title: Text(vehicle.label),
                    subtitle: Text(vehicle.plateNumber),
                    trailing: Text('${vehicle.odometerKm} km'),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showVehicleDialog(context, ref),
        tooltip: 'Ajouter voiture',
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

String? _positiveInt(String? value) {
  final int? number = int.tryParse(value ?? '');
  if (number == null || number < 0) {
    return 'Nombre invalide';
  }
  return null;
}

String _friendlyError(Object error) {
  final String message = error.toString();
  if (message.contains('PERMISSION_DENIED')) {
    return 'Firestore refuse l\'ecriture. Verifiez les regles et que '
        'request.auth.uid correspond au dossier drivers/{uid}.';
  }
  if (message.contains('NETWORK') || message.contains('XMLHttpRequest')) {
    return 'Erreur reseau Firebase. Verifiez la connexion et la configuration.';
  }
  return message;
}
