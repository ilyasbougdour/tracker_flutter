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
- `lib/src/infrastructure` : Auth Firebase REST, chemins Firestore,
  repository Firestore REST et repository demo local.
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

## Firebase / Firestore

Mode demo local :

```powershell
flutter run
```

Mode Firebase Auth + Firestore REST :

```powershell
flutter run --dart-define=FIREBASE_API_KEY=VOTRE_CLE --dart-define=FIREBASE_PROJECT_ID=VOTRE_PROJECT_ID
```

## Validation

```powershell
flutter analyze
flutter test
```
