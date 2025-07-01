import 'package:vacapp/features/animals/data/models/animal_dto.dart';
import 'package:vacapp/features/animals/data/repositories/animal_repository.dart';

class GetAnimals {
  final AnimalRepository repository;
  GetAnimals(this.repository);

  Future<List<AnimalDto>> call() async {
    return await repository.getAnimals();
  }
}