import 'dart:io';

import 'package:vacapp/features/animals/data/dataasources/animals_service.dart';
import 'package:vacapp/features/animals/data/dataasources/animal_dao.dart';
import 'package:vacapp/features/animals/data/models/animal_dto.dart';
import 'package:vacapp/core/services/connectivity_service.dart';
import 'package:vacapp/core/services/offline_data_service.dart';
import 'package:vacapp/core/services/token_service.dart';

class AnimalRepository {
  final AnimalsService _animalsService;
  final AnimalDao _animalDao;
  final ConnectivityService _connectivityService = ConnectivityService();
  final OfflineDataService _offlineService = OfflineDataService();

  AnimalRepository(this._animalsService, this._animalDao);

  Future<List<AnimalDto>> getAnimals() async {
    print('DEBUG AnimalRepository: Iniciando getAnimals()');
    try {
      // Si hay conexión, intentar obtener datos del servidor
      if (_connectivityService.isConnected) {
        print('DEBUG AnimalRepository: Hay conexión, obteniendo del servidor');
        final animals = await _animalsService.fetchAnimals();
        print('DEBUG AnimalRepository: Obtenidos ${animals.length} animales del servidor');
        
        // Guardar en caché local (sistema antiguo para compatibilidad)
        await _animalDao.insertAnimals(animals);
        
        // Guardar en el nuevo sistema offline
        for (final animal in animals) {
          final offlineData = _mapToOfflineFormat(animal);
          print('DEBUG AnimalRepository: Guardando animal offline: $offlineData');
          await _offlineService.saveAnimalOffline(offlineData);
        }
        
        // Marcar que hay datos offline disponibles
        if (animals.isNotEmpty) {
          await TokenService.instance.setHasOfflineData(true);
          print('DEBUG AnimalRepository: Marcado hasOfflineData como true');
        }
        
        return animals;
      } else {
        print('DEBUG AnimalRepository: Sin conexión, usando datos offline');
        // Sin conexión, usar datos offline del nuevo sistema
        final offlineData = await _offlineService.getAnimalsOffline();
        print('DEBUG AnimalRepository: Obtenidos ${offlineData.length} registros offline');
        
        if (offlineData.isNotEmpty) {
          final mappedAnimals = offlineData.map((data) => _mapFromOfflineFormat(data)).toList();
          print('DEBUG AnimalRepository: Mapeados ${mappedAnimals.length} animales');
          return mappedAnimals;
        }
        
        // Fallback al sistema antiguo si no hay datos en el nuevo sistema
        print('DEBUG AnimalRepository: Fallback al sistema antiguo');
        return await _animalDao.fetchAnimalsFromDb();
      }
    } catch (e) {
      print('Error in getAnimals: $e');
      
      // En caso de error, intentar usar datos offline
      try {
        final offlineData = await _offlineService.getAnimalsOffline();
        if (offlineData.isNotEmpty) {
          return offlineData.map((data) => _mapFromOfflineFormat(data)).toList();
        }
        
        // Fallback al sistema antiguo
        return await _animalDao.fetchAnimalsFromDb();
      } catch (offlineError) {
        print('Error accessing offline data: $offlineError');
        return [];
      }
    }
  }

  // Crear un animal
  Future<void> createAnimal(AnimalDto animal, File imageFile) async {
    try {
      if (_connectivityService.isConnected) {
        // Con conexión, crear en el servidor
        await _animalsService.createAnimal(animal, imageFile);
        // Actualizar caché local
        await getAnimals();
      } else {
        // Sin conexión, guardar offline para sincronizar después
        await _offlineService.saveAnimalOffline(_mapToOfflineFormat(animal));
        await TokenService.instance.setHasOfflineData(true);
        print('Animal guardado offline para sincronización posterior');
      }
    } catch (e) {
      // En caso de error, guardar offline
      await _offlineService.saveAnimalOffline(_mapToOfflineFormat(animal));
      await TokenService.instance.setHasOfflineData(true);
      print('Error creating animal, saved offline: $e');
      rethrow;
    }
  }

