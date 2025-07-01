import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vacapp/features/stables/data/datasources/stables_service.dart';
import 'package:vacapp/features/vaccines/data/datasources/vaccines_services.dart';
import 'package:vacapp/features/animals/data/dataasources/animals_service.dart';
import 'package:vacapp/features/stables/data/models/stable_dto.dart';
import 'package:vacapp/features/vaccines/data/models/vaccines_dto.dart';
import 'package:vacapp/features/animals/data/models/animal_dto.dart';

// Events
abstract class StatisticsEvent {
  const StatisticsEvent();
}

class LoadStatistics extends StatisticsEvent {}

class RefreshStatistics extends StatisticsEvent {}

// States
abstract class StatisticsState {
  const StatisticsState();
}

class StatisticsInitial extends StatisticsState {}

class StatisticsLoading extends StatisticsState {}

class StatisticsLoaded extends StatisticsState {
  final HomeStatistics statistics;

  const StatisticsLoaded(this.statistics);
}

class StatisticsError extends StatisticsState {
  final String message;

  const StatisticsError(this.message);
}

// Data Model
class HomeStatistics {
  final List<StableDto> stables;
  final List<VaccinesDto> vaccines;
  final List<AnimalDto> animals;

  const HomeStatistics({
    required this.stables,
    required this.vaccines,
    required this.animals,
  });

  // Estadísticas de establos
  int get totalStables => stables.length;
  int get totalAnimals => animals.length;
  int get totalCapacity => stables.fold(0, (sum, stable) => sum + stable.limit);
  double get occupationPercentage {
    if (totalCapacity == 0) return 0.0;
    return (totalAnimals / totalCapacity * 100);
  }

  // Estadísticas de género
  int get maleAnimals => animals.where((animal) => 
    animal.gender.toLowerCase() == 'macho' || 
    animal.gender.toLowerCase() == 'm' ||
    animal.gender.toLowerCase() == 'male'
  ).length;
  
  int get femaleAnimals => animals.where((animal) => 
    animal.gender.toLowerCase() == 'hembra' || 
    animal.gender.toLowerCase() == 'h' ||
    animal.gender.toLowerCase() == 'female'
  ).length;

  // Estadísticas de vacunas
  int get totalVaccines => vaccines.length;
  int get appliedVaccines => vaccines.where((v) => v.vaccineDate.isNotEmpty).length;
  int get pendingVaccines => totalVaccines - appliedVaccines;
  
  Set<int> get animalIdsWithVaccines => vaccines.map((v) => v.bovineId).toSet();
  int get animalsWithVaccines => animalIdsWithVaccines.length;
  int get animalsWithoutVaccines => totalAnimals - animalsWithVaccines;

  // Lista de animales sin vacuna
  List<AnimalDto> get animalsWithoutVaccinesList {
    final vaccinatedAnimalIds = animalIdsWithVaccines;
    return animals.where((animal) => !vaccinatedAnimalIds.contains(animal.id)).toList();
  }

  // Estadísticas por raza
  Map<String, int> get breedDistribution {
    final Map<String, int> distribution = {};
    for (final animal in animals) {
      distribution[animal.breed] = (distribution[animal.breed] ?? 0) + 1;
    }
    return distribution;
  }

  // Estadísticas por establo
  Map<int, int> get animalsPerStable {
    final Map<int, int> distribution = {};
    for (final animal in animals) {
      distribution[animal.stableId] = (distribution[animal.stableId] ?? 0) + 1;
    }
    return distribution;
  }

  // Porcentaje de vacunación
  double get vaccinationPercentage {
    if (totalAnimals == 0) return 0.0;
    return (animalsWithVaccines / totalAnimals * 100);
  }

  // Estadísticas detalladas de vacunas
  Map<String, int> get vaccineTypesDistribution {
    final Map<String, int> distribution = {};
    for (final vaccine in vaccines) {
      final type = vaccine.vaccineType.isNotEmpty ? vaccine.vaccineType : 'Sin tipo';
      distribution[type] = (distribution[type] ?? 0) + 1;
    }
    return distribution;
  }

  List<String> get topVaccineTypes {
    final distribution = vaccineTypesDistribution;
    final sortedEntries = distribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedEntries.take(3).map((e) => e.key).toList();
  }

  // Estadísticas detalladas de establos
  double get avgAnimalsPerStable {
    if (totalStables == 0) return 0.0;
    return totalAnimals / totalStables;
  }

  int get mostPopulatedStableCount {
    final distribution = animalsPerStable;
    if (distribution.isEmpty) return 0;
    return distribution.values.reduce((a, b) => a > b ? a : b);
  }

  double get stableUtilizationPercentage {
    if (totalCapacity == 0) return 0.0;
    return (totalAnimals / totalCapacity) * 100;
  }

  // Estadísticas especiales de establos
  List<int> get fullStables {
    final avgCapacity = totalCapacity / totalStables;
    return animalsPerStable.entries
        .where((entry) => entry.value >= avgCapacity)
        .map((entry) => entry.key)
        .toList();
  }

