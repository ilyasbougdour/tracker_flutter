import 'package:flutter_riverpod/legacy.dart';

import '../domain/entities/user_session.dart';
import '../domain/repositories/auth_repository.dart';

class AuthState {
  const AuthState({this.user, this.isLoading = false, this.errorMessage});

  final UserSession? user;
  final bool isLoading;
  final String? errorMessage;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    UserSession? user,
    bool clearUser = false,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repository) : super(const AuthState());

  final AuthRepository _repository;

  Future<UserSession?> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final UserSession user = await _repository.signIn(
        email: email,
        password: password,
      );
      state = AuthState(user: user);
      return user;
    } catch (error) {
      state = AuthState(errorMessage: error.toString());
      return null;
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    state = const AuthState();
  }
}
