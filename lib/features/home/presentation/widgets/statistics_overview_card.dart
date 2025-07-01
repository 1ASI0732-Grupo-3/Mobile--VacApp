import 'package:flutter/material.dart';
import 'package:vacapp/features/home/presentation/blocs/statistics_bloc.dart';

class StatisticsOverviewCard extends StatelessWidget {
  final HomeStatistics statistics;

  const StatisticsOverviewCard({
    super.key,
    required this.statistics,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF00695C),
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
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.dashboard,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Panel de Control',
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
                  child: _buildMainStat(
                    icon: Icons.pets,
                    value: '${statistics.totalAnimals}',
                    label: 'Animales',
                    color: Colors.white,
                  ),
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                Expanded(
                  child: _buildMainStat(
                    icon: Icons.vaccines,
                    value: '${statistics.totalVaccines}',
                    label: 'Vacunas',
                    color: Colors.white,
                  ),
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                Expanded(
                  child: _buildMainStat(
                    icon: Icons.home_work,
                    value: '${statistics.totalStables}',
                    label: 'Establos',
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Indicadores críticos y detallados
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
                        child: _buildDetailedIndicator(
                          icon: Icons.warning_amber_rounded,
                          title: 'Sin Vacunar',
                          value: '${statistics.animalsWithoutVaccines}',
                          subtitle: '${statistics.animalsWithoutVaccines > 0 ? ((statistics.animalsWithoutVaccines / statistics.totalAnimals) * 100).toStringAsFixed(1) : 0}% del rebaño',
                          isAlert: statistics.animalsWithoutVaccines > 0,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 50,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      Expanded(
                        child: _buildDetailedIndicator(
                          icon: Icons.trending_up,
                          title: 'Cobertura',
                          value: '${statistics.totalAnimals > 0 ? ((statistics.totalAnimals - statistics.animalsWithoutVaccines) / statistics.totalAnimals * 100).toStringAsFixed(0) : 0}%',
                          subtitle: '${statistics.totalAnimals - statistics.animalsWithoutVaccines} de ${statistics.totalAnimals}',
                          isAlert: false,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailedIndicator(
                          icon: Icons.male,
                          title: 'Distribución',
                          value: '${statistics.femaleAnimals}H/${statistics.maleAnimals}M',
                          subtitle: '${statistics.totalAnimals > 0 ? ((statistics.femaleAnimals / statistics.totalAnimals) * 100).toStringAsFixed(0) : 0}% hembras',
                          isAlert: false,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 50,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      Expanded(
                        child: _buildDetailedIndicator(
                          icon: Icons.home_work,
                          title: 'Capacidad',
                          value: '${statistics.stableUtilizationPercentage.toStringAsFixed(0)}%',
                          subtitle: '${statistics.totalAnimals}/${statistics.totalCapacity} espacios',
                          isAlert: statistics.stableUtilizationPercentage > 90,
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

  Widget _buildMainStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color.withValues(alpha: 0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedIndicator({
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
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: indicatorColor,
          ),
        ),
        const SizedBox(height: 2),
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
