import 'package:vacapp/features/stables/data/datasources/stables_service.dart';
import 'package:vacapp/features/stables/data/models/stable_dto.dart';

class StableRepository {
  final StablesService _stablesService;

  StableRepository(this._stablesService);

  Future<List<StableDto>> getStables() async {
  try {
    final stables = await _stablesService.fetchStables();
    return stables;
  } catch (e) {
    // Manejo de errores, podrías lanzar una excepción o retornar una lista vacía
    return [];
  }
  }
  
  // Crear un establo
  Future<StableDto> createStable(StableDto stable) async {
    final createdStable = await _stablesService.createStable(stable);
    // Opcional: puedes volver a sincronizar la lista de establos si lo deseas
    await getStables();
    return createdStable;
  }
  // Actualizar un establo
  Future<void> updateStable(int id, StableDto stable) async {
    await _stablesService.updateStable(id, stable);
    await getStables();
  }

  // Eliminar un establo
  Future<void> deleteStable(int id) async {
    await _stablesService.deleteStable(id);
    await getStables();
  }

  // Obtener un establo por ID
  Future<StableDto> getStableById(int id) async {
    return await _stablesService.fetchStableById(id); 
  } 
}