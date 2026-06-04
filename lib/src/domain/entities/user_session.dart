class UserSession {
  const UserSession({
    required this.driverId,
    required this.email,
    required this.token,
  });

  final String driverId;
  final String email;
  final String token;
}
