import 'package:flutter/material.dart';
import 'dart:async';
import '../services/connectivity_service.dart';
import 'no_connection_dialog.dart';

class ConnectivityWrapper extends StatefulWidget {
  final Widget child;
  final bool showDialogOnDisconnect;
  final VoidCallback? onConnected;
  final VoidCallback? onDisconnected;

  const ConnectivityWrapper({
    super.key,
    required this.child,
    this.showDialogOnDisconnect = true,
    this.onConnected,
    this.onDisconnected,
  });

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  late StreamSubscription<bool> _connectivitySubscription;
  final ConnectivityService _connectivityService = ConnectivityService();
  bool _isDialogShown = false;

  @override
  void initState() {
    super.initState();
    _initializeConnectivity();
  }

  Future<void> _initializeConnectivity() async {
    // Inicializar el servicio
    await _connectivityService.initialize();
    
    // Verificar estado inicial
    if (!_connectivityService.isConnected && widget.showDialogOnDisconnect) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showNoConnectionDialog();
      });
    }

    // Escuchar cambios de conectividad
    _connectivitySubscription = _connectivityService.connectivityStream.listen((isConnected) {
      if (mounted) {
        if (isConnected) {
          _onConnected();
        } else {
          _onDisconnected();
        }
      }
    });
  }

  void _onConnected() {
    widget.onConnected?.call();
    
    // Cerrar diálogo si está abierto
    if (_isDialogShown) {
      Navigator.of(context, rootNavigator: true).pop();
      _isDialogShown = false;
    }
  }

  void _onDisconnected() {
    widget.onDisconnected?.call();
    
    if (widget.showDialogOnDisconnect && !_isDialogShown) {
      _showNoConnectionDialog();
    }
  }

  void _showNoConnectionDialog() {
    if (!mounted || _isDialogShown) return;
    
    _isDialogShown = true;
    NoConnectionDialog.showWithRetry(
      context,
      () async {
        _isDialogShown = false;
        // Verificar conectividad al reintentar
        final isConnected = await _connectivityService.checkConnection();
        if (!isConnected && mounted) {
          // Si sigue sin conexión, mostrar el diálogo nuevamente después de un breve delay
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && !_connectivityService.isConnected) {
              _showNoConnectionDialog();
            }
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
