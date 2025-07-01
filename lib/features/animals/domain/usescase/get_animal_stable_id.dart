import 'package:vacapp/features/animals/data/models/animal_dto.dart';
import 'package:vacapp/features/animals/data/repositories/animal_repository.dart';

class GetAnimalsByStableId {
  final AnimalRepository repository;
  GetAnimalsByStableId(this.repository);

  Future<List<AnimalDto>> call(int stableId) async {
    return await repository.getAnimalsByStableId(stableId);
  }
}