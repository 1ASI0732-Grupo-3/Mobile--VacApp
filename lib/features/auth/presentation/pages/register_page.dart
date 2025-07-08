import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';
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

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String? _validateForm() {
    if (_nameController.text.trim().isEmpty) {
      return 'El nombre de usuario es obligatorio';
    }
    if (_nameController.text.trim().length < 3) {
      return 'El nombre de usuario debe tener al menos 3 caracteres';
    }
    if (_emailController.text.trim().isEmpty) {
      return 'El email es obligatorio';
    }
    if (!_isValidEmail(_emailController.text.trim())) {
      return 'Error de email: Por favor ingresa un email válido';
    }
    if (_passwordController.text.trim().isEmpty) {
      return 'La contraseña es obligatoria';
    }
    if (_passwordController.text.trim().length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  String _getErrorMessage(String serverError) {
    // Convertir errores del servidor a mensajes amigables
    final errorLower = serverError.toLowerCase();
    
    if (errorLower.contains('email') && errorLower.contains('invalid')) {
      return 'Error de email: Por favor ingresa un email válido';
    } else if (errorLower.contains('email') && errorLower.contains('already')) {
      return 'Este email ya está registrado. Intenta con otro email.';
    } else if (errorLower.contains('username') && errorLower.contains('already')) {
      return 'Este nombre de usuario ya existe. Intenta con otro.';
    } else if (errorLower.contains('password') && errorLower.contains('weak')) {
      return 'La contraseña es muy débil. Debe tener al menos 8 caracteres.';
    } else if (errorLower.contains('required')) {
      return 'Todos los campos son obligatorios.';
    } else if (errorLower.contains('network') || errorLower.contains('connection')) {
      return 'Error de conexión. Verifica tu internet e intenta nuevamente.';
    } else {
      return 'Ha ocurrido un error inesperado. Intenta nuevamente.';
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.white,
          elevation: 8,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.red.shade50.withOpacity(0.3),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ícono animado
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.red.shade400,
                        Colors.red.shade600,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.shade200,
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Título
                const Text(
                  '¡Ups! Algo salió mal',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // Mensaje de error
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.red.shade200,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.red.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Botón de acción
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00695C),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Entendido',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.white,
          elevation: 8,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.green.shade50.withOpacity(0.3),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ícono animado
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.green.shade400,
                        Colors.green.shade600,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.shade200,
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Título
                const Text(
                  '¡Registro Exitoso!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // Mensaje de éxito
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green.shade200,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Tu cuenta ha sido creada correctamente. Por favor, inicia sesión con tus credenciales para acceder a la aplicación.',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Botón de acción
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Cerrar dialog
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                        (route) => false, // Remover todas las rutas anteriores
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00695C),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Iniciar Sesión',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
                      height: 140, // Más pequeño para dar espacio
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Contenedor inferior - expandido con scroll interno
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
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                      child: BlocConsumer<AuthBloc, AuthState>(
                        listener: (context, state) {
                          if (state is SuccessRegisterState) {
                            _showSuccessDialog();
                          }
                          if (state is FailureState) {
                            final friendlyMessage = _getErrorMessage(state.errorMessage);
                            _showErrorDialog(friendlyMessage);
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
                                          final validationError = _validateForm();
                                          if (validationError != null) {
                                            _showErrorDialog(validationError);
                                            return;
                                          }

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
                              const SizedBox(height: 30),

                              Row(
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
                              // Padding bottom para SafeArea
                              SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
                            ],
                          );
                        },
                      ),
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
