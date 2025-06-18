import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Slide from top to center
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5), // Start off-screen top
      end: Offset.zero,             // End at center
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,     // Bouncy effect
    ));

    // Fade in during the slide
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();

    Timer(const Duration(seconds: 4), () {
      Navigator.of(context).pushReplacementNamed('/AuthWrapper'); // Change as needed
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              "assets/images/back1.png",
              fit: BoxFit.cover,
            ),
          ),
          // Animated logo
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Image.asset(
                  'assets/images/HomeSpice1.png',
                  height: 280,
                  width: 280,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
