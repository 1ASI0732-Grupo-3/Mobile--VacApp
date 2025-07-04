import 'package:flutter/material.dart';
import 'package:vacapp/features/animals/data/models/animal_dto.dart';
import 'package:vacapp/core/services/offline_data_service.dart';

class OfflineAnimalsPage extends StatefulWidget {
  const OfflineAnimalsPage({super.key});

  @override
  State<OfflineAnimalsPage> createState() => _OfflineAnimalsPageState();
}

class _OfflineAnimalsPageState extends State<OfflineAnimalsPage> {
  final OfflineDataService _offlineService = OfflineDataService();
  List<AnimalDto> _animals = [];
  bool _isLoading = true;
  String? _error;

  // Paleta de colores actualizada
  static const Color primary = Color(0xFF2E7D32);
  static const Color accent = Color(0xFF66BB6A);

  @override
  void initState() {
    super.initState();
    _loadOfflineAnimals();
  }

  Future<void> _loadOfflineAnimals() async {
    print('DEBUG: Cargando animales offline...');
    try {
      final offlineData = await _offlineService.getAnimalsOffline();
      print('DEBUG: Datos offline obtenidos: ${offlineData.length} registros');
      
      if (offlineData.isNotEmpty) {
        print('DEBUG: Primer registro: ${offlineData.first}');
      }
      
      final animals = offlineData.map((data) => _mapFromOfflineFormat(data)).toList();
      print('DEBUG: Animales mapeados: ${animals.length}');
      
      if (animals.isNotEmpty) {
        print('DEBUG: Primer animal mapeado: ${animals.first.name} - ${animals.first.breed}');
      }
      
      if (mounted) {
        setState(() {
          _animals = animals;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('DEBUG: Error al cargar animales offline: $e');
      if (mounted) {
        setState(() {
          _error = 'Error al cargar bovinos guardados: $e';
          _isLoading = false;
        });
      }
    }
  }

  /// Formatear fecha de manera más legible
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'No especificada';
    }
    
    try {
      DateTime date;
      // Intentar diferentes formatos de fecha
      if (dateString.contains('-')) {
        date = DateTime.parse(dateString);
      } else if (dateString.contains('/')) {
        final parts = dateString.split('/');
        if (parts.length == 3) {
          date = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        } else {
          return dateString;
        }
      } else {
        return dateString;
      }
      
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays < 365) {
        return '${difference.inDays} días';
      } else {
        final years = (difference.inDays / 365).floor();
        final months = ((difference.inDays % 365) / 30).floor();
        if (years > 0 && months > 0) {
          return '$years años, $months meses';
        } else if (years > 0) {
          return '$years año${years > 1 ? 's' : ''}';
        } else {
          return '$months mes${months > 1 ? 'es' : ''}';
        }
      }
    } catch (e) {
      return dateString;
    }
  }

  /// Mapear del formato offline a AnimalDto
  AnimalDto _mapFromOfflineFormat(Map<String, dynamic> data) {
    return AnimalDto(
      id: data['server_id'] ?? data['id'] ?? 0,
      name: data['name'] ?? '',
      gender: data['type'] ?? data['gender'] ?? '',
      birthDate: data['birth_date'] ?? data['birthDate'] ?? '',
      breed: data['breed'] ?? '',
      location: data['notes'] ?? data['location'] ?? '',
      bovineImg: data['image_url'] ?? data['bovineImg'] ?? '',
      stableId: data['stable_id'] ?? data['stableId'] ?? 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        foregroundColor: primary,
        title: const Text(
          'Bovinos Guardados',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2E7D32)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header en formato isla
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.offline_pin,
                      color: primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Modo Offline',
                          style: TextStyle(
                            color: Color(0xFF2E7D32),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isLoading 
                              ? 'Cargando datos...'
                              : '${_animals.length} bovino${_animals.length != 1 ? 's' : ''} guardado${_animals.length != 1 ? 's' : ''}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: accent.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: accent,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Disponible',
                          style: TextStyle(
                            fontSize: 12,
                            color: accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Contenido principal
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: primary,
                strokeWidth: 3,
              ),
              const SizedBox(height: 20),
              const Text(
                'Cargando bovinos guardados...',
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.error_outline,
                  color: Colors.red.shade400,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Error al cargar datos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_animals.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.pets_outlined,
                  size: 64,
                  color: primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No hay bovinos guardados',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Los bovinos se guardan automáticamente cuando navegas por la app con conexión a internet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accent.withOpacity(0.3)),
                ),
                child: Text(
                  'Conéctate a internet para sincronizar datos',
                  style: TextStyle(
                    fontSize: 12,
                    color: accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _animals.length,
      itemBuilder: (context, index) {
        final animal = _animals[index];
        return _buildAnimalCard(animal);
      },
    );
  }

  Widget _buildAnimalCard(AnimalDto animal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                // Imagen del animal o placeholder
                Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: primary.withOpacity(0.2), width: 2),
                  ),
                  child: animal.bovineImg.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            animal.bovineImg,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.pets,
                              color: primary,
                              size: 32,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.pets,
                          color: primary,
                          size: 32,
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              animal.name.isNotEmpty ? animal.name : 'Sin nombre',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: primary,
                              ),
                            ),
                          ),
                          // Indicador offline
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: accent.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.offline_pin,
                                  size: 12,
                                  color: accent,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Offline',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: accent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            animal.gender.toLowerCase().contains('macho') || animal.gender.toLowerCase().contains('m')
                                ? Icons.male
                                : Icons.female,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            animal.gender.isNotEmpty ? animal.gender : 'No especificado',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.cake_outlined,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _formatDate(animal.birthDate),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Información adicional
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 18,
                        color: primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Raza:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          animal.breed.isNotEmpty ? animal.breed : 'No especificada',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (animal.location.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 18,
                          color: primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Ubicación:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            animal.location,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (animal.stableId > 0) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.home_outlined,
                          size: 18,
                          color: primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Establo:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'ID ${animal.stableId}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
