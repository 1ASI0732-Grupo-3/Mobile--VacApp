import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../services/connectivity_service.dart';

class ConnectivityHttpClient {
  static final ConnectivityService _connectivityService = ConnectivityService();
  
  /// Realizar una petición GET con verificación de conectividad
  static Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
  }) async {
    await _ensureConnectivity();
    return http.get(url, headers: headers);
  }

  /// Realizar una petición POST con verificación de conectividad
  static Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    await _ensureConnectivity();
    return http.post(url, headers: headers, body: body);
  }

  /// Realizar una petición PUT con verificación de conectividad
  static Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    await _ensureConnectivity();
    return http.put(url, headers: headers, body: body);
  }

  /// Realizar una petición DELETE con verificación de conectividad
  static Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    await _ensureConnectivity();
    return http.delete(url, headers: headers, body: body);
  }

  /// Verificar conectividad antes de realizar peticiones
  static Future<void> _ensureConnectivity() async {
    final isConnected = await _connectivityService.checkConnection();
    if (!isConnected) {
      throw const SocketException('No hay conexión a internet');
    }
  }

  /// Verificar si hay conectividad sin lanzar excepción
  static Future<bool> hasConnection() async {
    return await _connectivityService.checkConnection();
  }
}
