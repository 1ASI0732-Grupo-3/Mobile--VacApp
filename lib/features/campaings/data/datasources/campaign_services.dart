import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vacapp/features/campaings/data/models/campaings_dto.dart';
import 'package:vacapp/core/constants/endpoints.dart';
import 'package:vacapp/core/services/token_service.dart';

class CampaignServices {
  
  // GET /api/v1/campaign/all-campaigns - Obtener todas las campañas
  Future<List<CampaingsDto>> getAllCampaigns() async {
    try {
      final token = await TokenService.instance.getToken();
      print('🔍 [DEBUG] Token obtenido para campañas: ${token.isNotEmpty ? "Token presente" : "Token vacío"}');
      
      final response = await http.get(
        Uri.parse('${Endpoints.campaign}/all-campaigns'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('🔍 [DEBUG] Response status: ${response.statusCode}');
      print('🔍 [DEBUG] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((campaign) => CampaingsDto.fromJson(campaign)).toList();
      } else {
        throw Exception('Error al obtener campañas: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ [DEBUG] Error en getAllCampaigns: $e');
      throw Exception('Error de conexión: $e');
    }
  }
  
  // POST /api/v1/campaign - Crear nueva campaña
  Future<CampaingsDto> createCampaign(Map<String, dynamic> campaignData) async {
    try {
      final token = await TokenService.instance.getToken();
      
      final response = await http.post(
        Uri.parse(Endpoints.campaign),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(campaignData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return CampaingsDto.fromJson(data);
      } else {
        throw Exception('Error al crear campaña: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // GET /api/v1/campaign/{id} - Obtener campaña por ID
  Future<CampaingsDto> getCampaignById(int id) async {
    try {
      final token = await TokenService.instance.getToken();
      
      final response = await http.get(
        Uri.parse('${Endpoints.campaign}/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return CampaingsDto.fromJson(data);
      } else {
        throw Exception('Error al obtener campaña: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // DELETE /api/v1/campaign/{id} - Eliminar campaña
  Future<bool> deleteCampaign(int id) async {
    try {
      final token = await TokenService.instance.getToken();
      
      final response = await http.delete(
        Uri.parse('${Endpoints.campaign}/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception('Error al eliminar campaña: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // PATCH /api/v1/campaign/{id}/update-status - Actualizar estado de campaña
  Future<CampaingsDto> updateCampaignStatus(int id, String status) async {
    try {
      final token = await TokenService.instance.getToken();
      print('🔍 [DEBUG] Token obtenido para actualizar estado: ${token.isNotEmpty ? "Token presente" : "Token vacío"}');
      print('🔍 [DEBUG] Actualizando estado de campaña ID: $id a estado: $status');
      
      final response = await http.patch(
        Uri.parse('${Endpoints.campaign}/$id/update-status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': status}),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Timeout: La solicitud tardó demasiado tiempo');
        },
      );

      print('🔍 [DEBUG] Response status para updateCampaignStatus: ${response.statusCode}');
      print('🔍 [DEBUG] Response body para updateCampaignStatus: ${response.body}');

      // Aceptar tanto 200 como 201 como respuestas exitosas
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final updatedCampaign = CampaingsDto.fromJson(data);
          print('✅ [DEBUG] Estado actualizado exitosamente. Nuevo estado: ${updatedCampaign.status}');
          return updatedCampaign;
        } catch (parseError) {
          print('❌ [DEBUG] Error al parsear respuesta JSON: $parseError');
          print('❌ [DEBUG] Response body que falló: ${response.body}');
          throw Exception('Error al procesar respuesta del servidor: $parseError');
        }
      } else {
        print('❌ [DEBUG] Error en updateCampaignStatus: Status ${response.statusCode}');
        throw Exception('Error al actualizar estado: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ [DEBUG] Error en updateCampaignStatus: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // PATCH /api/v1/campaign/{id}/add-goal - Agregar objetivo a campaña
  Future<CampaingsDto> addGoalToCampaign(int id, Map<String, dynamic> goalData) async {
    try {
      final token = await TokenService.instance.getToken();
      print('🔍 [DEBUG] Token obtenido para agregar goal: ${token.isNotEmpty ? "Token presente" : "Token vacío"}');
      print('🔍 [DEBUG] Agregando goal a campaña ID: $id');
      print('🔍 [DEBUG] Goal data enviado: $goalData');
      
      final response = await http.patch(
        Uri.parse('${Endpoints.campaign}/$id/add-goal'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(goalData),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Timeout: La solicitud tardó demasiado tiempo');
        },
      );

      print('🔍 [DEBUG] Response status para addGoalToCampaign: ${response.statusCode}');
      print('🔍 [DEBUG] Response body para addGoalToCampaign: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final updatedCampaign = CampaingsDto.fromJson(data);
        print('✅ [DEBUG] Goal agregado exitosamente. Nuevos goals: ${updatedCampaign.goals.length}');
        return updatedCampaign;
      } else {
        print('❌ [DEBUG] Error en addGoalToCampaign: Status ${response.statusCode}');
        throw Exception('Error al agregar objetivo: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ [DEBUG] Error en addGoalToCampaign: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // PATCH /api/v1/campaign/{id}/add-channel - Agregar canal a campaña
  Future<CampaingsDto> addChannelToCampaign(int id, Map<String, dynamic> channelData) async {
    try {
      final token = await TokenService.instance.getToken();
      print('🔍 [DEBUG] Token obtenido para agregar channel: ${token.isNotEmpty ? "Token presente" : "Token vacío"}');
      print('🔍 [DEBUG] Agregando channel a campaña ID: $id');
      print('🔍 [DEBUG] Channel data enviado: $channelData');
      
      final response = await http.patch(
        Uri.parse('${Endpoints.campaign}/$id/add-channel'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(channelData),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Timeout: La solicitud tardó demasiado tiempo');
        },
      );

      print('🔍 [DEBUG] Response status para addChannelToCampaign: ${response.statusCode}');
      print('🔍 [DEBUG] Response body para addChannelToCampaign: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final updatedCampaign = CampaingsDto.fromJson(data);
        print('✅ [DEBUG] Channel agregado exitosamente. Nuevos channels: ${updatedCampaign.channels.length}');
        return updatedCampaign;
      } else {
        print('❌ [DEBUG] Error en addChannelToCampaign: Status ${response.statusCode}');
        throw Exception('Error al agregar canal: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ [DEBUG] Error en addChannelToCampaign: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // GET /api/v1/campaign/{id}/goals - Obtener objetivos de una campaña
  Future<List<Map<String, dynamic>>> getCampaignGoals(int id) async {
    try {
      final token = await TokenService.instance.getToken();
      print('🎯 [CampaignService] getCampaignGoals - ID: $id');

      final response = await http.get(
        Uri.parse('${Endpoints.campaign}/$id/goals'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      print('🎯 [CampaignService] getCampaignGoals response - Status: ${response.statusCode}');
      print('🎯 [CampaignService] getCampaignGoals response - Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error al obtener objetivos: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [CampaignService] Error en getCampaignGoals: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // GET /api/v1/campaign/{id}/channels - Obtener canales de una campaña
  Future<List<Map<String, dynamic>>> getCampaignChannels(int id) async {
    try {
      final String token = await TokenService.instance.getToken();
      if (token.isEmpty) {
        throw Exception('Token de autenticación no encontrado');
      }

      print('📺 [CampaignService] getCampaignChannels - ID: $id');
      
      final response = await http.get(
        Uri.parse('${Endpoints.campaign}/$id/channels'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      print('📺 [CampaignService] getCampaignChannels response - Status: ${response.statusCode}');
      print('📺 [CampaignService] getCampaignChannels response - Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error al obtener canales: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [CampaignService] Error en getCampaignChannels: $e');
      throw Exception('Error de conexión: $e');
    }
  }
}