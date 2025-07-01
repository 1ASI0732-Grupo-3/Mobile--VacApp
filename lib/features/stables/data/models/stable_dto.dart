class StableDto {
  final int id;
  final String name;
  final int limit;
  
  StableDto({
    required this.id,
    required this.name,
    required this.limit,
  });

  factory StableDto.fromJson(Map<String, dynamic> json) {
    return StableDto(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      limit: json['limit'] is int
          ? json['limit']
          : int.tryParse(json['limit'].toString()) ?? 0,
    );
  }   

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'limit': limit,
    };
  }
}