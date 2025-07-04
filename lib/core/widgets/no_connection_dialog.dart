import 'package:flutter/material.dart';

class NoConnectionDialog {
  static void show(BuildContext context, {VoidCallback? onRetry}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Imagen de No WiFi
                  Image.asset(
                    'assets/images/nowifi.png',
                    height: 120,
                    width: 120,
                  ),
                  const SizedBox(height: 20),
                  
                  // Título
                  const Text(
                    '¡Sin conexión!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00695C),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  
                  // Mensaje
                  const Text(
                    'Parece que no tienes conexión a internet. Verifica tu conexión WiFi o datos móviles para continuar.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  
                  // Botón de reintentar
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00695C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        onRetry?.call();
                      },
                      child: const Text(
                        'Reintentar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Mostrar diálogo simple sin botón de reintentar
  static void showSimple(BuildContext context) {
    show(context);
  }

  /// Mostrar diálogo con acción personalizada de reintento
  static void showWithRetry(BuildContext context, VoidCallback onRetry) {
    show(context, onRetry: onRetry);
  }
}
