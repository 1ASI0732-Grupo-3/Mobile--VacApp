import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vacapp/core/services/token_service.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';
import 'package:vacapp/core/widgets/island_notification.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with TickerProviderStateMixin {
  bool _isVisible = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _agreeToTerms = false;

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
    _nameController.dispose();
    _emailController.dispose();
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
          // Imagen superior - con animación de fade
          SafeArea(
            bottom: false,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Hero(
                    tag: 'register_image',
                    child: Image.asset(
                      'assets/images/register.png',
                      height: 180,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Contenedor inferior - con animación desde abajo
          Expanded(
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    // Sección fija (Título, campos, botón)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      child: BlocConsumer<AuthBloc, AuthState>(
                        listener: (context, state) {
                          if (state is SuccessAuthState) {
                            _saveToken(state.user.token, state.user.username);
                            IslandNotification.showSuccess(
                              context,
                              message: '¡Registro exitoso! Bienvenido',
                            );
                            Navigator.pop(context);
                          }
                          if (state is FailureState) {
                            IslandNotification.showError(
                              context,
                              message: 'Error: ${state.errorMessage}',
                            );
                          }
                        },
                        builder: (context, state) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Crear tu Cuenta",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00695C),
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "Crea tu cuenta para comenzar tu viaje",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 30),

                              _customInput(
                                controller: _nameController,
                                hint: "Nombre de usuario",
                                icon: Icons.person_outline,
                              ),
                              const SizedBox(height: 20),

                              _customInput(
                                controller: _emailController,
                                hint: "Email",
                                icon: Icons.email_outlined,
                              ),
                              const SizedBox(height: 20),

                              _customInput(
                                controller: _passwordController,
                                hint: "Contraseña",
                                icon: Icons.lock_outline,
                                obscure: !_isVisible,
                                suffix: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _isVisible = !_isVisible;
                                    });
                                  },
                                  icon: Icon(
                                    _isVisible ? Icons.visibility : Icons.visibility_off,
                                    color: Color(0xFF00695C),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Checkbox(
                                    value: _agreeToTerms,
                                    activeColor: Color(0xFF00695C),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _agreeToTerms = value ?? false;
                                      });
                                    },
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: RichText(
                                        text: const TextSpan(
                                          text: 'Acepto los ',
                                          style: TextStyle(color: Colors.grey, fontSize: 14),
                                          children: [
                                            TextSpan(
                                              text: 'Términos & Condiciones',
                                              style: TextStyle(
                                                color: Color(0xFF00695C),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            TextSpan(text: ' y la '),
                                            TextSpan(
                                              text: 'Política de Privacidad',
                                              style: TextStyle(
                                                color: Color(0xFF00695C),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),

                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _agreeToTerms
                                        ? Color(0xFF00695C)
                                        : Colors.grey.shade300,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: (state is LoadingAuthState || !_agreeToTerms)
                                      ? null
                                      : () {
                                          BlocProvider.of<AuthBloc>(context).add(
                                            SignUpEvent(
                                              username: _nameController.text.trim(),
                                              password: _passwordController.text.trim(),
                                              email: _emailController.text.trim(),
                                            ),
                                          );
                                        },
                                  child: state is LoadingAuthState
                                      ? const CircularProgressIndicator(color: Colors.white)
                                      : Text(
                                          "Crear Cuenta",
                                          style: TextStyle(
                                            color: _agreeToTerms
                                                ? Colors.white
                                                : Colors.grey.shade600,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    // Scroll para dispositivos con poco espacio o teclado
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: Container(), // Placeholder para mantener el scroll funcional
                      ),
                    ),

                    // Texto fijo al fondo
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "¿Ya tienes una cuenta? ",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const LoginPage()),
                              );
                            },
                            child: const Text(
                              "Iniciar Sesión",
                              style: TextStyle(
                                color: Color(0xFF00695C),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
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
        ],
      ),
    );
  }

  Widget _customInput({
    required TextEditingController controller,
    String? hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
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
        suffixIcon: suffix,
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
        enabledBorder: OutlineInputBorder(
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
