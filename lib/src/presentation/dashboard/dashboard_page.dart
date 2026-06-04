import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/app_providers.dart';
import '../../application/fleet_controller.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/entities/vehicle.dart';
import '../shared/empty_state.dart';
import '../shared/money_text.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FleetState fleet = ref.watch(fleetControllerProvider);
    final DashboardSummary summary = ref.watch(dashboardSummaryProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text('Dashboard', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: MediaQuery.sizeOf(context).width > 700 ? 4 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.45,
          children: <Widget>[
            _MetricCard(
              icon: Icons.directions_car,
              label: 'Voitures',
              value: Text('${summary.vehicleCount}'),
            ),
            _MetricCard(
              icon: Icons.local_gas_station,
              label: 'Gasoil mois',
              value: MoneyText(summary.fuelTotal),
            ),
            _MetricCard(
              icon: Icons.build,
              label: 'Maintenance',
              value: MoneyText(summary.maintenanceTotal),
            ),
            _MetricCard(
              icon: Icons.water_drop_outlined,
              label: 'Litres mois',
              value: Text('${summary.monthlyFuelLiters.toStringAsFixed(1)} L'),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _ExpenseSplit(summary: summary),
        const SizedBox(height: 18),
        _SectionCard(
          title: 'Liste des voitures',
          child: fleet.vehicles.isEmpty
              ? const SizedBox(
                  height: 140,
                  child: EmptyState(
                    icon: Icons.directions_car_outlined,
                    message: 'Aucune voiture enregistree',
                  ),
                )
              : Column(
                  children: fleet.vehicles.map((Vehicle vehicle) {
                    return ListTile(
                      leading: const Icon(Icons.directions_car),
                      title: Text(vehicle.label),
                      subtitle: Text(vehicle.plateNumber),
                      trailing: Text('${vehicle.odometerKm} km'),
                    );
                  }).toList(),
                ),
        ),
        const SizedBox(height: 18),
        _SectionCard(
          title: 'Consommation gasoil par vehicule',
          child: Column(
            children: summary.consumptionByVehicle.map((
              VehicleConsumptionSummary item,
            ) {
              return ListTile(
                leading: const Icon(Icons.local_gas_station_outlined),
                title: Text(item.vehicleLabel),
                subtitle: Text('${item.liters.toStringAsFixed(1)} L'),
                trailing: MoneyText(item.amount),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            Text(label),
            DefaultTextStyle.merge(
              style: Theme.of(context).textTheme.titleLarge,
              child: value,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseSplit extends StatelessWidget {
  const _ExpenseSplit({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final int fuelPercent = (summary.fuelRatio * 100).round();
    final int maintenancePercent = (summary.maintenanceRatio * 100).round();

    return _SectionCard(
      title: 'Depenses par mois',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                flex: fuelPercent.clamp(1, 100),
                child: Container(height: 12, color: Colors.teal),
              ),
              Expanded(
                flex: maintenancePercent.clamp(1, 100),
                child: Container(height: 12, color: Colors.deepOrange),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Gasoil: $fuelPercent% - Maintenance: $maintenancePercent%'),
          const SizedBox(height: 6),
          Text('Objectif indicatif: 70% gasoil, 30% maintenance'),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}
