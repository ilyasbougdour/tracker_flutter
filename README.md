Partiel Programmation mobile

# tracker_flutter

Application mobile Flutter de suivi de gasoil et de maintenance SaaS simplifiee,
guidee par une organisation DDDA.

## Pile technologique

- Flutter
- GoRouter
- Riverpod
- Dio

## Structure DDDA

- `lib/src/domain` : entites metier et contrats repositories.
- `lib/src/application` : controllers Riverpod et calculs applicatifs.
- `lib/src/infrastructure` : Auth Firebase REST, configuration Firebase,
  chemins Firestore, repository Firestore REST et repository de test local.
- `lib/src/presentation` : pages, formulaires et widgets UI.

## Collections Firestore

Chaque driver possede ses donnees sous son identifiant :

- `drivers/{driverId}/vehicles`
- `drivers/{driverId}/fuelEntries`
- `drivers/{driverId}/maintenances`
- `drivers/{driverId}/maintenanceCategories`

## Fonctionnalites

- Authentification Driver email/password.
- Ajout et liste des voitures.
- Enregistrement des pleins de gasoil par vehicule.
- Enregistrement des maintenances par vehicule et categorie.
- Historique de maintenance filtrable par vehicule et par date.
- Dashboard avec depenses mensuelles, repartition gasoil/maintenance et
  consommation par vehicule.

## Firebase / Firestore reel

L'application runtime utilise Firebase reel avec le projet `tracker-flutter-119ee`.
La commande principale est :

```powershell
flutter run -d chrome
```

Il reste possible de cibler un autre projet Firebase avec `--dart-define` :

```powershell
flutter run -d chrome --dart-define=FIREBASE_API_KEY=VOTRE_CLE --dart-define=FIREBASE_PROJECT_ID=VOTRE_PROJECT_ID
```

Le repository local en memoire existe uniquement pour les tests automatises.

## Validation

```powershell
flutter analyze
flutter test
```
