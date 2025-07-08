import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../helpers/constants.dart';
import '../../utils/routes/routes_name.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize AnimationController
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Duration of the entire animation
    );

    // Scale Animation (Text scales up)
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );

    // Slide Animation (Text slides up)
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 1), end: const Offset(0, -1.8))
            .animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Fade Animation (Text fades in)
    _fadeAnimation = Tween<double>(begin: 0, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward(); // Start the animation

    /// Check Existing User
    FirebaseAuth auth = FirebaseAuth.instance;
    // Automatically navigate to the next screen after animation ends
    Timer(const Duration(seconds: 3), () {
      if (auth.currentUser != null) {
        Navigator.pushReplacementNamed(context, RouteNames.mainScreen);
      } else {
        Navigator.pushReplacementNamed(context, RouteNames.onboardingScreen);
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
    // For Screen Resolution
    final double sw = MediaQuery.sizeOf(context).width;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black, // Background color
        body: Stack(
          children: [
            // Diagonal lines background
            CustomPaint(
              size: const Size(double.infinity, double.infinity),
              painter: DiagonalLinesPainter(),
            ),
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Text(
                          "Glintor",
                          style: TextStyle(
                            shadows: [
                              Shadow(
                                blurRadius: sw * 0.04,
                                color: Colors.white,
                                offset: const Offset(0, 6),
                              ),
                              BoxShadow(
                                blurRadius: sw * 0.06,
                                color: AppColors.yellow,
                                spreadRadius: sw * 0.8,
                              ),
                            ],
                            fontSize: sw * 0.1,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                            color: Colors.white,
                            // Text color
                            letterSpacing: sw * 0.014,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Text: Powered By
            Positioned(
              bottom: sw * 0.06,
              right: sw * 0.03,
              child: Text(
                "Powered By: Glintor",
                style: TextStyle(
                  shadows: [
                    Shadow(
                      blurRadius: sw * 0.04,
                      color: Colors.white,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      blurRadius: sw * 0.06,
                      color: AppColors.yellow,
                      spreadRadius: sw * 0.8,
                    ),
                  ],
                  fontSize: sw * 0.02,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Serif',
                  color: Colors.white,
                  // Text color
                  letterSpacing: sw * 0.014,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for diagonal background lines
class DiagonalLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 2;

    // Draw diagonal lines
    const spacing = 100.0;
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i + spacing), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
