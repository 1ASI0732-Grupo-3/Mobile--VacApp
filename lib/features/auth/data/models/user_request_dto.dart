class UserRequestDto {
  final String usernameOrEmail;
  final String password;
  final String? email; // Solo para registro

  const UserRequestDto({
    required this.usernameOrEmail,
    required this.password,
    this.email,
  });

  // isSignUp: true para registro, false para login
  Map<String, dynamic> toJson({required bool isSignUp}) {
    if (isSignUp) {
      return {
        'username': usernameOrEmail,
        'password': password,
        'email': email ?? '',
      };
    } else {
      final isEmail = usernameOrEmail.contains('@');
      return {
        'email': isEmail ? usernameOrEmail : '',
        'userName': isEmail ? '' : usernameOrEmail,
        'password': password,
      };
    }
  }
}