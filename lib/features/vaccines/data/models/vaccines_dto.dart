import 'package:vacapp/features/vaccines/domain/vaccines.dart';

class VaccinesDto {
  final int id;
  final String name;
  final String vaccineType;
  final String vaccineDate;
  final String vaccineImg;
  final int bovineId;

  VaccinesDto({
    required this.id,
    required this.name,
    required this.vaccineType,
    required this.vaccineDate,
    required this.vaccineImg,
    required this.bovineId,
  });

  factory VaccinesDto.fromJson(Map<String, dynamic> json) {
    print('🔍 [DEBUG] Parseando JSON: $json');
    try {
      final dto = VaccinesDto(
        id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
        name: json['name']?.toString() ?? '',
        vaccineType: json['vaccineType']?.toString() ?? '',
        vaccineDate: json['vaccineDate']?.toString() ?? '',
        vaccineImg: json['vaccineImg']?.toString() ?? '',
        bovineId: json['bovineId'] is int ? json['bovineId'] : int.parse(json['bovineId'].toString()),
      );
      print('✅ [DEBUG] DTO creado exitosamente: ${dto.name} (ID: ${dto.id})');
      return dto;
    } catch (e) {
      print('❌ [DEBUG] Error parseando DTO: $e');
      print('❌ [DEBUG] JSON problemático: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'vaccineType': vaccineType,
      'vaccineDate': vaccineDate,
      'vaccineImg': vaccineImg,
      'bovineId': bovineId,
    };
  }

  Vaccines toDomain() {
    return Vaccines(
      id: id,
      name: name,
      vaccineType: vaccineType,
      vaccineDate: vaccineDate,
      vaccineImg: vaccineImg,
      bovineId: bovineId,
    );
  }

  static VaccinesDto fromDomain(Vaccines vaccine) {
    return VaccinesDto(
      id: vaccine.id,
      name: vaccine.name,
      vaccineType: vaccine.vaccineType,
      vaccineDate: vaccine.vaccineDate,
      vaccineImg: vaccine.vaccineImg,
      bovineId: vaccine.bovineId,
    );
  }
}