  List<int> get emptyStables {
    final allStableIds = stables.map((s) => s.id).toSet();
    final occupiedStableIds = animalsPerStable.keys.toSet();
    return allStableIds.difference(occupiedStableIds).toList();
  }

  List<int> get lowOccupancyStables {
    final avgCapacity = totalCapacity / totalStables;
    return animalsPerStable.entries
        .where((entry) => entry.value > 0 && entry.value < (avgCapacity * 0.5))
        .map((entry) => entry.key)
        .toList();
  }

  int get mostPopulatedStableId {
    if (animalsPerStable.isEmpty) return 0;
    return animalsPerStable.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  // Estadísticas detalladas de vacunas
  int get recentVaccines {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    return vaccines.where((vaccine) {
      if (vaccine.vaccineDate.isEmpty) return false;
      try {
        final vaccineDate = DateTime.parse(vaccine.vaccineDate);
        return vaccineDate.isAfter(thirtyDaysAgo);
      } catch (e) {
        return false;
      }
    }).length;
  }

  Map<String, int> get vaccinesByMonth {
    final Map<String, int> distribution = {};
    
    for (final vaccine in vaccines) {
      if (vaccine.vaccineDate.isEmpty) continue;
      try {
        final vaccineDate = DateTime.parse(vaccine.vaccineDate);
        final monthKey = '${vaccineDate.year}-${vaccineDate.month.toString().padLeft(2, '0')}';
        distribution[monthKey] = (distribution[monthKey] ?? 0) + 1;
      } catch (e) {
        // Ignorar fechas mal formateadas
      }
    }
    return distribution;
  }

  // Estadísticas de animales en estados especiales
  int get animalsInQuarantine => animals.where((animal) => 
    animal.location.toLowerCase().contains('cuarentena') ||
    animal.location.toLowerCase().contains('quarantine') ||
    animal.location.toLowerCase().contains('aislado')
  ).length;

  int get animalsInMaternity => animals.where((animal) => 
    animal.location.toLowerCase().contains('maternidad') ||
    animal.location.toLowerCase().contains('maternity') ||
    animal.location.toLowerCase().contains('parto') ||
    animal.location.toLowerCase().contains('gestante')
  ).length;

  int get animalsWithVetAppointment => animals.where((animal) => 
    animal.location.toLowerCase().contains('veterinario') ||
    animal.location.toLowerCase().contains('veterinary') ||
    animal.location.toLowerCase().contains('consulta') ||
    animal.location.toLowerCase().contains('tratamiento')
  ).length;

  // Listas de animales en estados especiales
  List<AnimalDto> get animalsInQuarantineList => animals.where((animal) => 
    animal.location.toLowerCase().contains('cuarentena') ||
    animal.location.toLowerCase().contains('quarantine') ||
    animal.location.toLowerCase().contains('aislado')
  ).toList();

  List<AnimalDto> get animalsInMaternityList => animals.where((animal) => 
    animal.location.toLowerCase().contains('maternidad') ||
    animal.location.toLowerCase().contains('maternity') ||
    animal.location.toLowerCase().contains('parto') ||
    animal.location.toLowerCase().contains('gestante')
  ).toList();

  List<AnimalDto> get animalsWithVetAppointmentList => animals.where((animal) => 
    animal.location.toLowerCase().contains('veterinario') ||
    animal.location.toLowerCase().contains('veterinary') ||
    animal.location.toLowerCase().contains('consulta') ||
    animal.location.toLowerCase().contains('tratamiento')
  ).toList();
}

// Bloc
class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final StablesService _stablesService;
  final VaccinesService _vaccinesService;
  final AnimalsService _animalsService;

  StatisticsBloc({
    StablesService? stablesService,
    VaccinesService? vaccinesService,
    AnimalsService? animalsService,
  })  : _stablesService = stablesService ?? StablesService(),
        _vaccinesService = vaccinesService ?? VaccinesService(),
        _animalsService = animalsService ?? AnimalsService(),
        super(StatisticsInitial()) {
    on<LoadStatistics>(_onLoadStatistics);
    on<RefreshStatistics>(_onRefreshStatistics);
  }

  Future<void> _onLoadStatistics(
    LoadStatistics event,
    Emitter<StatisticsState> emit,
  ) async {
    await _loadData(emit);
  }

  Future<void> _onRefreshStatistics(
    RefreshStatistics event,
    Emitter<StatisticsState> emit,
  ) async {
    await _loadData(emit);
  }

  Future<void> _loadData(Emitter<StatisticsState> emit) async {
    try {
      emit(StatisticsLoading());

      // Cargar datos en paralelo
      final futures = await Future.wait([
        _stablesService.fetchStables(),
        _vaccinesService.fetchVaccines(),
        _animalsService.fetchAnimals(),
      ]);

      final stables = futures[0] as List<StableDto>;
      final vaccines = futures[1] as List<VaccinesDto>;
      final animals = futures[2] as List<AnimalDto>;

      final statistics = HomeStatistics(
        stables: stables,
        vaccines: vaccines,
        animals: animals,
      );

      emit(StatisticsLoaded(statistics));
    } catch (e) {
      emit(StatisticsError('Error al cargar las estadísticas: $e'));
    }
  }
}
