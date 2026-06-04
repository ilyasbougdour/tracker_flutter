import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_flutter/src/app/tracker_app.dart';

void main() {
  testWidgets('login driver puis ajout de vehicule', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: TrackerApp()));

    expect(find.text('Connexion Driver'), findsOneWidget);

    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Renault Clio'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.directions_car_outlined));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Marque'),
      'Ford',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Modele'),
      'Focus',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Matricule'),
      '9999-C-6',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Kilometrage'),
      '42000',
    );

    await tester.tap(find.text('Ajouter'));
    await tester.pumpAndSettle();

    expect(find.text('Ford Focus'), findsOneWidget);
    expect(find.text('Voiture ajoutee'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.build_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Tous les vehicules'), findsOneWidget);
    expect(find.textContaining('Renault Clio - Vidange'), findsOneWidget);

    await tester.tap(find.text('Tous les vehicules'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dacia Logan').last);
    await tester.pumpAndSettle();

    expect(find.text('Aucune maintenance trouvee'), findsOneWidget);
  });
}
