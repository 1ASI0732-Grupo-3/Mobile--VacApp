abstract class AuthEvent {
  const AuthEvent();
}

class LoginEvent extends AuthEvent {
  final String usernameOrEmail;
  final String password;

  const LoginEvent({required this.usernameOrEmail, required this.password});
}

class SignUpEvent extends AuthEvent {
  final String username;
  final String password;
  final String email;

  const SignUpEvent({
    required this.username,
    required this.password,
    required this.email,
  });
}
