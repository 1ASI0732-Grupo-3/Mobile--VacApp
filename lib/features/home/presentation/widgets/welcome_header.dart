import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vacapp/core/services/token_service.dart';
import 'package:vacapp/features/auth/presentation/pages/login_page.dart';

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

  static const Color primaryColor = Color(0xFF00695C);
  static const Color lightGreen = Color(0xFFE8F5E8);
  static const Color accentColor = Color(0xFF4CAF50);

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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, primaryColor.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

                // Botón logout
                GestureDetector(
                  onTap: _logout,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red.shade400, Colors.red.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Salir',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
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
      children: [
        AnimatedSwitcher(
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
                  ),
                )
              : Text(
                  'Bienvenido, $username ',
                  key: const ValueKey('username'),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
        const Text(' 👋', style: TextStyle(fontSize: 18)),
      ],
    );
  }

  Widget _buildTitleMode() {
    return Row(
      key: const ValueKey('title_mode'),
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.dashboard,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'Control General',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
