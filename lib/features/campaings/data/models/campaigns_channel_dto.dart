import 'package:vacapp/features/campaings/domain/campaign_channel.dart';

class CampaignsChannelDto {
  final int id;
  final String type;
  final String details;

  CampaignsChannelDto({
    required this.id,
    required this.type,
    required this.details,
  });

  factory CampaignsChannelDto.fromJson(Map<String, dynamic> json) {
    return CampaignsChannelDto(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      type: json['type']?.toString() ?? '',
      details: json['details']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'details': details,
    };
  }

  CampaignChannel toDomain() {
    return CampaignChannel(
      id: id,
      type: type,
      details: details,
    );
  }

  static CampaignsChannelDto fromDomain(CampaignChannel channel) {
    return CampaignsChannelDto(
      id: channel.id,
      type: channel.type,
      details: channel.details,
    );
  }
  
}