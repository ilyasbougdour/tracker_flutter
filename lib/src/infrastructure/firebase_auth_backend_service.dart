import 'package:dio/dio.dart';

import '../domain/entities/user_session.dart';
import 'firebase_config.dart';

class FirebaseAuthBackendService {
  FirebaseAuthBackendService(this._dio);

  final Dio _dio;

  Future<UserSession> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    const String apiKey = FirebaseConfig.apiKey;

    if (apiKey.isEmpty) {
      throw StateError(
        'Firebase Auth non configure. '
        'Ajoutez FIREBASE_API_KEY avec --dart-define.',
      );
    }

    final Response<Map<String, dynamic>>
    response = await _dio.post<Map<String, dynamic>>(
      'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$apiKey',
      data: <String, Object>{
        'email': email,
        'password': password,
        'returnSecureToken': true,
      },
    );

    final Map<String, dynamic> data = response.data ?? <String, dynamic>{};
    return UserSession(
      driverId: data['localId'] as String,
      email: data['email'] as String,
      token: data['idToken'] as String,
    );
  }
}
