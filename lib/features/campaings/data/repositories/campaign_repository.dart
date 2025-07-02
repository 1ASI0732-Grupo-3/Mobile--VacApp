import 'package:vacapp/features/campaings/data/datasources/campaign_services.dart';
import 'package:vacapp/features/campaings/data/models/campaings_dto.dart';

class CampaignRepository {
  final CampaignServices _campaignServices;

  CampaignRepository(this._campaignServices);

  // Crear nueva campaña
  Future<CampaingsDto> createCampaign(Map<String, dynamic> campaignData) async {
    try {
      return await _campaignServices.createCampaign(campaignData);
    } catch (e) {
      throw Exception('Repository - Error al crear campaña: $e');
    }
  }

  // Obtener campaña por ID
  Future<CampaingsDto> getCampaignById(int id) async {
    try {
      return await _campaignServices.getCampaignById(id);
    } catch (e) {
      throw Exception('Repository - Error al obtener campaña: $e');
    }
  }

  // Eliminar campaña
  Future<bool> deleteCampaign(int id) async {
    try {
      return await _campaignServices.deleteCampaign(id);
    } catch (e) {
      throw Exception('Repository - Error al eliminar campaña: $e');
    }
  }

  // Obtener todas las campañas
  Future<List<CampaingsDto>> getAllCampaigns() async {
    try {
      return await _campaignServices.getAllCampaigns();
    } catch (e) {
      throw Exception('Repository - Error al obtener todas las campañas: $e');
    }
  }

  // Actualizar estado de campaña
  Future<CampaingsDto> updateCampaignStatus(int id, String status) async {
    try {
      final result = await _campaignServices.updateCampaignStatus(id, status);
      return result;
    } catch (e) {
      throw Exception('Repository - Error al actualizar estado: $e');
    }
  }

  // Agregar objetivo a campaña
  Future<CampaingsDto> addGoalToCampaign(int id, Map<String, dynamic> goalData) async {
    try {
      return await _campaignServices.addGoalToCampaign(id, goalData);
    } catch (e) {
      throw Exception('Repository - Error al agregar objetivo: $e');
    }
  }

  // Agregar canal a campaña
  Future<CampaingsDto> addChannelToCampaign(int id, Map<String, dynamic> channelData) async {
    try {
      return await _campaignServices.addChannelToCampaign(id, channelData);
    } catch (e) {
      throw Exception('Repository - Error al agregar canal: $e');
    }
  }

  // Obtener objetivos de una campaña
  Future<List<Map<String, dynamic>>> getCampaignGoals(int id) async {
    try {
      return await _campaignServices.getCampaignGoals(id);
    } catch (e) {
      throw Exception('Repository - Error al obtener objetivos: $e');
    }
  }

  // Obtener canales de una campaña
  Future<List<Map<String, dynamic>>> getCampaignChannels(int id) async {
    try {
      return await _campaignServices.getCampaignChannels(id);
    } catch (e) {
      throw Exception('Repository - Error al obtener canales: $e');
    }
  }

  // Métodos adicionales de conveniencia

  // Verificar si una campaña existe
  Future<bool> campaignExists(int id) async {
    try {
      await getCampaignById(id);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Obtener campañas por estado
  Future<List<CampaingsDto>> getCampaignsByStatus(String status) async {
    try {
      final allCampaigns = await getAllCampaigns();
      return allCampaigns.where((campaign) => campaign.status == status).toList();
    } catch (e) {
      throw Exception('Repository - Error al filtrar campañas por estado: $e');
    }
  }

  // Obtener campañas activas (estado activo)
  Future<List<CampaingsDto>> getActiveCampaigns() async {
    try {
      return await getCampaignsByStatus('active');
    } catch (e) {
      throw Exception('Repository - Error al obtener campañas activas: $e');
    }
  }

  // Obtener campañas por establo
  Future<List<CampaingsDto>> getCampaignsByStableId(int stableId) async {
    try {
      final allCampaigns = await getAllCampaigns();
      return allCampaigns.where((campaign) => campaign.stableId == stableId).toList();
    } catch (e) {
      throw Exception('Repository - Error al obtener campañas por establo: $e');
    }
  }

  // Activar campaña
  Future<CampaingsDto> activateCampaign(int id) async {
    try {
      return await updateCampaignStatus(id, 'active');
    } catch (e) {
      throw Exception('Repository - Error al activar campaña: $e');
    }
  }

  // Pausar campaña
  Future<CampaingsDto> pauseCampaign(int id) async {
    try {
      return await updateCampaignStatus(id, 'paused');
    } catch (e) {
      throw Exception('Repository - Error al pausar campaña: $e');
    }
  }

  // Completar campaña
  Future<CampaingsDto> completeCampaign(int id) async {
    try {
      return await updateCampaignStatus(id, 'completed');
    } catch (e) {
      throw Exception('Repository - Error al completar campaña: $e');
    }
  }

  // Cancelar campaña
  Future<CampaingsDto> cancelCampaign(int id) async {
    try {
      return await updateCampaignStatus(id, 'cancelled');
    } catch (e) {
      throw Exception('Repository - Error al cancelar campaña: $e');
    }
  }
}