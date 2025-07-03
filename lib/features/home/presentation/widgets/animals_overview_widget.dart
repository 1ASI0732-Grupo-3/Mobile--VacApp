import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vacapp/core/themes/color_palette.dart';
import 'package:vacapp/features/home/presentation/blocs/statistics_bloc.dart';

class AnimalsOverviewWidget extends StatelessWidget {
  const AnimalsOverviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatisticsBloc, StatisticsState>(
      builder: (context, state) {
        if (state is StatisticsLoading) {
          return _buildLoadingState();
        } else if (state is StatisticsError) {
          return _buildErrorState(state.message);
        } else if (state is StatisticsLoaded) {
          return _buildAnimalsContent(context, state.statistics);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      height: 200,
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.green,
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    final Color errorColor = Color(0xFFF8D7DA); // Pastel red background
    final Color borderColor = Color(0xFFF5C2C7); // Softer red border
    final Color textColor = Color(0xFFCC0000); // Softer red text
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: errorColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: textColor),
              const SizedBox(width: 8),
              Text(
                'Error en estadísticas de animales',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(color: textColor.withOpacity(0.9)),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimalsContent(BuildContext context, HomeStatistics statistics) {
    // Datos ficticios para el panel de control
    final Map<String, double> ageDistribution = {
      'Menos de 1 año': 15.0,
      '1-3 años': 45.0,
      '4-7 años': 30.0,
      'Más de 7 años': 10.0,
    };
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.pets_rounded,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Panel de Animales',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Resumen y estadísticas',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Estadísticas principales
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                _buildStatisticItem(
                  icon: Icons.pets,
                  title: '${statistics.totalAnimals}',
                  subtitle: 'Total Animales',
                ),
                const Spacer(),
                _buildStatisticItem(
                  icon: Icons.female,
                  title: '${statistics.femaleAnimals}',
                  subtitle: 'Hembras',
                  iconColor: Colors.pink[100],
                ),
                const Spacer(),
                _buildStatisticItem(
                  icon: Icons.male,
                  title: '${statistics.maleAnimals}',
                  subtitle: 'Machos',
                  iconColor: Colors.lightBlue[100],
                ),
              ],
            ),
          ),

          // Distribución de edades
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.green.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Distribución por Edad',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 12),
                ...ageDistribution.entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.withOpacity(0.8),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 7,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                FractionallySizedBox(
                                  widthFactor: entry.value / 100,
                                  child: Container(
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '${entry.value.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green.withOpacity(0.8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ],
            ),
          ),
          
          // Espacio al final
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatisticItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? iconColor,
  }) {
    final Color primaryColor = ColorPalette.primaryColor;
    final Color iconDefaultColor = Colors.green; // Change icon color to green
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: iconColor ?? iconDefaultColor,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: primaryColor.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  
}

class AnimalsPage extends StatelessWidget {
  const AnimalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animales'),
      ),
      body: const Center(
        child: Text('Lista de todos los animales'),
      ),
    );
  }
}
