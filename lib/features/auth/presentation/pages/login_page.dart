import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vacapp/core/services/token_service.dart';
import 'package:vacapp/features/app/presentation/pages/main_view.dart';
import '../../../../core/themes/color_palette.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isVisible = false;
  final TextEditingController _userOrEmailController = TextEditingController();
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
                  _saveToken(state.user.token, state.user.username);                  // Navega a MainView y elimina el login del stack
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const MainView()),
                  );
                }
                if (state is FailureState) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.errorMessage)),
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
                    _inputField(
                      controller: _userOrEmailController,
                      hint: "Usuario o Email",
                      icon: Icons.person_outline,
                      obscure: false,
                      isPassword: false,
                    ),
                    _inputField(
                      controller: _passwordController,
                      hint: "Contraseña",
                      icon: Icons.lock_outline,
                      obscure: !_isVisible,
                      isPassword: true,
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
                                  LoginEvent(
                                    usernameOrEmail: _userOrEmailController.text.trim(),
                                    password: _passwordController.text.trim(),
                                  ),
                                );
                              },
                        child: state is LoadingAuthState
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("Iniciar Sesión", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 45),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterPage()),
                        );
                      },
                      child: const Text(
                        "¿No tienes cuenta? Regístrate",
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

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool obscure,
    required bool isPassword,
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
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(_isVisible ? Icons.visibility : Icons.visibility_off, color: Colors.black),
                  onPressed: () {
                    setState(() {
                      _isVisible = !_isVisible;
                    });
                  },
                )
              : null,
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