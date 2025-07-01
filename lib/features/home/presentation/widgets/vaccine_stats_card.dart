import 'package:flutter/material.dart';
import 'package:vacapp/features/home/presentation/blocs/statistics_bloc.dart';
import 'package:vacapp/features/vaccines/presentation/pages/vaccines_page.dart';

class VaccineStatsCard extends StatelessWidget {
  final HomeStatistics statistics;

  const VaccineStatsCard({
    super.key,
    required this.statistics,
  });

  @override
  Widget build(BuildContext context) {
    final vaccinatedPercentage = statistics.totalAnimals > 0 
        ? ((statistics.totalAnimals - statistics.animalsWithoutVaccines) / statistics.totalAnimals) * 100 
        : 0.0;
    
    final topVaccines = statistics.topVaccineTypes;
    final vaccinesByMonth = statistics.vaccinesByMonth;
    final recentVaccines = statistics.recentVaccines;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const VaccinesPage(),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF4CAF50),
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
                      Icons.vaccines,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Control de Vacunas',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Estadísticas principales
              Row(
                children: [
                  Expanded(
                    child: _buildVaccineMetric(
                      icon: Icons.vaccines,
                      value: '${statistics.totalVaccines}',
                      label: 'Total',
                      subtitle: 'Aplicadas',
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 50,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                  Expanded(
                    child: _buildVaccineMetric(
                      icon: Icons.trending_up,
                      value: '${vaccinatedPercentage.toStringAsFixed(0)}%',
                      label: 'Cobertura',
                      subtitle: 'Animales vacunados',
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 50,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                  Expanded(
                    child: _buildVaccineMetric(
                      icon: Icons.access_time,
                      value: '$recentVaccines',
                      label: 'Recientes',
                      subtitle: 'Último mes',
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
                    // Tipos principales
                    if (topVaccines.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.medical_services,
                            size: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Tipos principales:',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        children: topVaccines.take(3).map((type) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            type,
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )).toList(),
                      ),
                    ],
                    
                    // Actividad mensual si hay datos
                    if (vaccinesByMonth.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_month,
                            size: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Actividad mensual:',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${vaccinesByMonth.length} meses activos',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withValues(alpha: 0.8),
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
      ),
    );
  }

  Widget _buildVaccineMetric({
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
}
