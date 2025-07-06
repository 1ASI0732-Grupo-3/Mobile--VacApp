import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vacapp/features/animals/presentation/pages/animal_page.dart';
import 'package:vacapp/features/home/presentation/pages/home_page.dart';
import 'package:vacapp/features/home/presentation/pages/gestion_page.dart';
import 'package:vacapp/features/stables/presentation/pages/stable_page.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int selectedIndex = 0;

  // Colores invertidos - Esquema oscuro elegante
  static const Color primary = Color(0xFF1A1A1A);        // Negro suave
  static const Color accent = Color(0xFF00695C);         // Verde para acentos
  static const Color lightAccent = Color(0xFF4DB6AC);    // Verde claro
  static const Color background = Color(0xFF0F0F0F);     // Fondo muy oscuro
  static const Color surface = Color(0xFF2D2D2D);        // Superficie oscura
  static const Color textPrimary = Color(0xFFFFFFFF);    // Texto blanco
  static const Color textSecondary = Color(0xFFB0B0B0);  // Texto gris claro

  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.home, 'label': 'Inicio'},
    {'icon': Icons.pets, 'label': 'Animales'},
    {'icon': Icons.campaign, 'label': 'Gestión'},
    {'icon': Icons.warehouse, 'label': 'Establos'},
  ];

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (selectedIndex == 0) {
      body = const HomePage();
    } else if (selectedIndex == 1) {
      body = const AnimalPage();
    } else if (selectedIndex == 2) {
      body = const GestionPage();
    } else if (selectedIndex == 3) {
      body = const StablePage();
    } else {
      body = Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              background,
              primary.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
                          MediaQuery.of(context).padding.top - 
                          MediaQuery.of(context).padding.bottom - 
                          100, // Espacio para la barra de navegación
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        constraints: const BoxConstraints(maxWidth: 350),
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color: accent.withOpacity(0.1),
                              blurRadius: 40,
                              offset: const Offset(0, 0),
                            ),
                          ],
                          border: Border.all(
                            color: accent.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [accent, lightAccent],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: accent.withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _menuItems[selectedIndex]['icon'],
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              _menuItems[selectedIndex]['label'],
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Próximamente disponible',
                              style: TextStyle(
                                fontSize: 16,
                                color: textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24, 
                                vertical: 12
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    accent.withOpacity(0.2),
                                    lightAccent.withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: accent.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '🚀',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'En desarrollo',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: lightAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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

    // Añade una clave única para que AnimatedSwitcher detecte el cambio
    Widget bodyKeyed = KeyedSubtree(
      key: ValueKey(selectedIndex),
      child: body,
    );

    return Scaffold(
      backgroundColor: background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              background,
              primary.withOpacity(0.9),
              surface.withOpacity(0.3),
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            /// AnimatedSwitcher con transiciones mejoradas
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeInOutCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.05, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutQuart,
                    )),
                    child: child,
                  ),
                );
              },
              child: bodyKeyed,
            ),

            /// Menú de navegación flotante con diseño oscuro
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0, left: 16, right: 16),
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width - 32,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      // Fondo oscuro semi-transparente
                      color: surface.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        // Sombra principal
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                          spreadRadius: 0,
                        ),
                        // Resplandor sutil
                        BoxShadow(
                          color: accent.withOpacity(0.1),
                          blurRadius: 30,
                          offset: const Offset(0, 0),
                          spreadRadius: 0,
                        ),
                      ],
                      // Borde elegante
                      border: Border.all(
                        color: accent.withOpacity(0.2),
                        width: 1.0,
                      ),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const ClampingScrollPhysics(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(_menuItems.length, (index) {
                          bool isSelected = selectedIndex == index;
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                selectedIndex = index;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: EdgeInsets.symmetric(
                                horizontal: isSelected ? 16 : 12, 
                                vertical: 12
                              ),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                // Fondo para ítem seleccionado
                                gradient: isSelected 
                                    ? LinearGradient(
                                        colors: [accent, lightAccent],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : null,
                                color: isSelected ? null : Colors.transparent,
                                borderRadius: BorderRadius.circular(22),
                                // Sombra para el elemento seleccionado
                                boxShadow: isSelected ? [
                                  BoxShadow(
                                    color: accent.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                    spreadRadius: 0,
                                  ),
                                ] : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _menuItems[index]['icon'],
                                    color: isSelected 
                                        ? Colors.white 
                                        : textSecondary,
                                    size: isSelected ? 24 : 22,
                                  ),
                                  if (isSelected)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Text(
                                        _menuItems[index]['label'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    )
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}