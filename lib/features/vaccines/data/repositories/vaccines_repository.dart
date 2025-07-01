import 'dart:io';

import 'package:vacapp/features/vaccines/data/datasources/vaccines_services.dart';
import 'package:vacapp/features/vaccines/data/models/vaccines_dto.dart';

class VaccinesRepository {
  final VaccinesService _vaccinesService;

  VaccinesRepository(this._vaccinesService);

  Future<List<VaccinesDto>> getVaccines() async {
    print('🔍 [DEBUG] Repositorio: Iniciando getVaccines...');
    try {
      final vaccines = await _vaccinesService.fetchVaccines();
      print('✅ [DEBUG] Repositorio: Vacunas obtenidas del servicio: ${vaccines.length}');
      for (int i = 0; i < vaccines.length; i++) {
        print('🔍 [DEBUG] Repositorio: Vacuna $i: ${vaccines[i].name} (ID: ${vaccines[i].id})');
      }
      return vaccines;
    } catch (e) {
      print('❌ [DEBUG] Repositorio: Error en getVaccines: $e');
      print('❌ [DEBUG] Repositorio: Stack trace: ${StackTrace.current}');
      // Manejo de errores, podrías lanzar una excepción o retornar una lista vacía
      return [];
    }
  }

  // Crear una vacuna
  Future<void> createVaccine(VaccinesDto vaccine, File imageFile) async {
    await _vaccinesService.createVaccine(vaccine, imageFile);
    await getVaccines();
  }

  // Crear una vacuna con URL de imagen predeterminada
  Future<void> createVaccineWithUrl(VaccinesDto vaccine) async {
    await _vaccinesService.createVaccineWithUrl(vaccine);
    await getVaccines();
  }

  // Actualizar una vacuna
  Future<void> updateVaccine(int id, Map<String, dynamic> data, File? imageFile) async {
    await VaccinesService().updateVaccine(id, data, imageFile);
  }

  // Eliminar una vacuna
  Future<void> deleteVaccine(int id) async {
    await _vaccinesService.deleteVaccine(id);
    await getVaccines();
  }

  // Obtener una vacuna por ID
  Future<VaccinesDto> getVaccineById(int id) async {
    return await _vaccinesService.fetchVaccineById(id);
  }

  // Obtener vacunas por bovinoId
  Future<List<VaccinesDto>> getVaccinesByBovineId(int bovineId) async {
    return await _vaccinesService.fetchVaccinesByBovineId(bovineId);
  }
}