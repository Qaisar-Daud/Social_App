import 'package:flutter/material.dart';
import 'package:social_app/src/helpers/empty_space.dart';
import 'package:social_app/src/views/other_screens/splash.dart';

import '../../helpers/constants.dart';
import '../../utils/routes/routes_name.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // For Screen Resolution
    final double sw = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Diagonal lines background
          CustomPaint(
            size: const Size(double.infinity, double.infinity),
            painter: DiagonalLinesPainter(),
          ),

          // Skip button
          Positioned(
            top: sw * 0.1,
            right: sw * 0.04,
            child: TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, RouteNames.loginScreen);
              },
              child: Text(
                "Skip",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: sw * 0.036,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Main content
          Padding(
            padding: EdgeInsets.only(
                left: sw * 0.02, right: sw * 0.02, top: sw * 0.7),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Connect With Open World',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: sw * 0.07,
                    fontWeight: FontWeight.bold,
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
                  ),
                ),
                20.height,
                Text(
                  'Enjoy to Watch Reels, Posts and Much More Entertainment, happy to share and Get People Reactions Connect With Open World',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.grey.withOpacity(0.99),
                    fontSize: sw * 0.038,
                    height: sw * 0.0046,
                    fontFamily: 'Inter',
                  ),
                ),
                const Spacer(),
                // Get Started Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                        context, RouteNames.loginScreen);
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(sw * 0.7, sw * 0.12),
                    backgroundColor: Colors.greenAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(sw * 0.06),
                    ),
                  ),
                  child: Text(
                    "Get Started",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: sw * 0.04,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins'),
                  ),
                ),
                20.height,
                // Signup Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(
                          color: Colors.white60,
                          fontFamily: 'Inter',
                          fontSize: sw * 0.03),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(
                            context, RouteNames.signupScreen);
                      },
                      child: Text(
                        "Sign up",
                        style: TextStyle(
                            color: Colors.greenAccent,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                            fontSize: sw * 0.03),
                      ),
                    ),
                  ],
                ),
                20.height,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
