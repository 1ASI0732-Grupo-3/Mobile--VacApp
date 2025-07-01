import 'package:vacapp/features/auth/data/datasources/auth_service.dart';
import 'package:vacapp/features/auth/data/models/user_dto.dart';
import 'package:vacapp/features/auth/domain/entitites/user.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  Future<User> login({required String usernameOrEmail, required String password}) async {
    final UserDTO userDTO = await _authService.login(
      usernameOrEmail: usernameOrEmail,
      password: password,
    );
    return User(
      username: userDTO.username,
      email: userDTO.email,
      password: '', // Por seguridad, no guardes el password
      token: userDTO.token,
    );
  }

  Future<User> signUp({required String username, required String password, required String email}) async {
    final UserDTO userDTO = await _authService.signUp(
      username: username,
      password: password,
      email: email,
    );
    return User(
      username: userDTO.username,
      email: userDTO.email,
      password: '', // Por seguridad, no guardes el password
      token: userDTO.token,
    );
  }
}