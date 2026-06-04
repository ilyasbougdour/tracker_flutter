import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_flutter/src/application/app_providers.dart';
import 'package:tracker_flutter/src/app/tracker_app.dart';
import 'package:tracker_flutter/src/domain/entities/user_session.dart';
import 'package:tracker_flutter/src/domain/repositories/auth_repository.dart';
import 'package:tracker_flutter/src/infrastructure/in_memory_fleet_repository.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  Future<UserSession> signIn({
    required String email,
    required String password,
  }) async {
    return UserSession(
      driverId: 'driver_esisa_demo',
      email: email,
      token: 'test-token',
    );
  }

  @override
  Future<void> signOut() async {}
}

void main() {
  testWidgets('login driver puis ajout de vehicule', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
          fleetRepositoryProvider.overrideWithValue(InMemoryFleetRepository()),
        ],
        child: const TrackerApp(),
      ),
    );

    expect(find.text('Connexion Driver'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'ilyas@esisa.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'password',
    );
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
