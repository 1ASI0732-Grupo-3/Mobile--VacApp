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
              const Color(0xFFF8F9FA),
              lightGreen.withOpacity(0.3),
            ],
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

            /// ⬇️ Menú de navegación flotante con estilo futurista
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    // Fondo futurista con gradiente verde claro
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.95),
                        lightGreen.withOpacity(0.9),
                        const Color(0xFFE0F2F1).withOpacity(0.95), // Verde mint claro
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(50),
                    // Efectos de sombra futuristas en verde
                    boxShadow: [
                      // Sombra principal con efecto de levitación verde
                      BoxShadow(
                        color: primary.withOpacity(0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                        spreadRadius: 5,
                      ),
                      // Resplandor neon verde
                      BoxShadow(
                        color: const Color(0xFF4CAF50).withOpacity(0.6),
                        blurRadius: 15,
                        offset: const Offset(0, 0),
                        spreadRadius: 2,
                      ),
                      // Sombra secundaria verde suave
                      BoxShadow(
                        color: const Color(0xFF81C784).withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                      // Sombra profunda para separación
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    // Borde futurista verde
                    border: Border.all(
                      color: primary.withOpacity(0.4),
                      width: 2.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(_menuItems.length, (index) {
                      bool isSelected = selectedIndex == index;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            // Fondo futurista verde para ítem seleccionado
                            gradient: isSelected ? LinearGradient(
                              colors: [
                                const Color(0xFF4CAF50), // Verde vibrante
                                primary, // Verde principal de la app
                                const Color(0xFF2E7D32), // Verde más oscuro
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ) : null,
                            color: !isSelected ? Colors.transparent : null,
                            borderRadius: BorderRadius.circular(35),
                            // Efectos de resplandor verde para ítem seleccionado
                            boxShadow: isSelected ? [
                              BoxShadow(
                                color: const Color(0xFF4CAF50).withOpacity(0.5),
                                blurRadius: 15,
                                offset: const Offset(0, 0),
                                spreadRadius: 2,
                              ),
                              BoxShadow(
                                color: primary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ] : null,
                            // Borde con resplandor verde claro
                            border: isSelected ? Border.all(
                              color: lightGreen.withOpacity(0.8),
                              width: 1.5,
                            ) : null,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _menuItems[index]['icon'],
                                color: isSelected ? Colors.white : primary.withOpacity(0.8),
                                size: isSelected ? 26 : 24,
                              ),
                              if (isSelected)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Text(
                                    _menuItems[index]['label'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      letterSpacing: 0.5,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black26,
                                          offset: Offset(0, 1),
                                          blurRadius: 2,
                                        ),
                                      ],
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
