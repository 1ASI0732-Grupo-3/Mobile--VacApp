class CampaignGoals {
  final int id;
  final String description;
  final String metric;
  final int targetValue;
  final int currentValue;

  CampaignGoals({
    required this.id,
    required this.description,
    required this.metric,
    required this.targetValue,
    required this.currentValue,
  });
}