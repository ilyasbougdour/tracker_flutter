import '../domain/entities/user_session.dart';
import '../domain/repositories/auth_repository.dart';
import 'firebase_auth_backend_service.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._backend);

  final FirebaseAuthBackendService _backend;

  @override
  Future<UserSession> signIn({
    required String email,
    required String password,
  }) {
    return _backend.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signOut() async {}
}
