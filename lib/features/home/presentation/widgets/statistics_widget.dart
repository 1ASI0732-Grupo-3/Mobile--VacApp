import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vacapp/features/home/presentation/blocs/statistics_bloc.dart';
import 'package:vacapp/features/home/presentation/widgets/statistics_overview_card.dart';
import 'package:vacapp/features/home/presentation/widgets/vaccine_stats_card.dart';
import 'package:vacapp/features/home/presentation/widgets/alert_stats_card.dart';

class StatisticsWidget extends StatelessWidget {
  const StatisticsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatisticsBloc, StatisticsState>(
      builder: (context, state) {
        if (state is StatisticsLoading) {
          return const _LoadingStatistics();
        } else if (state is StatisticsError) {
          return _ErrorStatistics(message: state.message);
        } else if (state is StatisticsLoaded) {
          return _LoadedStatistics(statistics: state.statistics);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _LoadingStatistics extends StatelessWidget {
  const _LoadingStatistics();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E8).withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            duration: const Duration(seconds: 2),
            tween: Tween(begin: 0.8, end: 1.2),
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Icon(
                  Icons.analytics_outlined,
                  size: 40,
                  color: const Color(0xFF00695C).withOpacity(0.7),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Cargando estadísticas...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF00695C),
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            backgroundColor: const Color(0xFF00695C).withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00695C)),
          ),
        ],
      ),
    );
  }
}

class _ErrorStatistics extends StatelessWidget {
  final String message;

  const _ErrorStatistics({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Error al cargar estadísticas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.red.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<StatisticsBloc>().add(RefreshStatistics());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

class _LoadedStatistics extends StatelessWidget {
  final HomeStatistics statistics;

  const _LoadedStatistics({required this.statistics});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // PRIORIDAD 1: Alertas importantes (animales sin vacuna) - Aparece PRIMERO
          if (statistics.animalsWithoutVaccines > 0)
            AlertStatsCard(statistics: statistics),
          
          // PRIORIDAD 2: Resumen general de establos y animales
          StatisticsOverviewCard(statistics: statistics),
          
          // Tarjeta de vacunas (fila completa)
          VaccineStatsCard(statistics: statistics),
          
          const SizedBox(height: 12),
          
          // Tarjeta de establos (fila completa)
          _buildStablesCard(statistics),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStablesCard(HomeStatistics statistics) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF00695C), // Mismo color que el panel de control
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.home_work,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Gestión de Establos',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Estadísticas principales
            Row(
              children: [
                Expanded(
                  child: _buildStableMetric(
                    icon: Icons.home_work,
                    value: '${statistics.totalStables}',
                    label: 'Total',
                    subtitle: 'Establos activos',
                  ),
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                Expanded(
                  child: _buildStableMetric(
                    icon: Icons.trending_up,
                    value: '${statistics.stableUtilizationPercentage.toStringAsFixed(0)}%',
                    label: 'Ocupación',
                    subtitle: 'Capacidad utilizada',
                  ),
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                Expanded(
                  child: _buildStableMetric(
                    icon: Icons.pets,
                    value: statistics.avgAnimalsPerStable.toStringAsFixed(1),
                    label: 'Promedio',
                    subtitle: 'Animales/establo',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Información detallada
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailMetric(
                          icon: Icons.check_circle,
                          title: 'Llenos',
                          value: '${statistics.fullStables.length}',
                          subtitle: _formatStablesList(statistics.fullStables, 'En capacidad'),
                          isAlert: statistics.fullStables.length == statistics.totalStables,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      Expanded(
                        child: _buildDetailMetric(
                          icon: Icons.space_bar,
                          title: 'Vacíos',
                          value: '${statistics.emptyStables.length}',
                          subtitle: _formatStablesList(statistics.emptyStables, 'Sin animales'),
                          isAlert: statistics.emptyStables.length > (statistics.totalStables * 0.3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailMetric(
                          icon: Icons.trending_down,
                          title: 'Baja Ocupación',
                          value: '${statistics.lowOccupancyStables.length}',
                          subtitle: _formatStablesList(statistics.lowOccupancyStables, 'Menos del 50%'),
                          isAlert: statistics.lowOccupancyStables.length > 2,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      Expanded(
                        child: _buildDetailMetric(
                          icon: Icons.space_dashboard,
                          title: 'Capacidad Total',
                          value: '${statistics.totalCapacity}',
                          subtitle: 'Espacios disponibles',
                          isAlert: false,
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
    );
  }

  String _formatStablesList(List<int> stables, String defaultText) {
    if (stables.isEmpty) return defaultText;
    
    if (stables.length <= 3) {
      return 'Establos: ${stables.join(", ")}';
    } else {
      final firstThree = stables.take(3).join(", ");
      return 'Establos: $firstThree... (+${stables.length - 3})';
    }
  }

  Widget _buildStableMetric({
    required IconData icon,
    required String value,
    required String label,
    required String subtitle,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 9,
            color: Colors.white.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDetailMetric({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required bool isAlert,
  }) {
    final indicatorColor = isAlert ? Colors.orange[200] : Colors.white;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: indicatorColor,
              size: 14,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: indicatorColor,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 8,
            color: Colors.white.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
