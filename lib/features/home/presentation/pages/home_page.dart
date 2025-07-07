import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vacapp/features/home/presentation/blocs/statistics_bloc.dart';
import 'package:vacapp/features/home/presentation/widgets/welcome_header.dart';
import 'package:vacapp/features/home/presentation/widgets/campaigns_overview_widget.dart';
import 'package:vacapp/features/home/presentation/widgets/staff_overview_widget.dart';
import 'package:vacapp/features/home/presentation/widgets/vaccines_overview_widget.dart';
import 'package:vacapp/features/home/presentation/widgets/stables_overview_widget.dart';
import 'package:vacapp/features/home/presentation/widgets/animals_overview_widget.dart';
import 'package:vacapp/features/home/presentation/widgets/alert_stats_card.dart';

class HomePage extends StatefulWidget {
  final Function(int)? onNavigateToTab;
  
  const HomePage({super.key, this.onNavigateToTab});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const Color backgroundColor = Color(0xFFF8F9FA);
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StatisticsBloc()..add(LoadStatistics()),
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              // Contenido principal con estadísticas
              SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    // Espacio para el header flotante
                    const SizedBox(height: 130),
                    
                    // Panel de alertas y estadísticas
                    BlocBuilder<StatisticsBloc, StatisticsState>(
                      builder: (context, state) {
                        if (state is StatisticsLoading) {
                          return Container(
                            margin: const EdgeInsets.all(20),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Column(
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 16),
                                  Text('Cargando estadísticas...'),
                                ],
                              ),
                            ),
                          );
                        } else if (state is StatisticsError) {
                          return Container(
                            margin: const EdgeInsets.all(20),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.error_outline, 
                                     color: Colors.red.shade400, 
                                     size: 48),
                                const SizedBox(height: 16),
                                Text(
                                  'Error al cargar estadísticas: ${state.message}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.red.shade700),
                                ),
                              ],
                            ),
                          );
                        } else if (state is StatisticsOffline) {
                          return Container(
                            margin: const EdgeInsets.all(20),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.wifi_off, 
                                     color: Colors.grey.shade600, 
                                     size: 48),
                                const SizedBox(height: 16),
                                Text(
                                  'No hay WiFi',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Verifica tu conexión a internet para ver las estadísticas',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          );
                        } else if (state is StatisticsLoaded) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                // Panel de alerta rojo
                                AlertStatsCard(statistics: state.statistics),
                                
                                
                                // Panel de animales
                                const AnimalsOverviewWidget(),
                              ],
                            ),
                          );
                        } 
                        return const SizedBox(height: 20);
                      },
                    ),
                    
                    // Widget de campañas
                    const CampaignsOverviewWidget(),
                    
                    // Widget de personal
                    const StaffOverviewWidget(),
                    
                    // Widget de vacunas
                    const VaccinesOverviewWidget(),
                    
                    // Widget de establos
                    StablesOverviewWidget(
                      onNavigateToTab: widget.onNavigateToTab,
                    ),
                    
                    // Espacio suficiente para evitar superposición con navigation bar
                    const SizedBox(height: 120),
                  ],
                ),
              ),

              // Header de bienvenida flotante
              WelcomeHeader(scrollController: _scrollController),
            ],
          ),
        ),
      ),
    );
  }
}
