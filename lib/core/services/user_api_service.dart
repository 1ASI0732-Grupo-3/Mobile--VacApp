import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vacapp/core/constants/endpoints.dart';
import 'package:vacapp/core/services/token_service.dart';

class UserApiService {
  static Future<Map<String, String>> _getHeaders() async {
    final token = await TokenService.instance.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Obtener información del perfil del usuario
  static Future<Map<String, dynamic>> getUserInfo() async {
    try {
      print('🔍 [USER_API] Obteniendo información del usuario...');
      
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${Endpoints.baseUrl}/user/get-info'),
        headers: headers,
      );

      print('📊 [USER_API] Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ [USER_API] Información obtenida exitosamente');
        return data;
      } else {
        print('❌ [USER_API] Error ${response.statusCode}: ${response.body}');
        throw Exception('Error al obtener información del usuario: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [USER_API] Error: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  /// Actualizar perfil del usuario
  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> profileData) async {
    try {
      print('🔄 [USER_API] Actualizando perfil del usuario...');
      
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('${Endpoints.baseUrl}/user/update-profile'),
        headers: headers,
        body: json.encode(profileData),
      );

      print('📊 [USER_API] Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ [USER_API] Perfil actualizado exitosamente');
        return data;
      } else {
        print('❌ [USER_API] Error ${response.statusCode}: ${response.body}');
        throw Exception('Error al actualizar perfil: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [USER_API] Error: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  /// Eliminar cuenta del usuario (PELIGROSO)
  static Future<bool> deleteAccount() async {
    try {
      print('🚨 [USER_API] ELIMINANDO CUENTA DEL USUARIO...');
      
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${Endpoints.baseUrl}/user/delete-account'),
        headers: headers,
      );

      print('📊 [USER_API] Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('✅ [USER_API] Cuenta eliminada exitosamente');
        // Limpiar sesión local
        await TokenService.instance.clearUserSession();
        return true;
      } else {
        print('❌ [USER_API] Error ${response.statusCode}: ${response.body}');
        throw Exception('Error al eliminar cuenta: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [USER_API] Error: $e');
      throw Exception('Error de conexión: $e');
    }
  }
}
