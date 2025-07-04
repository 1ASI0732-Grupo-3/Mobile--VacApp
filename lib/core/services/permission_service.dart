import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  /// Lista de permisos críticos que necesita la aplicación
  static const List<Permission> _criticalPermissions = [
    Permission.camera,
    Permission.photos,
    Permission.notification,
  ];

  /// Lista de permisos opcionales (pueden mejora la experiencia)
  static const List<Permission> _optionalPermissions = [
    Permission.storage,
    Permission.microphone,
    Permission.location,
    Permission.contacts,
  ];

  /// Todos los permisos
  static List<Permission> get allPermissions => [
    ..._criticalPermissions,
    ..._optionalPermissions,
  ];

  /// Verificar si todos los permisos críticos están concedidos
  Future<bool> hasAllCriticalPermissions() async {
    for (Permission permission in _criticalPermissions) {
      final status = await permission.status;
      if (!status.isGranted) {
        print('❌ Permiso ${permission.toString()} no concedido: $status');
        return false;
      }
    }
    print('✅ Todos los permisos críticos están concedidos');
    return true;
  }

  /// Verificar si todos los permisos están concedidos
  Future<bool> hasAllPermissions() async {
    for (Permission permission in allPermissions) {
      final status = await permission.status;
      if (!status.isGranted) {
        return false;
      }
    }
    return true;
  }

  /// Solicitar todos los permisos críticos
  Future<Map<Permission, PermissionStatus>> requestCriticalPermissions() async {
    print('🔐 Solicitando permisos críticos...');
    Map<Permission, PermissionStatus> statuses = {};
    
    for (Permission permission in _criticalPermissions) {
      print('🔐 Solicitando permiso: $permission');
      final status = await permission.request();
      statuses[permission] = status;
      print('🔐 Estado del permiso $permission: $status');
    }
    
    return statuses;
  }

  /// Solicitar todos los permisos necesarios
  Future<Map<Permission, PermissionStatus>> requestAllPermissions() async {
    print('🔐 Solicitando todos los permisos...');
    Map<Permission, PermissionStatus> statuses = {};
    
    for (Permission permission in allPermissions) {
      final status = await permission.request();
      statuses[permission] = status;
    }
    
    return statuses;
  }

  /// Solicitar un permiso específico
  Future<PermissionStatus> requestPermission(Permission permission) async {
    return await permission.request();
  }

  /// Verificar el estado de un permiso específico
  Future<PermissionStatus> checkPermission(Permission permission) async {
    return await permission.status;
  }

  /// Abrir configuración de la aplicación para permisos
  Future<bool> openAppSettings() async {
    return await openAppSettings();
  }

  /// Obtener descripción amigable del permiso
  String getPermissionDescription(Permission permission) {
    switch (permission) {
      case Permission.camera:
        return 'Tomar fotos de bovinos y vacunas';
      case Permission.photos:
        return 'Seleccionar imágenes de la galería';
      case Permission.notification:
        return 'Enviar recordatorios y alertas importantes';
      case Permission.storage:
        return 'Guardar datos localmente';
      case Permission.microphone:
        return 'Grabar notas de voz (opcional)';
      case Permission.location:
        return 'Ubicación de establos (opcional)';
      case Permission.contacts:
        return 'Compartir información (opcional)';
      default:
        return 'Funcionalidad de la aplicación';
    }
  }

  /// Obtener nombre amigable del permiso
  String getPermissionName(Permission permission) {
    switch (permission) {
      case Permission.camera:
        return 'Cámara';
      case Permission.photos:
        return 'Fotos';
      case Permission.notification:
        return 'Notificaciones';
      case Permission.storage:
        return 'Almacenamiento';
      case Permission.microphone:
        return 'Micrófono';
      case Permission.location:
        return 'Ubicación';
      case Permission.contacts:
        return 'Contactos';
      default:
        return permission.toString();
    }
  }

  /// Verificar si un permiso es crítico
  bool isCriticalPermission(Permission permission) {
    return _criticalPermissions.contains(permission);
  }

  /// Solicitar permisos críticos directamente del sistema
  Future<bool> requestPermissionsDirectly() async {
    try {
      print('🔐 Solicitando permisos críticos directamente del sistema...');

      // Primero verificar si ya tenemos los permisos críticos
      final hasCritical = await hasAllCriticalPermissions();
      if (hasCritical) {
        print('✅ Ya tenemos todos los permisos críticos');
        return true;
      }

      // Solicitar permisos críticos directamente
      final statuses = await requestCriticalPermissions();
      
      // Verificar resultados
      List<Permission> deniedPermissions = [];
      for (var entry in statuses.entries) {
        if (entry.value != PermissionStatus.granted) {
          deniedPermissions.add(entry.key);
        }
      }

      if (deniedPermissions.isNotEmpty) {
        print('❌ Algunos permisos fueron denegados: $deniedPermissions');
        print('ℹ️ La app continuará con funcionalidad limitada');
        return false;
      }

      print('✅ Todos los permisos críticos fueron concedidos');
      return true;

    } catch (e) {
      print('❌ Error solicitando permisos: $e');
      return false;
    }
  }

  /// Mostrar diálogo explicativo para permisos
  static void showPermissionDialog(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00695C),
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
              height: 1.4,
            ),
          ),
          actions: [
            if (onCancel != null)
              TextButton(
                onPressed: onCancel,
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00695C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: onConfirm,
              child: const Text(
                'Permitir',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Manejar permisos al iniciar la aplicación
  Future<bool> handleAppPermissions(BuildContext context) async {
    // Verificar si ya tenemos todos los permisos
    if (await hasAllPermissions()) {
      return true;
    }

    // Mostrar diálogo explicativo
    bool permissionsGranted = false;
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Permisos necesarios',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00695C),
            ),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'VacApp necesita los siguientes permisos para funcionar correctamente:',
                style: TextStyle(fontSize: 16, height: 1.4),
              ),
              SizedBox(height: 16),
              _PermissionItem(
                icon: Icons.camera_alt,
                title: 'Cámara',
                description: 'Para tomar fotos de los animales',
              ),
              _PermissionItem(
                icon: Icons.photo_library,
                title: 'Galería',
                description: 'Para seleccionar fotos existentes',
              ),
              _PermissionItem(
                icon: Icons.notifications,
                title: 'Notificaciones',
                description: 'Para recordatorios de vacunación',
              ),
              _PermissionItem(
                icon: Icons.storage,
                title: 'Almacenamiento',
                description: 'Para guardar datos localmente',
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00695C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(double.infinity, 45),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                final statuses = await requestAllPermissions();
                permissionsGranted = statuses.values.every((status) => status.isGranted);
              },
              child: const Text(
                'Conceder Permisos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    return permissionsGranted;
  }
}

class _PermissionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _PermissionItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF00695C),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
