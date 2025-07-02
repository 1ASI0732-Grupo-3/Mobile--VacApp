import 'package:vacapp/features/campaings/data/models/campaings_dto.dart';

abstract class CampaignState {
  const CampaignState();
}

class CampaignInitial extends CampaignState {}

class CampaignLoading extends CampaignState {}

class CampaignLoaded extends CampaignState {
  final List<CampaingsDto> campaigns;
  
  const CampaignLoaded(this.campaigns);
}

class CampaignSingleLoaded extends CampaignState {
  final CampaingsDto campaign;
  
  const CampaignSingleLoaded(this.campaign);
}

class CampaignCreated extends CampaignState {
  final CampaingsDto campaign;
  
  const CampaignCreated(this.campaign);
}

class CampaignUpdated extends CampaignState {
  final CampaingsDto campaign;
  
  const CampaignUpdated(this.campaign);
}

class CampaignDeleted extends CampaignState {
  final String message;
  
  const CampaignDeleted(this.message);
}

class CampaignGoalsLoaded extends CampaignState {
  final List<Map<String, dynamic>> goals;
  
  const CampaignGoalsLoaded(this.goals);
}

class CampaignChannelsLoaded extends CampaignState {
  final List<Map<String, dynamic>> channels;
  
  const CampaignChannelsLoaded(this.channels);
}

class CampaignWithDetailsLoaded extends CampaignState {
  final List<CampaingsDto> campaigns;
  final Map<int, List<Map<String, dynamic>>> campaignGoals;
  final Map<int, List<Map<String, dynamic>>> campaignChannels;
  
  const CampaignWithDetailsLoaded({
    required this.campaigns,
    required this.campaignGoals,
    required this.campaignChannels,
  });
}

class CampaignError extends CampaignState {
  final String message;
  
  const CampaignError(this.message);
}

class CampaignEmpty extends CampaignState {
  final String message;
  
  const CampaignEmpty(this.message);
}
