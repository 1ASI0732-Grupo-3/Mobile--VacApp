import 'package:flutter/material.dart';
import 'package:vacapp/features/animals/domain/entitites/Animal.dart';
import 'package:vacapp/features/stables/data/datasources/stables_service.dart';
import 'package:vacapp/features/vaccines/data/datasources/vaccines_services.dart';
import 'package:vacapp/features/vaccines/data/models/vaccines_dto.dart';

class AnimalDetailsPage extends StatefulWidget {
  final Animal animal;
  const AnimalDetailsPage({super.key, required this.animal});

  @override
  State<AnimalDetailsPage> createState() => _AnimalDetailsPageState();
}

class _AnimalDetailsPageState extends State<AnimalDetailsPage> {
  final StablesService _stablesService = StablesService();
  final VaccinesService _vaccinesService = VaccinesService();
  String? _stableName;
  bool _isLoadingStable = true;
  String? _errorMessage;
  List<VaccinesDto> _vaccines = [];
  bool _isLoadingVaccines = true;
  String? _vaccineErrorMessage;

  @override
  void initState() {
    super.initState();
    _loadStableName();
    _loadVaccines();
  }

  Future<void> _loadStableName() async {
    try {
      setState(() {
        _isLoadingStable = true;
        _errorMessage = null;
      });

      final stableId = widget.animal.stableId;
      final stable = await _stablesService.fetchStableById(stableId);
      setState(() {
        _stableName = stable.name;
        _isLoadingStable = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar el establo';
        _isLoadingStable = false;
      });
    }
  }

  Future<void> _loadVaccines() async {
    try {
      setState(() {
        _isLoadingVaccines = true;
        _vaccineErrorMessage = null;
      });

      final vaccines = await _vaccinesService.fetchVaccinesByBovineId(widget.animal.id);
      setState(() {
        _vaccines = vaccines;
        _isLoadingVaccines = false;
      });
    } catch (e) {
      setState(() {
        _vaccineErrorMessage = 'Error al cargar las vacunas';
        _isLoadingVaccines = false;
      });
    }
  }

  // Función para mostrar el género en español
  String _getGenderDisplay(String gender) {
    return gender.toLowerCase() == 'male' ? 'Macho' : 'Hembra';
  }

