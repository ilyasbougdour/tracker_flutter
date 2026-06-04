import 'package:dio/dio.dart';

import '../domain/entities/user_session.dart';

class FirebaseAuthBackendService {
  FirebaseAuthBackendService(this._dio);

  final Dio _dio;

  Future<UserSession> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    const String apiKey = String.fromEnvironment('FIREBASE_API_KEY');

    if (apiKey.isEmpty) {
      return UserSession(
        driverId: email.replaceAll(RegExp('[^a-zA-Z0-9]'), '_'),
        email: email,
        token: 'demo-token',
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
