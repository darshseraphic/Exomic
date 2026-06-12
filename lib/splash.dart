import 'dart:async';
import 'package:flutter/material.dart';
import 'navbar.dart'; // Import to gain access to ExomicNavbarShell

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Total animation runtime optimized for continuous fluid playback
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Ultra-smooth cubic easing curve for modern, industrial-grade presentation
    final CurvedAnimation smoothCurve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(smoothCurve);

    // Subtle expansion scaling without harsh back-spring breaks to remove stuttering
    _scaleAnimation = Tween<double>(begin: 0.94, end: 1.0).animate(smoothCurve);

    _controller.forward();

    // FIXED TIMER HOOK: Holds and transitions cleanly to your Exomic navbar shell
    Timer(const Duration(milliseconds: 2200), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const ExomicNavbarShell(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
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
    // Dynamic system background lookup respects app preferences automatically
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

    // Safely grab the text color depending on dark/light mode
    final textColor = Theme.of(context).textTheme.titleLarge?.color ?? Colors.white;

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