import 'package:vacapp/features/animals/data/repositories/animal_repository.dart';

class DeleteAnimal {
  final AnimalRepository repository;
  DeleteAnimal(this.repository);

  Future<void> call(int id) async {
    await repository.deleteAnimal(id);
  }
}