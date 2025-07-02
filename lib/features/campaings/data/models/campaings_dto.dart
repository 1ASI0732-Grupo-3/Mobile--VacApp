
import 'package:vacapp/features/campaings/data/models/campaigns_channel_dto.dart';
import 'package:vacapp/features/campaings/data/models/campaigns_goal_dto.dart';
import 'package:vacapp/features/campaings/domain/campaign.dart';

class CampaingsDto {
  final int id;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final List<CampaignsGoalDto> goals; // Updated to use CampaignGoals
  final List<CampaignsChannelDto> channels;
  final int stableId;

  CampaingsDto({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.goals, // Updated to use CampaignGoals
    required this.channels,
    required this.stableId,
  });

  factory CampaingsDto.fromJson(Map<String, dynamic> json) {
    return CampaingsDto(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      status: json['status']?.toString() ?? '',
      goals: (json['goals'] as List?)
          ?.map((goal) => CampaignsGoalDto.fromJson(goal))
          .toList() ?? [],
      channels: (json['channel'] as List?) // Cambiado de 'channels' a 'channel' 
          ?.map((channel) => CampaignsChannelDto.fromJson(channel))
          .toList() ?? [],
      stableId: json['stableId'] is int
          ? json['stableId']
          : int.parse(json['stableId'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status,
      'goals': goals.map((goal) => goal.toJson()).toList(),
      'channel': channels.map((channel) => channel.toJson()).toList(), // Cambiado de 'channels' a 'channel'
      'stableId': stableId,
    };
  }

  Campaign toDomain() {
    return Campaign(
      id: id,
      name: name,
      description: description,
      startDate: startDate,
      endDate: endDate,
      status: status,
      goals: goals.map((goal) => goal.toDomain()).toList(),
      channels: channels.map((channel) => channel.toDomain()).toList(),
      stableId: stableId,
    );
  }

  static CampaingsDto fromDomain(Campaign campaign) {
    return CampaingsDto(
      id: campaign.id,
      name: campaign.name,
      description: campaign.description,
      startDate: campaign.startDate,
      endDate: campaign.endDate,
      status: campaign.status,
      goals: campaign.goals.map((goal) => CampaignsGoalDto.fromDomain(goal)).toList(),
      channels: campaign.channels.map((channel) => CampaignsChannelDto.fromDomain(channel)).toList(),
      stableId: campaign.stableId,
    );
  }

}