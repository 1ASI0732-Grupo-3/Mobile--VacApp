import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vacapp/core/services/token_service.dart';
import 'package:vacapp/features/app/presentation/pages/main_view.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  bool _isVisible = false;
  final TextEditingController _userOrEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    // Start animations with safety check
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fadeController.forward();
        _slideController.forward();
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _userOrEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _saveToken(String token, String username) async {
    await TokenService.instance.saveUserSession(token, username);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF00695C),
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          // Parte superior con logo - con animación de fade
          SafeArea(
            bottom: false,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Hero(
                      tag: 'login_image',
                      child: Image.asset(
                        'assets/images/login.png',
                        height: 160, // Más pequeño para dar espacio
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Contenedor blanco con formulario - expandido con scroll interno
          Expanded(
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: BlocConsumer<AuthBloc, AuthState>(
                      listener: (context, state) {
                        if (state is SuccessLoginState) {
                          _saveToken(state.user.token, state.user.username);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const MainView()),
                          );
                        }
                        if (state is FailureState) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.errorMessage),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      builder: (context, state) {
                        return FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              const Text(
                                "¡Bienvenido de nuevo!",
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00695C),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Ingresa tus credenciales para continuar",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 30),

                              _inputField(
                                controller: _userOrEmailController,
                                hint: "Usuario o Email",
                                icon: Icons.person_outline,
                                obscure: false,
                                isPassword: false,
                              ),
                              const SizedBox(height: 20),

                              _inputField(
                                controller: _passwordController,
                                hint: "Contraseña",
                                icon: Icons.lock_outline,
                                obscure: !_isVisible,
                                isPassword: true,
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    // Implementar recuperación
                                  },
                                  child: const Text(
                                    "¿Olvidaste tu contraseña?",
                                    style: TextStyle(
                                      color: Color(0xFF00695C),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),

                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF00695C),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: state is LoadingAuthState
                                      ? null
                                      : () {
                                          BlocProvider.of<AuthBloc>(context).add(
                                            LoginEvent(
                                              usernameOrEmail: _userOrEmailController.text.trim(),
                                              password: _passwordController.text.trim(),
                                            ),
                                          );
                                        },
                                  child: state is LoadingAuthState
                                      ? const CircularProgressIndicator(color: Colors.white)
                                      : const Text(
                                          "Iniciar Sesión",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 30),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "¿No tienes cuenta? ",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const RegisterPage()),
                                      );
                                    },
                                    child: const Text(
                                      "Regístrate",
                                      style: TextStyle(
                                        color: Color(0xFF00695C),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // Padding bottom para SafeArea
                              SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool obscure,
    required bool isPassword,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      cursorColor: Color(0xFF00695C),
      style: const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 16,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Color(0xFF00695C)),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isVisible ? Icons.visibility : Icons.visibility_off,
                  color: Color(0xFF00695C),
                ),
                onPressed: () {
                  setState(() {
                    _isVisible = !_isVisible;
                  });
                },
              )
            : null,
        hintText: hint,
        hintStyle: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 15,
          color: Colors.grey.shade500,
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00695C)),
        ),
      ),
    );
  }
}