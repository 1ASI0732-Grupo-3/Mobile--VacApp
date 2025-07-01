import 'dart:io';
import 'package:vacapp/features/animals/data/models/animal_dto.dart';
import 'package:vacapp/features/animals/data/repositories/animal_repository.dart';

class CreateAnimal {
  final AnimalRepository repository;
  CreateAnimal(this.repository);

  Future<void> call(AnimalDto animal, File imageFile) async {
    await repository.createAnimal(animal, imageFile);
  }
}
