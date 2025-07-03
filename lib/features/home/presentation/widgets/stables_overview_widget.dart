import 'package:flutter/material.dart';
import 'package:vacapp/features/stables/data/repositories/stable_repository.dart';
import 'package:vacapp/features/stables/data/datasources/stables_service.dart';
import 'package:vacapp/features/stables/data/models/stable_dto.dart';

class StablesOverviewWidget extends StatefulWidget {
  const StablesOverviewWidget({super.key});

  @override
  State<StablesOverviewWidget> createState() => _StablesOverviewWidgetState();
}

class _StablesOverviewWidgetState extends State<StablesOverviewWidget> {
  late StableRepository _repository;

  bool _isLoading = true;
  String? _error;

  // Datos agrupados
  int _totalStables = 0;
  int _totalCapacity = 0;
  int _availableSpace = 0;
  List<StableDto> _recentStables = [];

  // Paleta de colores moderna
  static const Color primary = Color(0xFF00695C);
  static const Color accent = Color(0xFF26A69A);
  static const Color cardBackground = Colors.white;

  @override
  void initState() {
    super.initState();
    _repository = StableRepository(StablesService());
    _loadStables();
  }

  Future<void> _loadStables() async {
    try {
      final stables = await _repository.getStables();
      if (mounted) {
        // Ordenar por reciente (asumimos que ID más grande = más reciente)
        final sortedStables = List<StableDto>.from(stables)
          ..sort((a, b) => b.id.compareTo(a.id));
        
        int totalCapacity = 0;
        int availableSpace = 0;
        
        for (final stable in stables) {
          totalCapacity += stable.limit;
          // En un caso real, se calcularía el espacio disponible basado en la ocupación actual
          // Para este ejemplo, simulamos que hay un 30% de espacio disponible
          availableSpace += (stable.limit * 0.3).round();
        }
        
        setState(() {

          _totalStables = stables.length;
          _totalCapacity = totalCapacity;
          _availableSpace = availableSpace;
          _recentStables = sortedStables.take(3).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al cargar establos';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con título
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primary, accent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.home_work_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Establos',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primary,
                        ),
                      ),
                      Text(
                        'Gestión de espacios',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            if (_isLoading)
              _buildLoadingState()
            else if (_error != null)
              _buildErrorState()
            else
              _buildStablesContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: CircularProgressIndicator(
          color: primary,
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade600,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _error!,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStablesContent() {
    return Column(
      children: [
        // Estadísticas principales
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total',
                _totalStables.toString(),
                Icons.home_work_rounded,
                primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Capacidad',
                _totalCapacity.toString(),
                Icons.pets_rounded,
                accent,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Disponible',
                _availableSpace.toString(),
                Icons.check_circle_outline,
                Colors.green,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Establos recientes
        if (_recentStables.isNotEmpty) ...[
          Row(
            children: [
              Text(
                'Establos recientes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: primary,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // Navegar a página de establos
                },
                child: Text(
                  'Ver todos',
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...(_recentStables.map((stable) => _buildStableItem(stable)).toList()),
        ] else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'No hay datos de establos disponibles',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: color.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStableItem(StableDto stable) {
    // Calcular ocupación (simulada, en un caso real vendría de la API)
    final ocupado = stable.limit - (stable.limit * 0.3).round();
    final porcentaje = ((ocupado / stable.limit) * 100).round();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.home_rounded,
                  color: primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  stable.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _getOcupacionColor(porcentaje).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$porcentaje% ocupado',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getOcupacionColor(porcentaje),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: porcentaje / 100,
              backgroundColor: Colors.grey.shade200,
              color: _getOcupacionColor(porcentaje),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Capacidad: ${stable.limit}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                'Disponible: ${stable.limit - ocupado}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Color _getOcupacionColor(int porcentaje) {
    if (porcentaje < 60) return Colors.green;
    if (porcentaje < 85) return Colors.orange;
    return Colors.red;
  }
}
