import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vacapp/features/home/presentation/blocs/statistics_bloc.dart';
import 'package:vacapp/features/home/presentation/widgets/statistics_widget.dart';
import 'package:vacapp/features/home/presentation/widgets/welcome_header.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
          child: Stack(
            children: [
              // Contenido principal con estadísticas
              SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    // Espacio para el header flotante
                    const SizedBox(height: 130),
                    
                    // Widget de estadísticas
                    const StatisticsWidget(),
                    
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
