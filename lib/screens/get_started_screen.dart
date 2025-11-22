import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'welcome_screen.dart'; // Ensure this import is correct

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand, // Make stack children fill the screen
        children: [
          // --- Background Gradient ---
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                // Use a richer gradient with your theme colors
                colors: [
                  Color(0xFFB5A491), // Lighter beige/brown
                  Color(0xFF8B7355), // Main theme brown
                  Color(0xFF7D6B58), // Slightly darker brown
                ],
                stops: [0.0, 0.6, 1.0], // Adjust gradient flow
              ),
            ),
          ),

          // --- Content Layer ---
          SafeArea(
            // Ensure content avoids system UI areas
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30.0,
              ), // Slightly more horizontal padding
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Spacer to push content down
                  const Spacer(flex: 3),

                  // App Logo Placeholder (Optional but recommended)
                  // Replace with your actual logo widget if you have one
                  Icon(
                    Icons.style, // Example icon
                    size: 80, // Larger icon
                    color: Colors.white.withOpacity(0.9),
                    shadows: [
                      // Add shadow to the icon too
                      Shadow(
                        blurRadius: 15.0,
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(3.0, 3.0),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Title
                  Text(
                    "FORMA", // More engaging title
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      // Or another stylish font
                      fontSize: 36, // Larger title
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5, // Slight letter spacing
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
                    "Get personalized fashion recommendations\ntailored just for you.", // Refined tagline
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 17, // Good readability
                      color: Colors.white.withOpacity(0.9),
                      height: 1.6, // Increased line height
                    ),
                  ),

                  // Spacer to push button down
                  const Spacer(flex: 4),

                  // Get Started Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // White button stands out
                      foregroundColor: const Color(
                        0xFF8B7355,
                      ), // Theme text color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          30,
                        ), // Smooth curves
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 55, // Wider button
                        vertical: 18, // Taller button
                      ),
                      elevation: 8, // More prominent shadow
                      shadowColor: Colors.black.withOpacity(
                        0.3,
                      ), // Softer shadow color
                    ),
                    onPressed: () {
                      // Navigate to WelcomeScreen, preventing return to this screen
                      Navigator.pushReplacement(
                        context,
                        // Add a subtle fade transition (optional)
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  WelcomeScreen(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                          transitionDuration: const Duration(milliseconds: 400),
                        ),
                        // MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                      );
                    },
                    child: Text(
                      "Get Started", // Simpler text
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 0.5, // Match title spacing slightly
                      ),
                    ),
                  ),

                  // Bottom Spacer
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
