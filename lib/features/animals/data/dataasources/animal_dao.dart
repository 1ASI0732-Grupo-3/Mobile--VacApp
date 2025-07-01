import 'package:vacapp/features/animals/data/dataasources/database_provider.dart';
import 'package:vacapp/features/animals/data/models/animal_dto.dart';


class AnimalDao {
  Future<void> insertAnimals(List<AnimalDto> animals) async {
    final db = await DatabaseProvider().openDb();
    await db.delete('animals');
    for (final animal in animals) {
      await db.insert('animals', animal.toJson());
    }
  }

  Future<List<AnimalDto>> fetchAnimalsFromDb() async {
    final db = await DatabaseProvider().openDb();
    final maps = await db.query('animals');
    return maps.map((e) => AnimalDto.fromJson(e)).toList();
  }
}