import 'dart:io';

import 'package:vacapp/features/animals/data/dataasources/animals_service.dart';
import 'package:vacapp/features/animals/data/dataasources/animal_dao.dart';
import 'package:vacapp/features/animals/data/models/animal_dto.dart';

class AnimalRepository {
  final AnimalsService _animalsService;
  final AnimalDao _animalDao;

  AnimalRepository(this._animalsService, this._animalDao);

  Future<List<AnimalDto>> getAnimals() async {
    try {
      final animals = await _animalsService.fetchAnimals();
      await _animalDao.insertAnimals(animals);
      return animals;
    } catch (e) {
      return await _animalDao.fetchAnimalsFromDb();
    }
  }

  // Crear un animal
  Future<void> createAnimal(AnimalDto animal, File imageFile) async {
    await _animalsService.createAnimal(animal, imageFile);
    // Opcional: puedes volver a sincronizar la base local si lo deseas
    await getAnimals();
  }

  Future<void> updateAnimal(int id, Map<String, dynamic> data) async {
    await AnimalsService().updateAnimal(id, data);
  }

  // Eliminar un animal
  Future<void> deleteAnimal(int id) async {
    await _animalsService.deleteAnimal(id);
    await getAnimals();
  }

  // Obtener un animal por ID
  Future<AnimalDto> getAnimalById(int id) async {
    return await _animalsService.fetchAnimalById(id);
  }

  // Obtener animales por stableId
  Future<List<AnimalDto>> getAnimalsByStableId(int stableId) async {
    return await _animalsService.fetchAnimalByStableId(stableId);
  }
}