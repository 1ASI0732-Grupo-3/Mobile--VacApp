import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vacapp/core/services/token_service.dart';
import '../../../../core/themes/color_palette.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';
import 'package:vacapp/core/widgets/island_notification.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isVisible = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _saveToken(String token, String username) async {
    await TokenService.instance.saveUserSession(token, username);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.secondaryColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is SuccessAuthState) {
                  _saveToken(state.user.token, state.user.username);
                  IslandNotification.showSuccess(
                    context,
                    message: '¡Registro exitoso! Bienvenido',
                  );
                  Navigator.pop(context); // Vuelve al login
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
                  children: [
                    const SizedBox(height: 20),
                    Image.asset(
                      'assets/images/vacapp_logo.png',
                      height: 200,
                      width: 200,
                    ),
                    _customInput(
                      controller: _nameController,
                      hint: "Nombre de usuario",
                      icon: Icons.person_outline,
                    ),
                    _customInput(
                      controller: _emailController,
                      hint: "Email",
                      icon: Icons.email_outlined,
                    ),
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
                          color: ColorPalette.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorPalette.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: state is LoadingAuthState
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
                            : const Text("Registrarme", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 45),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Tengo una cuenta",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: ColorPalette.primaryColor,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        cursorColor: ColorPalette.primaryColor,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black),
          suffixIcon: suffix,
          hintText: hint,
          hintStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          filled: true,
          fillColor: ColorPalette.cream,
          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}