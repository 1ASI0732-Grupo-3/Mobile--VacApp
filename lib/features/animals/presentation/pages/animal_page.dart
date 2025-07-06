import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:vacapp/features/animals/data/dataasources/animals_service.dart';
import 'package:vacapp/features/animals/data/dataasources/animal_dao.dart';
import 'package:vacapp/features/animals/data/models/animal_dto.dart';
import 'package:vacapp/features/animals/data/repositories/animal_repository.dart';
import 'package:vacapp/features/animals/presentation/pages/animal_details_page.dart';
import 'package:vacapp/features/animals/presentation/pages/create_animal_page.dart';
import 'package:vacapp/features/animals/presentation/pages/delete_animal.dart';
import 'package:vacapp/features/animals/presentation/pages/update_animal_page.dart';
import 'package:vacapp/features/stables/data/models/stable_dto.dart';
import 'package:vacapp/features/stables/data/datasources/stables_service.dart';
import 'package:vacapp/features/vaccines/data/repositories/vaccines_repository.dart';
import 'package:vacapp/features/vaccines/data/datasources/vaccines_services.dart';

class AnimalPage extends StatefulWidget {
  const AnimalPage({super.key});

  @override
  State<AnimalPage> createState() => _AnimalPageState();
}

class _AnimalPageState extends State<AnimalPage> {
  late final AnimalRepository _repository;
  late final VaccinesRepository _vaccinesRepository;
  late Future<List<AnimalDto>> _futureAnimals;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<AnimalDto> _allAnimals = [];
  List<AnimalDto> _filteredAnimals = [];
  List<StableDto> _stables = [];
  bool _stablesLoaded = false;
  bool _showTitle = true;
  
  // Map para almacenar el conteo de vacunas por animal
  Map<int, int> _vaccineCountByAnimal = {};

  @override
  void initState() {
    super.initState();
    _repository = AnimalRepository(AnimalsService(), AnimalDao());
    _vaccinesRepository = VaccinesRepository(VaccinesService());
    _futureAnimals = _repository.getAnimals();
    _searchController.addListener(_onSearchChanged);
    _loadStables();
    _loadVaccinesForAllAnimals();
    
    // Listener para controlar la visibilidad del título con animación ultra suave
    _scrollController.addListener(() {
      const threshold = 120.0; // Píxeles de scroll para ocultar el título (más gradual)
      final shouldShowTitle = _scrollController.offset <= threshold;
      
      if (shouldShowTitle != _showTitle) {
        setState(() {
          _showTitle = shouldShowTitle;
        });
      }
    });
  }

