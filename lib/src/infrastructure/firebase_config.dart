class FirebaseConfig {
  const FirebaseConfig._();

  static const String apiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: 'AIzaSyCVzAxm2HkPjjbhyDnbY7l5NGnJuqJTWk0',
  );

  static const String projectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'tracker-flutter-119ee',
  );
}
