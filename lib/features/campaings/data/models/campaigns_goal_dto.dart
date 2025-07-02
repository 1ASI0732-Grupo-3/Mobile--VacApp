import 'package:vacapp/features/campaings/domain/campaign_goals.dart';

class CampaignsGoalDto {
  final int id;
  final String description;
  final String metric;
  final int targetValue;
  final int currentValue;

  CampaignsGoalDto({
    required this.id,
    required this.description,
    required this.metric,
    required this.targetValue,
    required this.currentValue,
  });

  factory CampaignsGoalDto.fromJson(Map<String, dynamic> json) {
    return CampaignsGoalDto(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      description: json['description']?.toString() ?? '',
      metric: json['metric']?.toString() ?? '',
      targetValue: json['targetValue'] is int
          ? json['targetValue']
          : int.parse(json['targetValue'].toString()),
      currentValue: json['currentValue'] is int
          ? json['currentValue']
          : int.parse(json['currentValue'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'metric': metric,
      'targetValue': targetValue,
      'currentValue': currentValue,
    };
  }
  CampaignGoals toDomain() {
    return CampaignGoals(
      id: id,
      description: description,
      metric: metric,
      targetValue: targetValue,
      currentValue: currentValue,
    );
  }

  static CampaignsGoalDto fromDomain(CampaignGoals goals) {
    return CampaignsGoalDto(
      id: goals.id,
      description: goals.description,
      metric: goals.metric,
      targetValue: goals.targetValue,
      currentValue: goals.currentValue,
    );
  }

}