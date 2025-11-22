import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key}); // Added const constructor

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Use Container for gradient background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFB5A491), // Lighter theme color
              Color(0xFF8B7355), // Main theme color
            ],
          ),
        ),
        child: SafeArea(
          // Ensure content is within safe areas
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center content vertically
              crossAxisAlignment:
                  CrossAxisAlignment.stretch, // Stretch buttons horizontally
              children: [
                // Spacer from top
                const Spacer(flex: 2),

                // Logo Placeholder (optional)
                Icon(
                  Icons.style_outlined, // Replace with your logo/icon
                  size: 70,
                  color: Colors.white.withOpacity(0.9),
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(2.0, 2.0),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Title
                Text(
                  "Welcome to FORMA", // Reiterate the app name or use a welcome message
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 32, // Consistent title size
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        blurRadius: 12.0,
                        color: Colors.black.withOpacity(0.4),
                        offset: const Offset(2.0, 3.0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Tagline
                Text(
                  "Log in or Sign up to\nstart your style journey.", // Clear call to action
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.6,
                  ),
                ),

                // Spacer before buttons
                const Spacer(flex: 3),

                // Log In Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // Primary action: White
                    foregroundColor: const Color(
                      0xFF8B7355,
                    ), // Theme color text
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                    ), // Taller button
                    elevation: 5,
                    shadowColor: Colors.black.withOpacity(0.2),
                  ),
                  onPressed: () {
                    // Navigate using a subtle transition
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const LoginScreen(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                        transitionDuration: const Duration(milliseconds: 300),
                      ),
                    );
                    // MaterialPageRoute(builder: (context) => const LoginScreen()),
                  },
                  child: Text(
                    "Log In",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 18), // Space between buttons
                // Sign Up Button (Outlined style for secondary action)
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white, // White text
                    side: const BorderSide(
                      color: Colors.white,
                      width: 1.5,
                    ), // White border
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                    ), // Match height
                  ),
                  onPressed: () {
                    // Navigate using a subtle transition
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const SignupScreen(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                        transitionDuration: const Duration(milliseconds: 300),
                      ),
                      //MaterialPageRoute(builder: (context) => const SignupScreen()),
                    );
                  },
                  child: Text(
                    "Sign Up",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),

                // Bottom Spacer
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
