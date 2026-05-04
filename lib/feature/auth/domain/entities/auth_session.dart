class AuthSession {
  const AuthSession({
    required this.userId,
    required this.email,
    required this.organizationId,
  });

  final String userId;
  final String email;
  final String organizationId;
}
