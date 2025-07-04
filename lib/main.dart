import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vacapp/core/services/token_service.dart';
import 'package:vacapp/core/services/notification_service.dart';
import 'package:vacapp/core/services/sync_service.dart';
import 'package:vacapp/core/widgets/connectivity_wrapper.dart';
import 'package:vacapp/core/widgets/permission_initializer.dart';
import 'package:vacapp/features/app/presentation/pages/main_view.dart';
import 'package:vacapp/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:vacapp/features/auth/presentation/pages/welcome_page.dart';
import 'package:vacapp/features/auth/data/repositories/auth_repository.dart';
import 'package:vacapp/features/auth/data/datasources/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configurar el status bar globalmente
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // Inicializar servicios críticos
  await _initializeServices();
  
  runApp(const MainApp());
}

/// Inicializar todos los servicios de la aplicación
Future<void> _initializeServices() async {
  try {
    // Inicializar servicio de notificaciones
    final notificationService = NotificationService();
    await notificationService.initialize();
    
    // Inicializar servicio de sincronización
    final syncService = SyncService();
    await syncService.initialize();
    
    print('✅ Servicios inicializados correctamente');
  } catch (e) {
    print('❌ Error inicializando servicios: $e');
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  Future<Widget> _getInitialPage() async {
    // Verificar si hay sesión activa o datos offline
    final hasActiveSession = await TokenService.instance.hasValidToken();
    final hasOfflineData = await TokenService.instance.hasOfflineData();
    
    print('🔍 [INIT] Verificando estado inicial:');
    print('🔍 [INIT] - Sesión activa: $hasActiveSession');
    print('🔍 [INIT] - Datos offline: $hasOfflineData');
    
    if (hasActiveSession) {
      // Usuario logueado, ir a la vista principal
      print('✅ [INIT] Dirigiendo a MainView (sesión activa)');
      return const MainView();
    } else if (hasOfflineData) {
      // No hay sesión pero hay datos offline, mostrar vista principal en modo offline
      print('✅ [INIT] Dirigiendo a MainView (modo offline)');
      return const MainView();
    } else {
      // No hay sesión ni datos offline, mostrar bienvenida
      print('✅ [INIT] Dirigiendo a WelcomePage (primera vez)');
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
        home: PermissionInitializer(
          child: ConnectivityWrapper(
            child: FutureBuilder<Widget>(
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
        ),
      ),
    );
  }
}