  @override
  Widget build(BuildContext context) {
    // Colores institucionales modernos
    const primary = Color(0xFF00695C);
    const lightGreen = Color(0xFFE8F5E8);
    const accent = Color(0xFF4CAF50);

    // Determinar el tipo de establo especial
    final isQuarantine = _stableName?.toLowerCase().contains('cuarentena') == true || 
                        widget.animal.stableId == 6; // Fallback para el ID conocido de cuarentena
    
    final isVeterinary = _stableName?.toLowerCase().contains('veterinarios') == true ||
                        _stableName?.toLowerCase().contains('c.veterinarios') == true ||
                        _stableName?.toLowerCase().contains('cuidados veterinarios') == true ||
                        widget.animal.stableId == 24; // Fallback para el ID conocido de veterinarios
    
    final isMaternity = _stableName?.toLowerCase().contains('maternidad') == true;

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
          child: Column(
            children: [
              // Header moderno
              Container(
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
                      // Botón de retroceso
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              primary.withOpacity(0.15),
                              primary.withOpacity(0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: primary.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: primary,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Título con icono
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.pets_rounded,
                                color: primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Detalles del Bovino',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Badge del ID
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              lightGreen.withOpacity(0.8),
                              lightGreen.withOpacity(0.6),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: primary.withOpacity(0.2),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.qr_code_rounded,
                              color: primary,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'ID: ${widget.animal.id}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: primary,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Contenido principal
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // Información del establo primero
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 600),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 30 * (1 - value)),
                          child: Opacity(
                            opacity: value,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 24),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white,
                                    lightGreen.withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: primary.withOpacity(0.08),
                                    blurRadius: 25,
                                    offset: const Offset(0, 10),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                                border: Border.all(
                                  color: lightGreen.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(28),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header del establo
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                primary.withOpacity(0.1),
                                                primary.withOpacity(0.05),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: const Icon(
                                            Icons.home_work_outlined,
                                            color: primary,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        const Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Ubicación del Bovino',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: primary,
                                                ),
                                              ),
                                              Text(
                                                'Establo asignado en el sistema',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    
                                    // Card del establo
                                    _buildStableCard(widget.animal.stableId, isQuarantine, isVeterinary, isMaternity),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          );
                      },
                    ),

                    // Alerta de cuarentena si aplica
                    if (isQuarantine)
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 800),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: Opacity(
                              opacity: value,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 24),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFFFF5722).withOpacity(0.1),
                                      const Color(0xFFFF5722).withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFFFF5722).withOpacity(0.3),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFF5722).withOpacity(0.2),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF5722).withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.warning_rounded,
                                        color: Color(0xFFFF5722),
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Bovino en Cuarentena',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFFF5722),
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Este bovino se encuentra actualmente en el establo de cuarentena. Requiere atención especial y seguimiento médico.',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black87,
                                              height: 1.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                    // Alerta de cuidados veterinarios si aplica
                    if (isVeterinary)
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 900),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: Opacity(
                              opacity: value,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 24),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFF2196F3).withOpacity(0.1),
                                      const Color(0xFF2196F3).withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFF2196F3).withOpacity(0.3),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF2196F3).withOpacity(0.2),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2196F3).withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.medical_services_rounded,
                                        color: Color(0xFF2196F3),
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Bovino en Cuidados Veterinarios',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF2196F3),
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Este bovino se encuentra bajo cuidados veterinarios especializados. Requiere tratamiento médico y supervisión constante.',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black87,
                                              height: 1.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            );
                        },
                      ),

                    // Alerta de maternidad si aplica
                    if (isMaternity)
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 1000),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: Opacity(
                              opacity: value,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 24),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.pink.withOpacity(0.1),
                                      Colors.pink.withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.pink.withOpacity(0.3),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.pink.withOpacity(0.2),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.pink.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.pregnant_woman_rounded,
                                        color: Colors.pink,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Bovino en Maternidad',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.pink,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Este bovino se encuentra en el área de maternidad. Requiere cuidados especiales durante el período de gestación o posparto.',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black87,
                                              height: 1.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            );
                        },
                      ),
                    
                    // Imagen del animal con diseño moderno
                    if (widget.animal.bovineImg.isNotEmpty)
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 600),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 30 * (1 - value)),
                            child: Opacity(
                              opacity: value,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 24),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white,
                                      lightGreen.withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withOpacity(0.08),
                                      blurRadius: 25,
                                      offset: const Offset(0, 10),
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: lightGreen.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    // Header de la sección
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                primary.withOpacity(0.15),
                                                accent.withOpacity(0.1),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Icon(
                                            Icons.camera_alt_rounded,
                                            color: primary,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Imagen de ${widget.animal.name}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    // Imagen con efectos
                                    Container(
                                      height: 200,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: primary.withOpacity(0.1),
                                            blurRadius: 15,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Image.network(
                                          widget.animal.bovineImg,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  lightGreen.withOpacity(0.4),
                                                  const Color(0xFF81C784).withOpacity(0.3),
                                                ],
                                              ),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.broken_image_rounded,
                                                  size: 60,
                                                  color: primary.withOpacity(0.6),
                                                ),
                                                const SizedBox(height: 12),
                                                Text(
                                                  'Error al cargar imagen',
                                                  style: TextStyle(
                                                    color: primary.withOpacity(0.6),
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
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
                            );
                        },
                      ),
                    
                    // Información del bovino
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 1000),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: Opacity(
                            opacity: value,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white,
                                    lightGreen.withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: primary.withOpacity(0.08),
                                    blurRadius: 25,
                                    offset: const Offset(0, 10),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                                border: Border.all(
                                  color: lightGreen.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(28),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header del formulario
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                primary.withOpacity(0.1),
                                                primary.withOpacity(0.05),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: const Icon(
                                            Icons.info_outline_rounded,
                                            color: primary,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        const Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Información del Bovino',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: primary,
                                                ),
                                              ),
                                              Text(
                                                'Datos registrados en el sistema',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 32),
                                    
                                    // Campos de información mejorados
                                    _buildInfoCard('Nombre', widget.animal.name, Icons.pets_outlined, primary),
                                    const SizedBox(height: 16),
                                    
                                    _buildInfoCard('Género', _getGenderDisplay(widget.animal.gender), Icons.wc_outlined, primary),
                                    const SizedBox(height: 16),
                                    
                                    _buildInfoCard('Raza', widget.animal.breed, Icons.category_outlined, primary),
                                    const SizedBox(height: 16),
                                    
                                    _buildInfoCard('Nacimiento', _formatDate(widget.animal.birthDate), Icons.calendar_today_outlined, primary),
                                    const SizedBox(height: 16),
                                    
                                    _buildInfoCard('Ubicación', widget.animal.location, Icons.location_on_outlined, primary),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          );
                      },
                    ),
                    
                    // Sección de vacunas
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 1200),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: Opacity(
                            opacity: value,
                            child: _buildVaccineSection(),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E8).withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: primaryColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: primaryColor.withOpacity(0.7),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStableCard(int stableId, bool isQuarantine, bool isVeterinary, bool isMaternity) {
    const primary = Color(0xFF00695C);
    
    // Usar el nombre del establo del estado
    String stableName;
    if (_isLoadingStable) {
      stableName = 'Cargando...';
    } else if (_errorMessage != null) {
      stableName = _stableName ?? 'Error al cargar';
    } else {
      stableName = _stableName ?? 'Sin establo asignado';
    }
    
    Color cardColor;
    Color textColor;
    IconData stableIcon;
    String badgeText = '';
    
    if (isQuarantine) {
      cardColor = const Color(0xFFFF5722).withOpacity(0.1);
      textColor = const Color(0xFFFF5722);
      stableIcon = Icons.warning_rounded;
      badgeText = 'Cuarentena';
    } else if (isVeterinary) {
      cardColor = const Color(0xFF2196F3).withOpacity(0.1);
      textColor = const Color(0xFF2196F3);
      stableIcon = Icons.medical_services_outlined;
      badgeText = 'C. Veterinarios';
    } else if (isMaternity) {
      cardColor = Colors.pink.withOpacity(0.1);
      textColor = Colors.pink;
      stableIcon = Icons.pregnant_woman_rounded;
      badgeText = 'Maternidad';
    } else {
      cardColor = const Color(0xFFE8F5E8).withOpacity(0.3);
      textColor = primary;
      stableIcon = Icons.home_work_outlined;
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: textColor.withOpacity(0.2),
          width: (isQuarantine || isVeterinary || isMaternity) ? 2 : 1,
        ),
        boxShadow: (isQuarantine || isVeterinary || isMaternity) ? [
          BoxShadow(
            color: textColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ] : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: textColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              stableIcon,
              color: textColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Establo ID: $stableId',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: textColor.withOpacity(0.7),
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (badgeText.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: textColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (_isLoadingStable) ...[
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (_errorMessage != null) ...[
                      const Icon(
                        Icons.error_outline,
                        size: 16,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Expanded(
                      child: Text(
                        stableName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _isLoadingStable ? Colors.grey : Colors.black87,
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
    );
  }

  Widget _buildVaccineSection() {
    const primary = Color(0xFF00695C);
    const lightGreen = Color(0xFFE8F5E8);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            lightGreen.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: lightGreen.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header de vacunas
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primary.withOpacity(0.1),
                        primary.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _vaccines.isEmpty ? Icons.warning_rounded : Icons.vaccines_rounded,
                    color: _vaccines.isEmpty ? Colors.orange : primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _vaccines.isEmpty ? 'Estado de Vacunación Crítico' : 'Historial de Vacunas',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _vaccines.isEmpty ? Colors.orange.shade700 : primary,
                        ),
                      ),
                      Text(
                        _vaccines.isEmpty 
                          ? 'Este bovino no tiene vacunas registradas'
                          : '${_vaccines.length} vacuna${_vaccines.length != 1 ? 's' : ''} aplicada${_vaccines.length != 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                // Badge con contador
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _vaccines.isEmpty 
                      ? Colors.orange.withOpacity(0.1)
                      : primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _vaccines.isEmpty 
                        ? Colors.orange.withOpacity(0.3)
                        : primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _vaccines.isEmpty ? Icons.close_rounded : Icons.check_circle_rounded,
                        color: _vaccines.isEmpty ? Colors.orange : primary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _vaccines.isEmpty ? 'Sin vacunas' : '${_vaccines.length}',
                        style: TextStyle(
                          fontSize: 12,
                          color: _vaccines.isEmpty ? Colors.orange : primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Content
            if (_isLoadingVaccines)
              _buildLoadingVaccines()
            else if (_vaccineErrorMessage != null)
              _buildVaccineError()
            else if (_vaccines.isEmpty)
              _buildDangerWarning()
            else
              _buildVaccinesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingVaccines() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: const Row(
        children: [
          CircularProgressIndicator(strokeWidth: 2),
          SizedBox(width: 16),
          Text(
            'Cargando historial de vacunas...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVaccineError() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade600,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Error al cargar vacunas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _vaccineErrorMessage ?? 'No se pudieron obtener las vacunas del bovino',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerWarning() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange.withOpacity(0.15),
            Colors.red.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.orange.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icono de peligro con animación
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.orange.withOpacity(0.4),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.dangerous_rounded,
              color: Colors.orange.shade700,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          
          // Mensaje de peligro
          Text(
            '⚠️ ATENCIÓN: BOVINO SIN VACUNAS ⚠️',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          
          Text(
            'Este bovino no tiene ninguna vacuna registrada en el sistema. Es URGENTE revisar su estado de vacunación y aplicar las vacunas necesarias según el protocolo sanitario.',
            style: TextStyle(
              fontSize: 15,
              color: Colors.orange.shade800,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          
          // Acciones recomendadas
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.orange.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icono centrado
                Center(
                  child: Icon(
                    Icons.checklist_rounded,
                    color: Colors.orange.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                // Texto centrado
                Center(
                  child: Text(
                    'ACCIONES INMEDIATAS REQUERIDAS:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
                _buildActionItem('Consultar con el veterinario'),
                _buildActionItem('Revisar el protocolo de vacunación'),
                _buildActionItem('Aplicar vacunas obligatorias'),
                _buildActionItem('Registrar las vacunas en el sistema'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.orange.shade600,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.orange.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVaccinesList() {
    const primary = Color(0xFF00695C);
    
    return Column(
      children: [
        // Lista de vacunas
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _vaccines.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final vaccine = _vaccines[index];
            return _buildVaccineCard(vaccine);
          },
        ),
        
        if (_vaccines.isNotEmpty) ...[
          const SizedBox(height: 16),
          // Mensaje de estado positivo
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Este bovino tiene un buen registro de vacunación. Continúa monitoreando las fechas de refuerzo.',
                    style: TextStyle(
                      fontSize: 13,
                      color: const Color(0xFF00695C),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVaccineCard(VaccinesDto vaccine) {
    const primary = Color(0xFF00695C);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primary.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de la vacuna
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.vaccines_rounded,
                  color: primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vaccine.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      vaccine.vaccineType,
                      style: TextStyle(
                        fontSize: 12,
                        color: primary.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Badge de fecha
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _formatDate(vaccine.vaccineDate),
                  style: TextStyle(
                    fontSize: 11,
                    color: primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
        'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
      ];
      return '${date.day} de ${months[date.month - 1]} de ${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
