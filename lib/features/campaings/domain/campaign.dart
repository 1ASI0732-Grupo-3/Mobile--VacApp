import 'package:vacapp/features/campaings/domain/campaign_channel.dart';
import 'package:vacapp/features/campaings/domain/campaign_goals.dart';

class Campaign {
  final int id;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final List<CampaignGoals> goals;
  final List<CampaignChannel> channels;
  final int stableId;

  Campaign({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.goals,
    required this.channels,
    required this.stableId,
  });

  
}

