# tracker_flutter

Application mobile Flutter de suivi de gasoil et de maintenance SaaS simplifiee,
guidee par une organisation DDDA.

## Objectif examen

Mettre en place une application mobile pour un client `Driver` avec :

- authentification email/password via un service backend Firebase Auth ;
- donnees separees par client ;
- gestion des voitures ;
- enregistrement des pleins de carburant par voiture ;
- enregistrement des operations de maintenance par voiture ;
- dashboard flexible.

## Pile technologique

- Flutter
- GoRouter
- Riverpod
- Dio

## Structure DDDA

- `lib/src/domain` : entites metier et contrats repositories.
- `lib/src/application` : controllers Riverpod et calculs applicatifs.
- `lib/src/infrastructure` : implementation Auth/Fleet et chemins Firestore.
- `lib/src/presentation` : pages, formulaires et widgets UI.

## Collections metier

Chaque client possede ses donnees sous son identifiant driver :

- `drivers/{driverId}/vehicles`
- `drivers/{driverId}/fuelEntries`
- `drivers/{driverId}/maintenances`
- `drivers/{driverId}/maintenanceCategories`

## Fonctionnalites livrees

- Connexion Driver par email/password.
- Ajout de vehicule.
- Liste des voitures.
- Enregistrement des pleins de gasoil par vehicule.
- Enregistrement des maintenances par vehicule et categorie.
- Historique de maintenance avec filtrage par date.
- Dashboard :
  - depenses mensuelles gasoil/maintenance ;
  - repartition gasoil vs maintenance ;
  - consommation gasoil du mois en litres et montant par vehicule.

## Firebase

Le service `FirebaseAuthBackendService` utilise Dio et peut appeler Firebase
Auth REST si `FIREBASE_API_KEY` est fourni au build :

```powershell
flutter run --dart-define=FIREBASE_API_KEY=VOTRE_CLE
```

Sans cle Firebase, l'application utilise une connexion demo locale pour rester
testable pendant l'examen.

## Validation

```powershell
flutter pub get
flutter analyze
flutter test
flutter run
```
