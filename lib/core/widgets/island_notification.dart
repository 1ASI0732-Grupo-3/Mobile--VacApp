import 'package:flutter/material.dart';

class IslandNotification extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final Duration duration;
  final VoidCallback? onTap;

  const IslandNotification({
    super.key,
    required this.message,
    required this.icon,
    this.backgroundColor = const Color(0xFF002D26),
    this.textColor = const Color(0xFFFFF1BE),
    this.duration = const Duration(seconds: 3),
    this.onTap,
  });

  @override
  State<IslandNotification> createState() => _IslandNotificationState();

  static void show(
    BuildContext context, {
    required String message,
    required IconData icon,
    Color? backgroundColor,
    Color? textColor,
    Duration? duration,
    VoidCallback? onTap,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: IslandNotification(
            message: message,
            icon: icon,
            backgroundColor: backgroundColor ?? const Color(0xFF002D26),
            textColor: textColor ?? const Color(0xFFFFF1BE),
            duration: duration ?? const Duration(seconds: 3),
            onTap: onTap ?? () => overlayEntry.remove(),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Auto remove after duration
    Future.delayed(duration ?? const Duration(seconds: 3), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  static void showSuccess(
    BuildContext context, {
    required String message,
    Duration? duration,
    VoidCallback? onTap,
  }) {
    show(
      context,
      message: message,
      icon: Icons.check_circle,
      backgroundColor: const Color(0xFF4CAF50),
      textColor: Colors.white,
      duration: duration,
      onTap: onTap,
    );
  }

  static void showError(
    BuildContext context, {
    required String message,
    Duration? duration,
    VoidCallback? onTap,
  }) {
    show(
      context,
      message: message,
      icon: Icons.error,
      backgroundColor: const Color(0xFFE53E3E),
      textColor: Colors.white,
      duration: duration,
      onTap: onTap,
    );
  }

  static void showInfo(
    BuildContext context, {
    required String message,
    Duration? duration,
    VoidCallback? onTap,
  }) {
    show(
      context,
      message: message,
      icon: Icons.info,
      backgroundColor: const Color(0xFF002D26),
      textColor: const Color(0xFFFFF1BE),
      duration: duration,
      onTap: onTap,
    );
  }
}

class _IslandNotificationState extends State<IslandNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.icon,
                      color: widget.textColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: TextStyle(
                          color: widget.textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.close,
                      color: widget.textColor.withValues(alpha: 0.7),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
