import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vacapp/core/services/token_service.dart';
import 'package:vacapp/features/auth/presentation/pages/login_page.dart';
import 'package:vacapp/features/auth/presentation/pages/profile_page.dart';

class WelcomeHeader extends StatefulWidget {
  final ScrollController? scrollController;
  
  const WelcomeHeader({
    super.key,
    this.scrollController,
  });

  @override
  State<WelcomeHeader> createState() => _WelcomeHeaderState();
}

class _WelcomeHeaderState extends State<WelcomeHeader> {
  late Future<String> _usernameFuture;
  bool _isScrolled = false;

  static const Color primaryColor = Color(0xFF00897B); // Más vibrante
  static const Color lightGreen = Color(0xFFD0F5E8); // Más claro
  static const Color accentColor = Color(0xFF00BFA5); // Acento moderno

  @override
  void initState() {
    super.initState();
    _usernameFuture = _loadUserData();
    
    // Escuchar cambios en el scroll
    widget.scrollController?.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (widget.scrollController == null) return;
    
    final scrollOffset = widget.scrollController!.offset;
    final shouldShowTitle = scrollOffset > 50;
    
    if (shouldShowTitle != _isScrolled) {
      setState(() {
        _isScrolled = shouldShowTitle;
      });
    }
  }

  Future<String> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Obtener y mostrar el token actual en la consola debug
    final token = await TokenService.instance.getToken();
    final username = await TokenService.instance.getUsername();
    
    print('═══════════════════════════════════════');
    print('🏠 HOME DEBUG INFO');
    print('═══════════════════════════════════════');
    
    if (token.isNotEmpty) {
      print('🔑 TOKEN ACTUAL: $token');
      print('📋 Token length: ${token.length} caracteres');
      print('👤 Username: $username');
      
      // Verificar si el token es válido
      final hasValidToken = await TokenService.instance.hasValidToken();
      print('✅ Token válido: $hasValidToken');
    } else {
      print('❌ No hay token disponible');
    }
    
    print('═══════════════════════════════════════');
    
    return prefs.getString('username') ?? 'Usuario';
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  void _navigateToProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ProfilePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 20,
      left: 24,
      right: 24,
      child: FutureBuilder<String>(
        future: _usernameFuture,
        builder: (context, snapshot) {
          final isLoading = snapshot.connectionState == ConnectionState.waiting;
          final username = snapshot.data ?? 'Usuario';

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, Color(0xFF00695C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withOpacity(0.13),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Contenido principal del header
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) =>
                        SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(-0.3, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        ),
                    child: _isScrolled
                        ? _buildTitleMode()
                        : _buildWelcomeMode(isLoading, username),
                  ),
                ),

                // Dropdown de configuraciones con glassmorphism y diseño moderno
                Container(
                  margin: const EdgeInsets.only(left: 16),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      popupMenuTheme: PopupMenuThemeData(
                        color: Colors.white, // Fondo sólido
                        elevation: 16,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                    child: PopupMenuButton<String>(
                      offset: const Offset(0, 60),
                      elevation: 16,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      constraints: const BoxConstraints(minWidth: 170),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.07),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.settings_rounded,
                          color: primaryColor,
                          size: 22,
                        ),
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem<String>(
                          value: 'profile',
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: lightGreen.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.person_rounded,
                                  color: Color(0xFF00695C),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              const Text(
                                'Mi Perfil',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Color(0xFF00695C),
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'logout',
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.logout_rounded,
                                  color: Colors.red.shade600,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              const Text(
                                'Cerrar Sesión',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        switch (value) {
                          case 'profile':
                            _navigateToProfile();
                            break;
                          case 'logout':
                            _logout();
                            break;
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeMode(bool isLoading, String username) {
    return Row(
      key: const ValueKey('welcome_mode'),
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar container with improved styling
        Container(
          height: 42,
          width: 42,
          padding: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: isLoading
                ? SizedBox(
                    key: const ValueKey('loading'),
                    width: 80,
                    height: 16,
                    child: LinearProgressIndicator(
                      backgroundColor: lightGreen.withOpacity(0.5),
                      color: accentColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Bienvenido',
                            key: const ValueKey('welcome'),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.85),
                              height: 1.1,
                            ),
                          ),       
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        username,
                        key: const ValueKey('username'),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.1,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleMode() {
    return Row(
      key: const ValueKey('title_mode'),
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 44,
          width: 44,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.dashboard_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VacApp',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Control General',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
