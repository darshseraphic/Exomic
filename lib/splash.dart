import 'dart:async';
import 'package:flutter/material.dart';
import 'navbar.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    final CurvedAnimation smoothCurve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(smoothCurve);
    _scaleAnimation = Tween<double>(begin: 0.94, end: 1.0).animate(smoothCurve);

    _controller.forward();
    Timer(const Duration(milliseconds: 2200), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const ExomicNavbarShell(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity:
                    CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final textColor =
        Theme.of(context).textTheme.titleLarge?.color ?? Colors.white;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Text(
              'EXOMIC',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: textColor,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