  Future<void> _loadStables() async {
    try {
      final stablesService = StablesService();
      final stables = await stablesService.fetchStables();
      if (mounted) {
        setState(() {
          _stables = stables;
          _stablesLoaded = true;
        });
      }
    } catch (e) {
      // En caso de error, seguir funcionando solo con IDs
      if (mounted) {
        setState(() {
          _stablesLoaded = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredAnimals = _allAnimals.where((animal) {
        final genderInSpanish = _getGenderDisplay(animal.gender).toLowerCase();
        return animal.name.toLowerCase().contains(query) ||
               animal.breed.toLowerCase().contains(query) ||
               animal.gender.toLowerCase().contains(query) ||
               genderInSpanish.contains(query);
      }).toList();
    });
  }

  // Función para mostrar el género en español
  String _getGenderDisplay(String gender) {
    return gender.toLowerCase() == 'male' ? 'Macho' : 'Hembra';
  }

  // Función para detectar si un animal está en cuarentena
  bool _isInQuarantine(AnimalDto animal) {
    // Verificar por ID conocido
    if (animal.stableId == 6) return true;
    
    // Verificar por nombre del establo si los establos están cargados
    if (_stablesLoaded && _stables.isNotEmpty) {
      try {
        final stable = _stables.firstWhere((s) => s.id == animal.stableId);
        return stable.name.toLowerCase().contains('cuarentena');
      } catch (e) {
        // El establo no se encontró en la lista
        return false;
      }
    }
    
    return false;
  }

  // Función para detectar si un animal está en cuidados veterinarios
  bool _isInVeterinaryCare(AnimalDto animal) {
    // Verificar por ID conocido
    if (animal.stableId == 24) return true;
    
    // Verificar por nombre del establo si los establos están cargados
    if (_stablesLoaded && _stables.isNotEmpty) {
      try {
        final stable = _stables.firstWhere((s) => s.id == animal.stableId);
        final stableName = stable.name.toLowerCase();
        return stableName.contains('veterinarios') || 
               stableName.contains('c.veterinarios') ||
               stableName.contains('cuidados veterinarios');
      } catch (e) {
        // El establo no se encontró en la lista
        return false;
      }
    }
    
    return false;
  }

  // Función para detectar si un animal está en maternidad
  bool _isInMaternity(AnimalDto animal) {
    // Verificar por nombre del establo si los establos están cargados
    if (_stablesLoaded && _stables.isNotEmpty) {
      try {
        final stable = _stables.firstWhere((s) => s.id == animal.stableId);
        return stable.name.toLowerCase().contains('maternidad');
      } catch (e) {
        // El establo no se encontró en la lista
        return false;
      }
    }
    
    return false;
  }

  Future<void> _refreshAnimals() async {
    final animals = await _repository.getAnimals();
    setState(() {
      _allAnimals = animals;
      _filteredAnimals = animals;
    });
    // Recargar vacunas cuando se actualicen los animales
    _loadVaccinesForAllAnimals();
  }

  Future<void> _loadVaccinesForAllAnimals() async {
    try {
      final vaccines = await _vaccinesRepository.getVaccines();
      final Map<int, int> vaccineCount = {};
      
      // Contar vacunas por animal
      for (var vaccine in vaccines) {
        vaccineCount[vaccine.bovineId] = (vaccineCount[vaccine.bovineId] ?? 0) + 1;
      }
      
      if (mounted) {
        setState(() {
          _vaccineCountByAnimal = vaccineCount;
        });
      }
    } catch (e) {
      print('❌ [DEBUG] Error loading vaccines: $e');
      // En caso de error, mantener el mapa vacío
      if (mounted) {
        setState(() {
          _vaccineCountByAnimal = {};
        });
      }
    }
  }

  int _getVaccineCount(int animalId) {
    return _vaccineCountByAnimal[animalId] ?? 0;
  }

  Future<void> _goToCreate() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateAnimalPage(repository: _repository),
      ),
    );
    if (result == true) await _refreshAnimals();
  }

  Future<void> _goToEdit(AnimalDto animal) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditAnimalPage(repository: _repository, animal: animal),
      ),
    );
    if (result == true) await _refreshAnimals();
  }

  Future<void> _goToDelete(int animalId) async {
    await showDeleteAnimalDialog(
      context: context,
      animalId: animalId,
      repository: _repository,
    );
    await _refreshAnimals();
  }

  // Animación de carga moderna y simplificada
  Widget _buildModernLoadingAnimation() {
    const primary = Color(0xFF002D26);
    const cardColor = Color(0xFFFDF6F1);
    
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icono principal simple con pulso suave
            TweenAnimationBuilder<double>(
              duration: const Duration(seconds: 2),
              tween: Tween(begin: 0.9, end: 1.1),
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.pets_rounded,
                      size: 40,
                      color: primary,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            
            // Texto centrado simple
            const Text(
              'Cargando animales',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            Text(
              'Preparando información...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Barra de progreso visual y atractiva
            Container(
              width: 250,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(3),
              ),
              child: TweenAnimationBuilder<double>(
                duration: const Duration(seconds: 3),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Stack(
                    children: [
                      // Barra de progreso con gradiente
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 250 * value,
                        height: 6,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primary,
                              primary.withOpacity(0.7),
                              primary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      
                      // Efecto de brillo sutil
                      if (value > 0.1)
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 200),
                          left: (250 * value) - 30,
                          child: Container(
                            width: 30,
                            height: 6,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.0),
                                  Colors.white.withOpacity(0.5),
                                  Colors.white.withOpacity(0.0),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            
            // Porcentaje centrado
            TweenAnimationBuilder<double>(
              duration: const Duration(seconds: 3),
              tween: Tween(begin: 0.0, end: 100.0),
              builder: (context, percentage, child) {
                return Text(
                  '${percentage.toInt()}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: primary.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Card moderno de animal con alerta crítica si no tiene vacunas
  Widget _buildAnimalCard(AnimalDto animal, int index) {
    const primary = Color(0xFF00695C);
    const lightGreen = Color(0xFFE8F5E8);
    const accent = Color(0xFF4CAF50);
    
    // Verificar si el bovino no tiene vacunas - CRÍTICO
    final vaccineCount = _getVaccineCount(animal.id);
    final isUnvaccinated = vaccineCount == 0;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  // Si no tiene vacunas, sombra roja suave
                  if (isUnvaccinated) ...[
                    BoxShadow(
                      color: const Color(0xFFFFEBEE).withOpacity(0.8),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: const Color(0xFFE57373).withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ] else ...[
                    // Sombra normal
                    BoxShadow(
                      color: primary.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ],
                border: Border.all(
                  // Borde rojo suave si no tiene vacunas
                  color: isUnvaccinated 
                    ? const Color(0xFFEF9A9A).withOpacity(0.6)
                    : lightGreen.withOpacity(0.3),
                  width: isUnvaccinated ? 2 : 1,
                ),
              ),
              child: Stack(
                children: [
                  // Banner de alerta crítica con animación pulsante
                  if (isUnvaccinated)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: TweenAnimationBuilder<double>(
                        duration: const Duration(seconds: 2),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, animValue, child) {
                          return AnimatedContainer(
                            duration: Duration(milliseconds: 1000 + (animValue * 200).toInt()),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color.lerp(const Color(0xFFFFCDD2), const Color(0xFFFF8A80), 
                                    (animValue * 0.3))!,
                                  Color.lerp(const Color(0xFFFFEBEE), const Color(0xFFFFCDD2), 
                                    (animValue * 0.2))!,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(24),
                                topRight: Radius.circular(24),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF8A80).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Icono de advertencia con animación de escala y rotación
                                TweenAnimationBuilder<double>(
                                  duration: const Duration(milliseconds: 1500),
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  builder: (context, scale, child) {
                                    return Transform.scale(
                                      scale: 0.9 + (scale * 0.3),
                                      child: Transform.rotate(
                                        angle: scale * 0.1,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFD32F2F).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.health_and_safety_outlined,
                                            color: Color(0xFFD32F2F),
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 10),
                                // Texto con efecto de typing
                                TweenAnimationBuilder<int>(
                                  duration: const Duration(milliseconds: 2000),
                                  tween: IntTween(begin: 0, end: 28),
                                  builder: (context, charCount, child) {
                                    final text = 'RIESGO ALTO';
                                    final displayText = text.substring(0, 
                                      charCount.clamp(0, text.length));
                                    return Text(
                                      displayText,
                                      style: const TextStyle(
                                        color: Color(0xFFD32F2F),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.8,
                                        shadows: [
                                          Shadow(
                                            color: Color(0xFFFFCDD2),
                                            offset: Offset(1, 1),
                                            blurRadius: 2,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  
                  // Contenido principal de la tarjeta
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      20, 
                      isUnvaccinated ? 68 : 20, // Más espacio arriba para el banner mejorado
                      20, 
                      20
                    ),
                    child: Column(
                      children: [
                        // Header del card con imagen y acciones
                        Row(
                          children: [
                            // Imagen del animal con borde de alerta
                            Hero(
                              tag: 'animal_${animal.id}',
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: isUnvaccinated ? Border.all(
                                    color: const Color(0xFFEF9A9A).withOpacity(0.6),
                                    width: 2,
                                  ) : null,
                                  boxShadow: [
                                    BoxShadow(
                                      color: isUnvaccinated 
                                        ? const Color(0xFFE57373).withOpacity(0.3)
                                        : Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    animal.bovineImg,
                                    height: 90,
                                    width: 90,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      height: 90,
                                      width: 90,
                                      decoration: BoxDecoration(
                                        color: isUnvaccinated 
                                          ? const Color(0xFFFFCDD2).withOpacity(0.8)
                                          : lightGreen.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Icon(
                                        Icons.pets_rounded,
                                        size: 40,
                                        color: isUnvaccinated 
                                          ? const Color(0xFFE57373).withOpacity(0.8)
                                          : primary.withOpacity(0.7),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            
                            // Información del animal
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Badge de tipo
                                  _buildAnimalTypeLabel(animal),
                                  const SizedBox(height: 8),
                                  
                                  // Nombre del animal
                                  Text(
                                    animal.name,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: isUnvaccinated ? const Color(0xFFD32F2F) : primary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  
                                  // Información adicional
                                  Row(
                                    children: [
                                      Icon(
                                        animal.gender.toLowerCase() == 'male' 
                                            ? Icons.male_rounded 
                                            : Icons.female_rounded,
                                        size: 16,
                                        color: Colors.grey.shade600,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          '${_getGenderDisplay(animal.gender)} • ${animal.breed}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  
                                  // Indicador de vacunas crítico
                                  _buildVaccineIndicator(animal),
                                ],
                              ),
                            ),
                          ],
                        ),
                    
                    const SizedBox(height: 20),
                    
                    // Botones de acción modernos
                    Row(
                      children: [
                        // Botón Ver Detalles
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [primary, primary.withOpacity(0.8)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => AnimalDetailsPage(
                                        animal: animal.toDomain(),
                                      ),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.visibility_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Ver más',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        // Botón Editar
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: accent,
                                width: 2,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _goToEdit(animal),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.edit_rounded,
                                        color: accent,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Editar',
                                        style: TextStyle(
                                          color: accent,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        // Botón Eliminar
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.red.shade300,
                              width: 1.5,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _goToDelete(animal.id),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                child: Icon(
                                  Icons.delete_rounded,
                                  color: Colors.red.shade600,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ],
            ),
          ),
          )
        );
      },
    );
  }

  // Función para crear el badge especial junto al label "Bovino"
  Widget _buildAnimalTypeLabel(AnimalDto animal) {
    const primary = Color(0xFF00695C);
    const lightGreen = Color(0xFFE8F5E8);
    
    bool isQuarantine = _isInQuarantine(animal);
    bool isVeterinary = _isInVeterinaryCare(animal);
    bool isMaternity = _isInMaternity(animal);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label principal "Bovino"
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                lightGreen.withOpacity(0.8),
                lightGreen.withOpacity(0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: const Text(
            'Bovino',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: primary,
            ),
          ),
        ),
        
        // Badge especial si está en cuarentena, cuidados veterinarios o maternidad
        if (isQuarantine || isVeterinary || isMaternity) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: isQuarantine 
                  ? const Color(0xFFFF5722).withOpacity(0.1) // Naranja para cuarentena
                  : isMaternity 
                    ? Colors.pink.withOpacity(0.1) // Rosa para maternidad
                    : const Color(0xFF2196F3).withOpacity(0.1), // Azul para veterinario
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isQuarantine 
                    ? const Color(0xFFFF5722).withOpacity(0.3)
                    : isMaternity 
                      ? Colors.pink.withOpacity(0.3)
                      : const Color(0xFF2196F3).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isQuarantine 
                    ? Icons.warning_rounded 
                    : isMaternity 
                      ? Icons.pregnant_woman_rounded
                      : Icons.medical_services_rounded,
                  size: 12,
                  color: isQuarantine 
                      ? const Color(0xFFFF5722)
                      : isMaternity 
                        ? Colors.pink
                        : const Color(0xFF2196F3),
                ),
                const SizedBox(width: 4),
                Text(
                  isQuarantine 
                    ? 'Cuarentena' 
                    : isMaternity 
                      ? 'Maternidad' 
                      : 'C. Veterinarios',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isQuarantine 
                        ? const Color(0xFFFF5722)
                        : isMaternity 
                          ? Colors.pink
                          : const Color(0xFF2196F3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // Indicador de vacunas - CRÍTICO cuando no tiene
  Widget _buildVaccineIndicator(AnimalDto animal) {
    const primary = Color(0xFF00695C);
    const lightGreen = Color(0xFFE8F5E8);
    
    final vaccineCount = _getVaccineCount(animal.id);
    
    if (vaccineCount == 0) {
      // ⚠️ ALERTA CRÍTICA - BOVINO SIN VACUNAS - SUPER LLAMATIVO
      return TweenAnimationBuilder<double>(
        duration: const Duration(seconds: 3),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, animationValue, child) {
          // Efecto de pulsación suave
          final pulseScale = 1.0 + (math.sin(animationValue * 6.28 * 2) * 0.05);
          
          return Transform.scale(
            scale: pulseScale,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFFECB3).withOpacity(0.95), // Amarillo muy suave
                    const Color(0xFFFFE0B2).withOpacity(0.85), // Naranja muy suave
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFFF8F00).withOpacity(0.7), // Borde naranja vibrante
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF8F00).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: const Color(0xFFFFE0B2).withOpacity(0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Fila principal con iconos y texto
                  Row(
                    children: [                      
                      // Texto principal con efecto de aparición gradual
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TweenAnimationBuilder<int>(
                              duration: const Duration(milliseconds: 1500),
                              tween: IntTween(begin: 0, end: 20),
                              builder: (context, charCount, child) {
                                final text = 'BOVINO SIN VACUNAS';
                                final displayText = text.substring(0, 
                                  charCount.clamp(0, text.length));
                                return Text(
                                  displayText,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFE65100),
                                    letterSpacing: 0.6,
                                    shadows: [
                                      Shadow(
                                        color: Color(0xFFFFE0B2),
                                        offset: Offset(1, 1),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Requiere vacunación urgente',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFBF360C).withOpacity(0.8),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Iconos laterales con animación escalonada
                      Column(
                        children: [
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 1000),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, scale, child) {
                              return Transform.scale(
                                scale: 0.7 + (scale * 0.4),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE65100).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(
                                    Icons.warning_amber_rounded,
                                    size: 18,
                                    color: Color(0xFFE65100),
                                  ),
                                ),
                              );
                            },
                          ),                        
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Mensaje final con badge de prioridad mejorado
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE65100),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE65100).withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Text(
                          'PRIORIDAD ALTA',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      // Mostrar contador positivo de vacunas
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: lightGreen.withOpacity(0.8),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.vaccines_rounded,
              size: 16,
              color: primary,
            ),
            const SizedBox(width: 6),
            Text(
              '$vaccineCount ${vaccineCount == 1 ? 'vacuna' : 'vacunas'}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: primary,
              ),
            ),
          ],
        ),
      );
    }
  }

  // Estado vacío mejorado
  Widget _buildEmptyState() {
    const primary = Color(0xFF00695C);
    const lightGreen = Color(0xFFE8F5E8);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  lightGreen.withOpacity(0.8),
                  lightGreen.withOpacity(0.4),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.pets_rounded,
              size: 80,
              color: primary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'No hay bovinos registrados',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Comienza agregando tu primer bovino',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primary, primary.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _goToCreate,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Agregar Bovino',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Estado de error mejorado
  Widget _buildErrorState(String error) {
    const primary = Color(0xFF00695C);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 80,
              color: Colors.red.shade400,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Error al cargar bovinos',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _futureAnimals = _repository.getAnimals();
              });
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Colores institucionales modernos
    const primary = Color(0xFF00695C);
    const lightGreen = Color(0xFFE8F5E8);
    const accent = Color(0xFF4CAF50);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFF8F9FA),
              lightGreen.withOpacity(0.3),
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: FutureBuilder<List<AnimalDto>>(
            future: _futureAnimals,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildModernLoadingAnimation();
              }
              if (snapshot.hasError) {
                return _buildErrorState(snapshot.error.toString());
              }

              if (_allAnimals.isEmpty && snapshot.hasData) {
                _allAnimals = snapshot.data!;
                _filteredAnimals = _allAnimals;
              }

              if (_filteredAnimals.isEmpty) {
                return _buildEmptyState();
              }

              return Column(
                children: [
                  // Header moderno con animación de ocultación ultra suave
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 800), // Duración más larga para suavidad
                    curve: Curves.easeInOutCubicEmphasized, // Curva más suave y elegante
                    height: _showTitle ? null : 0,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 700), // Fade más gradual
                      curve: Curves.easeInOutQuint, // Curva muy suave para opacidad
                      opacity: _showTitle ? 1.0 : 0.0,
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeInOutCubicEmphasized,
                        scale: _showTitle ? 1.0 : 0.95, // Escala sutil
                        child: AnimatedSlide(
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeInOutCubicEmphasized,
                          offset: _showTitle ? Offset.zero : const Offset(0, -0.2), // Deslizamiento más sutil
                          child: Container(
                            margin: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: primary.withOpacity(0.15),
                                  blurRadius: 25,
                                  offset: const Offset(0, 8),
                                ),
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                              border: Border.all(
                                color: lightGreen.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                              child: Row(
                                children: [
                                  // Icono de la sección
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          primary.withOpacity(0.15),
                                          accent.withOpacity(0.1),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(
                                      Icons.pets_rounded,
                                      color: primary,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  
                                  // Título y descripción
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Gestión de Bovinos',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: primary,
                                          ),
                                        ),
                                        Text(
                                          'Administra tu ganado bovino',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Contador de animales
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          lightGreen.withOpacity(0.8),
                                          lightGreen.withOpacity(0.6),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: primary.withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Total: ',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${_filteredAnimals.length}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Barra de búsqueda y botón de agregar con transición ultra suave
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 700), // Sincronizado con el header
                    curve: Curves.easeInOutCubicEmphasized,
                    margin: EdgeInsets.fromLTRB(20, _showTitle ? 0 : 20, 20, 0),
                    child: AnimatedSlide(
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeInOutCubicEmphasized,
                      offset: _showTitle ? Offset.zero : const Offset(0, -0.1), // Movimiento más sutil
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeInOutCubicEmphasized,
                        scale: _showTitle ? 1.0 : 1.02, // Escala ligeramente hacia arriba
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: lightGreen.withOpacity(0.3),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withOpacity(0.08),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "Buscar por nombre, raza o género...",
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 14,
                                    ),
                                    prefixIcon: Container(
                                      margin: const EdgeInsets.all(8),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.search_rounded,
                                        color: primary,
                                        size: 20,
                                      ),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    primary,
                                    primary.withOpacity(0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: primary.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: _goToCreate,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.add_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Agregar',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Lista de animales
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _filteredAnimals.length,
                      itemBuilder: (context, index) {
                        final animal = _filteredAnimals[index];
                        return _buildAnimalCard(animal, index);
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}