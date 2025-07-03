import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vacapp/core/services/token_service.dart';
import 'package:vacapp/features/app/presentation/pages/main_view.dart';
import 'package:vacapp/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:vacapp/features/auth/presentation/pages/welcome_page.dart';
import 'package:vacapp/features/auth/data/repositories/auth_repository.dart';
import 'package:vacapp/features/auth/data/datasources/auth_service.dart';

void main() { 
  // Configurar el status bar globalmente
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  Future<Widget> _getInitialPage() async {
    final hasToken = await TokenService.instance.hasValidToken();
    if (hasToken) {
      return const MainView();
    } else {
      return const WelcomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(
            authRepository: AuthRepository(AuthService()),
          ),
        ),
        // Puedes agregar más BLoCs aquí si necesitas
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: FutureBuilder<Widget>(
          future: _getInitialPage(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return snapshot.data ?? const WelcomePage();
          },
        ),
      ),
    );
  }
}