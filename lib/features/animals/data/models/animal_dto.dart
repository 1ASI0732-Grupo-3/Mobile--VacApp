import 'package:vacapp/features/animals/domain/entitites/Animal.dart';

class AnimalDto {
  final int id;
  final String name;
  final String gender;
  final String birthDate;
  final String breed;
  final String location;
  final String bovineImg;
  final int stableId;

  AnimalDto({
    required this.id,
    required this.name,
    required this.gender,
    required this.birthDate,
    required this.breed,
    required this.location,
    required this.bovineImg,
    required this.stableId,
  });

  factory AnimalDto.fromJson(Map<String, dynamic> json) {
    return AnimalDto(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      gender: json['gender'] ?? '',
      birthDate: json['birthDate'] ?? '',
      breed: json['breed'] ?? '',
      location: json['location'] ?? '',
      bovineImg: json['bovineImg'] ?? '',
      stableId: json['stableId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'birthDate': birthDate,
      'breed': breed,
      'location': location,
      'bovineImg': bovineImg,
      'stableId': stableId,
    };
  }

  Animal toDomain() {
    return Animal(
      id: id,
      name: name,
      gender: gender,
      birthDate: birthDate,
      breed: breed,
      location: location,
      bovineImg: bovineImg,
      stableId: stableId,
    );
  }

  factory AnimalDto.fromDomain(Animal animal) {
    return AnimalDto(
      id: animal.id,
      name: animal.name,
      gender: animal.gender,
      birthDate: animal.birthDate,
      breed: animal.breed,
      location: animal.location,
      bovineImg: animal.bovineImg,
      stableId: animal.stableId,
    );
  }
}