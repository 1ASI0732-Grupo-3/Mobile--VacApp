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

  // Colores consistentes con animal_page.dart
  static const Color primary = Color(0xFF00695C);
  static const Color lightGreen = Color(0xFFE8F5E8);

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
              const Color(0xFFF8F9FA),
              lightGreen.withOpacity(0.3),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(0.15),
                      blurRadius: 25,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(
                    color: lightGreen.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primary, primary.withOpacity(0.8)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        _menuItems[selectedIndex]['icon'],
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _menuItems[selectedIndex]['label'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Próximamente disponible',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: lightGreen,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '🚀 En desarrollo',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
      backgroundColor: const Color(0xFFF8F9FA),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFAFAFA),
              const Color(0xFFF5F7F6),
              lightGreen.withOpacity(0.08),
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            /// ⬇️ Aquí usamos AnimatedSwitcher
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              switchInCurve: Curves.easeInOut,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.1, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: bodyKeyed,
            ),

            /// ⬇️ Menú de navegación flotante con estilo suave
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    // Fondo más suave con transparencia
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(28),
                    // Sombras más sutiles
                    boxShadow: [
                      // Sombra principal suave
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                        spreadRadius: 0,
                      ),
                      // Borde interno luminoso
                      BoxShadow(
                        color: Colors.white.withOpacity(0.9),
                        blurRadius: 1,
                        spreadRadius: 0,
                        offset: const Offset(0, 1),
                      ),
                    ],
                    // Borde elegante
                    border: Border.all(
                      color: Colors.white.withOpacity(0.8),
                      width: 1.0,
                    ),
                  ),
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
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            // Fondo suave para ítem seleccionado
                            color: isSelected 
                                ? primary.withOpacity(0.9)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            // Sombra sutil solo para el elemento seleccionado
                            boxShadow: isSelected ? [
                              BoxShadow(
                                color: primary.withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                                spreadRadius: 0,
                              ),
                            ] : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _menuItems[index]['icon'],
                                color: isSelected ? Colors.white : primary.withOpacity(0.7),
                                size: isSelected ? 24 : 22,
                              ),
                              if (isSelected)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Text(
                                    _menuItems[index]['label'],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
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
          ],
        ),
      ),
    );
  }
}
