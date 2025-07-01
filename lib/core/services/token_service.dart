import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  static const String _tokenKey = 'token';
  static const String _usernameKey = 'username';
  static TokenService? _instance;
  
  TokenService._();
  
  static TokenService get instance {
    _instance ??= TokenService._();
    return _instance!;
  }

  /// Obtiene el token de autenticación almacenado
  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey) ?? '';
  }

  /// Guarda el token de autenticación
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Guarda el username del usuario
  Future<void> saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username);
  }

  /// Obtiene el username almacenado
  Future<String> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey) ?? '';
  }

  /// Guarda tanto el token como el username
  Future<void> saveUserSession(String token, String username) async {
    await saveToken(token);
    await saveUsername(username);
  }

  /// Elimina el token de autenticación
  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  /// Elimina toda la sesión del usuario (token y username)
  Future<void> clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_usernameKey);
  }

  /// Verifica si existe un token válido
  Future<bool> hasValidToken() async {
    final token = await getToken();
    return token.isNotEmpty;
  }

  /// Obtiene los headers de autorización con el token
  Future<Map<String, String>> getAuthHeaders({Map<String, String>? additionalHeaders}) async {
    final token = await getToken();
    final headers = <String, String>{
      'Authorization': 'Bearer $token',
      ...?additionalHeaders,
    };
    return headers;
  }

  /// Obtiene los headers de autorización con Content-Type application/json
  Future<Map<String, String>> getJsonAuthHeaders() async {
    return await getAuthHeaders(additionalHeaders: {
      'Content-Type': 'application/json',
    });
  }
}
