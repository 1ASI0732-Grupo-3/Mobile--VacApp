import 'package:vacapp/features/auth/domain/entitites/user.dart';

abstract class AuthState {
  const AuthState();
}

class InitialAuthState extends AuthState {}

class LoadingAuthState extends AuthState {}

class SuccessAuthState extends AuthState {
  final User user;
  const SuccessAuthState({required this.user});
}

class FailureState extends AuthState {
  final String errorMessage;
  const FailureState({required this.errorMessage});
}