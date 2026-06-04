import '../entities/user_session.dart';

abstract class AuthRepository {
  Future<UserSession> signIn({required String email, required String password});

  Future<void> signOut();
}
