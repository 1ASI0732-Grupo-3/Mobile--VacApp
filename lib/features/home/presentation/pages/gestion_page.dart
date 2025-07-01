import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vacapp/features/vaccines/presentation/pages/vaccines_page.dart';
import 'package:vacapp/features/vaccines/data/repositories/vaccines_repository.dart';
import 'package:vacapp/features/vaccines/data/datasources/vaccines_services.dart';

class GestionPage extends StatefulWidget {
  const GestionPage({super.key});

  @override
  State<GestionPage> createState() => _GestionPageState();
}

class _GestionPageState extends State<GestionPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Para contar los vacunados
  late VaccinesRepository _repository;
  int _vaccinatedCount = 0;
  bool _isLoadingVaccines = true;

  // Paleta institucional consistente
  static const Color primary = Color(0xFF00695C);
  static const Color lightGreen = Color(0xFFE8F5E8);

  List<Map<String, dynamic>> get _gestionOptions => [
    {
      'title': 'Campañas',
      'subtitle': 'Gestión de campañas de vacunación',
      'icon': Icons.campaign_outlined,
      'gradient': [const Color(0xFF00695C), const Color(0xFF004D40)],
      'badge': '12 activas',
      'action': 'campaigns',
    },
    {
      'title': 'Vacunas',
      'subtitle': 'Control y registro de vacunas',
      'icon': Icons.vaccines_outlined,
      'gradient': [const Color(0xFF2E7D32), const Color(0xFF1B5E20)],
      'badge': _isLoadingVaccines ? 'Cargando...' : '$_vaccinatedCount vacunados',
      'action': 'vaccines',
    },
    {
      'title': 'Empleados',
      'subtitle': 'Administración de personal',
      'icon': Icons.people_outline,
      'gradient': [const Color(0xFF00796B), const Color(0xFF00695C)],
      'badge': '8 activos',
      'action': 'employees',
    },
  ];

  @override
  void initState() {
    super.initState();
    
    // Inicializar repositorio
    _repository = VaccinesRepository(VaccinesService());
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Iniciar animaciones y cargar datos
    _fadeController.forward();
    _slideController.forward();
    _loadVaccinatedCount();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadVaccinatedCount() async {
    try {
      final vaccines = await _repository.getVaccines();
      if (mounted) {
        setState(() {
          _vaccinatedCount = vaccines.length;
          _isLoadingVaccines = false;
        });
      }
    } catch (e) {
      print('❌ [DEBUG] Error loading vaccines count: $e');
      if (mounted) {
        setState(() {
          _vaccinatedCount = 0;
          _isLoadingVaccines = false;
        });
      }
    }
  }

  Future<void> _navigateToVaccines() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const VaccinesPage(),
      ),
    );
    // Recargar el conteo cuando regrese de la página de vacunas
    _loadVaccinatedCount();
  }

  void _handleOptionTap(String action) {
    HapticFeedback.mediumImpact();
    switch (action) {
      case 'campaigns':
        print('Navegando a Campañas');
        break;
      case 'vaccines':
        _navigateToVaccines();
        break;
      case 'employees':
        print('Navegando a Empleados');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
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
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header con título y descripción
                    _buildHeader(),
                    const SizedBox(height: 32),
                    
                    // Grid de opciones de gestión
                    Expanded(
                      child: _buildGestionGrid(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primary, primary.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: primary.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.admin_panel_settings,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gestión',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Administra recursos y personal',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGestionGrid() {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: _gestionOptions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        final option = _gestionOptions[index];
        
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 600 + (index * 200)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: _buildGestionCard(option, index),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGestionCard(Map<String, dynamic> option, int index) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          _handleOptionTap(option['action']);
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
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
          child: Row(
            children: [
              // Icono con gradiente
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: option['gradient'],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: option['gradient'][0].withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  option['icon'],
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 20),
              
              // Información principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          option['title'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: primary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                lightGreen,
                                lightGreen.withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: primary.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            option['badge'],
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      option['subtitle'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Indicador de acción
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: lightGreen.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: primary,
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
      ),
    );
  }
}
