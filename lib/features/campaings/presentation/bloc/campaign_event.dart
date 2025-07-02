abstract class CampaignEvent {
  const CampaignEvent();
}

// Eventos para cargar campañas
class LoadAllCampaigns extends CampaignEvent {}

class LoadCampaignById extends CampaignEvent {
  final int id;
  
  const LoadCampaignById(this.id);
}

class LoadCampaignsByStable extends CampaignEvent {
  final int stableId;
  
  const LoadCampaignsByStable(this.stableId);
}

// Eventos CRUD
class CreateCampaign extends CampaignEvent {
  final Map<String, dynamic> campaignData;
  
  const CreateCampaign(this.campaignData);
}

class UpdateCampaignStatus extends CampaignEvent {
  final int id;
  final String status;
  
  const UpdateCampaignStatus(this.id, this.status);
}

class DeleteCampaign extends CampaignEvent {
  final int id;
  
  const DeleteCampaign(this.id);
}

// Eventos para goals y channels
class AddGoalToCampaign extends CampaignEvent {
  final int campaignId;
  final Map<String, dynamic> goalData;
  
  const AddGoalToCampaign(this.campaignId, this.goalData);
}

class AddChannelToCampaign extends CampaignEvent {
  final int campaignId;
  final Map<String, dynamic> channelData;
  
  const AddChannelToCampaign(this.campaignId, this.channelData);
}

// Nuevos eventos para obtener goals y channels
class LoadCampaignGoals extends CampaignEvent {
  final int campaignId;
  
  const LoadCampaignGoals(this.campaignId);
}

class LoadCampaignChannels extends CampaignEvent {
  final int campaignId;
  
  const LoadCampaignChannels(this.campaignId);
}

// Evento para cargar goals y channels de todas las campañas
class LoadAllCampaignsWithDetails extends CampaignEvent {}

// Eventos de utilidad
class RefreshCampaigns extends CampaignEvent {}

class ResetCampaignState extends CampaignEvent {}