  Future<void> updateAnimal(int id, Map<String, dynamic> data) async {
    try {
      if (_connectivityService.isConnected) {
        await AnimalsService().updateAnimal(id, data);
      } else {
        // Sin conexión, guardar cambios offline
        final offlineData = _mapToOfflineFormat(AnimalDto.fromJson({...data, 'id': id}));
        await _offlineService.saveAnimalOffline(offlineData);
        await TokenService.instance.setHasOfflineData(true);
        print('Animal update guardado offline para sincronización posterior');
      }
    } catch (e) {
      // En caso de error, guardar offline
      final offlineData = _mapToOfflineFormat(AnimalDto.fromJson({...data, 'id': id}));
      await _offlineService.saveAnimalOffline(offlineData);
      await TokenService.instance.setHasOfflineData(true);
      print('Error updating animal, saved offline: $e');
      rethrow;
    }
  }

  // Eliminar un animal
  Future<void> deleteAnimal(int id) async {
    try {
      if (_connectivityService.isConnected) {
        await _animalsService.deleteAnimal(id);
        await getAnimals();
      } else {
        // Sin conexión, marcar para eliminación offline
        // Esto requeriría una implementación más compleja en el offline service
        print('Animal deletion will be synced when connection is restored');
        throw Exception('No se puede eliminar sin conexión. Intenta cuando tengas internet.');
      }
    } catch (e) {
      print('Error deleting animal: $e');
      rethrow;
    }
  }

  // Obtener un animal por ID
  Future<AnimalDto> getAnimalById(int id) async {
    try {
      if (_connectivityService.isConnected) {
        return await _animalsService.fetchAnimalById(id);
      } else {
        // Buscar en datos offline
        final offlineAnimals = await _offlineService.getAnimalsOffline();
        final animal = offlineAnimals.firstWhere(
          (data) => data['id'] == id || data['server_id'] == id,
          orElse: () => throw Exception('Animal no encontrado offline'),
        );
        return _mapFromOfflineFormat(animal);
      }
    } catch (e) {
      print('Error getting animal by ID: $e');
      rethrow;
    }
  }

  // Obtener animales por stableId
  Future<List<AnimalDto>> getAnimalsByStableId(int stableId) async {
    try {
      if (_connectivityService.isConnected) {
        return await _animalsService.fetchAnimalByStableId(stableId);
      } else {
        // Filtrar datos offline por stableId
        final offlineAnimals = await _offlineService.getAnimalsOffline();
        final filteredAnimals = offlineAnimals.where(
          (data) => data['stable_id'] == stableId || data['stableId'] == stableId,
        ).toList();
        
        return filteredAnimals.map((data) => _mapFromOfflineFormat(data)).toList();
      }
    } catch (e) {
      print('Error getting animals by stable ID: $e');
      
      // Fallback: buscar en datos offline
      try {
        final offlineAnimals = await _offlineService.getAnimalsOffline();
        final filteredAnimals = offlineAnimals.where(
          (data) => data['stable_id'] == stableId || data['stableId'] == stableId,
        ).toList();
        
        return filteredAnimals.map((data) => _mapFromOfflineFormat(data)).toList();
      } catch (offlineError) {
        print('Error accessing offline data: $offlineError');
        return [];
      }
    }
  }

  /// Verificar si hay datos offline disponibles
  Future<bool> hasOfflineData() async {
    try {
      final offlineAnimals = await _offlineService.getAnimalsOffline();
      return offlineAnimals.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Obtener estadísticas de datos offline
  Future<Map<String, int>> getOfflineStats() async {
    return await _offlineService.getOfflineStats();
  }

  /// Mapear AnimalDto al formato del OfflineDataService
  Map<String, dynamic> _mapToOfflineFormat(AnimalDto animal) {
    return {
      'server_id': animal.id,
      'name': animal.name,
      'type': animal.gender, // Mapear gender a type
      'breed': animal.breed,
      'birth_date': animal.birthDate,
      'image_url': animal.bovineImg,
      'notes': animal.location,
      'stable_id': animal.stableId,
    };
  }

  /// Mapear del formato offline a AnimalDto
  AnimalDto _mapFromOfflineFormat(Map<String, dynamic> data) {
    return AnimalDto(
      id: data['server_id'] ?? data['id'] ?? 0,
      name: data['name'] ?? '',
      gender: data['type'] ?? data['gender'] ?? '', // Mapear type de vuelta a gender
      birthDate: data['birth_date'] ?? data['birthDate'] ?? '',
      breed: data['breed'] ?? '',
      location: data['notes'] ?? data['location'] ?? '',
      bovineImg: data['image_url'] ?? data['bovineImg'] ?? '',
      stableId: data['stable_id'] ?? data['stableId'] ?? 0,
    );
  }
}