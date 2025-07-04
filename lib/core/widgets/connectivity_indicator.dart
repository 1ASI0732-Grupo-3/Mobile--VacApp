import 'package:flutter/material.dart';
import 'dart:async';
import '../services/connectivity_service.dart';

class ConnectivityIndicator extends StatefulWidget {
  final Widget child;
  final bool showBanner;
  final Color connectedColor;
  final Color disconnectedColor;
  final Duration animationDuration;

  const ConnectivityIndicator({
    super.key,
    required this.child,
    this.showBanner = true,
    this.connectedColor = Colors.green,
    this.disconnectedColor = Colors.red,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<ConnectivityIndicator> createState() => _ConnectivityIndicatorState();
}

class _ConnectivityIndicatorState extends State<ConnectivityIndicator>
    with SingleTickerProviderStateMixin {
  late StreamSubscription<bool> _connectivitySubscription;
  final ConnectivityService _connectivityService = ConnectivityService();
  late AnimationController _animationController;
  
  bool _isConnected = true;
  bool _showBanner = false;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _initializeConnectivity();
  }

  Future<void> _initializeConnectivity() async {
    await _connectivityService.initialize();
    
    setState(() {
      _isConnected = _connectivityService.isConnected;
    });

    _connectivitySubscription = _connectivityService.connectivityStream.listen((isConnected) {
      if (mounted) {
        setState(() {
          _isConnected = isConnected;
        });
        
        if (widget.showBanner) {
          _showConnectivityBanner();
        }
      }
    });
  }

  void _showConnectivityBanner() {
    setState(() {
      _showBanner = true;
    });
    
    _animationController.forward();
    
    // Ocultar el banner después de 3 segundos si está conectado
    if (_isConnected) {
      Timer(const Duration(seconds: 3), () {
        if (mounted) {
          _hideBanner();
        }
      });
    }
  }

  void _hideBanner() {
    _animationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _showBanner = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          widget.child,
          
          // Banner de conectividad
          if (_showBanner && widget.showBanner)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -1),
                  end: Offset.zero,
                ).animate(_animationController),
                child: SafeArea(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: _isConnected 
                        ? widget.connectedColor 
                        : widget.disconnectedColor,
                    child: Row(
                      children: [
                        Icon(
                          _isConnected 
                              ? Icons.wifi 
                              : Icons.wifi_off,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _isConnected 
                                ? '¡Conectado a internet!' 
                                : 'Sin conexión a internet',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (!_isConnected)
                          TextButton(
                            onPressed: () async {
                              final hasConnection = await _connectivityService.checkConnection();
                              if (!hasConnection) {
                                // Mostrar diálogo de no conexión si sigue sin internet
                              }
                            },
                            child: const Text(
                              'Reintentar',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
