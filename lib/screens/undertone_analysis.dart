// lib/screens/undertone_analysis.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'palette_screen.dart'; // Screen with camera functionality
import '../utils/transitions_helper.dart'; // Keep if StaggeredListItem/AnimatedSlideIn is used

class UndertoneAnalysisScreen extends StatelessWidget {
  const UndertoneAnalysisScreen({super.key}); // Use super(key: key)

  // Theme Colors (consistent with other screens)
  static const Color themeColor = Color(0xFF8B7355);
  static const Color lightBackgroundColor = Color(0xFFF8F5F2);
  static const Color cardBackgroundColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackgroundColor, // Use light theme background
      appBar: AppBar(
        // Add AppBar for consistency
        backgroundColor: Colors.white,
        elevation: 1.0,
        // Removed leading back button if this is a main tab screen
        // leading: IconButton(...)
        title: Text(
          'Skin Undertone Guide', // More descriptive title
          style: GoogleFonts.inter(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          // Use ListView for scrolling content
          padding: const EdgeInsets.all(16.0), // Consistent padding
          children: [
            // --- Header Section ---
            // Reusing AnimatedSlideIn for entry animation
            AnimatedSlideIn(
              duration: const Duration(milliseconds: 500),
              delay: const Duration(milliseconds: 100),
              begin: const Offset(0, -0.2), // Slide from top
              child: _buildHeaderCard(context), // Extracted header card
            ),
            const SizedBox(height: 24),

            // --- Undertone Types Title ---
            Padding(
              padding: const EdgeInsets.only(
                left: 4.0,
                bottom: 16.0,
              ), // Align with cards
              child: Text(
                'Understanding Undertones',
                style: GoogleFonts.inter(
                  fontSize: 20, // Slightly larger title
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),

            // --- Undertone Cards ---
            // Reusing StaggeredListItem for entry animation
            const StaggeredListItem(
              index: 0,
              baseDelay: Duration(milliseconds: 150), // Adjust delay
              child: UndertoneCard(
                title: 'Warm Undertone',
                subtitle:
                    'Skin has hints of golden, yellow, or peachy hues. Often tans easily.',
                icon: Icons.wb_sunny_outlined, // Relevant icon
                iconColor: Color(0xFFF59E0B), // Warm color
                colors: [
                  Color(0xFFF59E0B),
                  Color(0xFFFCD34D),
                  Color(0xFFFBBC05),
                  Color(0xFFFBBF24),
                ], // Example warm palette
              ),
            ),
            const SizedBox(height: 16), // Consistent spacing
            const StaggeredListItem(
              index: 1,
              baseDelay: Duration(milliseconds: 150),
              child: UndertoneCard(
                title: 'Cool Undertone',
                subtitle:
                    'Skin has hints of pink, red, or bluish hues. May burn easily.',
                icon: Icons.ac_unit_outlined, // Relevant icon
                iconColor: Color(0xFF3B82F6), // Cool color
                colors: [
                  Color(0xFF3B82F6),
                  Color(0xFF60A5FA),
                  Color(0xFF93C5FD),
                  Color(0xFFBFDBFE),
                ], // Example cool palette
              ),
            ),
            const SizedBox(height: 16),
            const StaggeredListItem(
              index: 2,
              baseDelay: Duration(milliseconds: 150),
              child: UndertoneCard(
                title: 'Neutral Undertone',
                subtitle:
                    'Skin has a balance of warm and cool hues. Can wear most colors.',
                icon: Icons.balance_outlined, // Relevant icon
                iconColor: Color(0xFF10B981), // Neutral/Balanced color
                colors: [
                  Color(0xFF10B981),
                  Color(0xFF6EE7B7),
                  Color(0xFFA7F3D0),
                  Color(0xFFD1FAE5),
                ], // Example neutral palette
              ),
            ),
            const SizedBox(height: 20), // Extra space at the bottom
          ],
        ),
      ),
    );
  }

  // --- Extracted Header Card Widget ---
  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20), // Good padding
      decoration: BoxDecoration(
        color: cardBackgroundColor, // Use defined card color
        borderRadius: BorderRadius.circular(16), // Consistent rounding
        boxShadow: [
          // Subtle shadow
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        // Use Column for vertical layout
        crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch button
        children: [
          Row(
            // Icon and Title Row
            crossAxisAlignment: CrossAxisAlignment.start, // Align icon top
            children: [
              // Animated Icon
              TweenAnimationBuilder<double>(
                /* ... animation for icon ... */
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 700),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.palette_outlined, // Palette Icon
                        color: themeColor,
                        size: 28,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              Expanded(
                // Title and Subtitle Column
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analyze Your Skin Tone',
                      style: GoogleFonts.inter(
                        fontSize: 18, // Adjusted size
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Use your camera for an instant analysis and discover colors that flatter you most.', // Updated text
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.black54, // Softer color
                        height: 1.4, // Line spacing
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20), // Space before button
          // Button to navigate to PaletteScreen (camera screen)
          ElevatedButton.icon(
            icon: const Icon(
              Icons.camera_alt_outlined,
              size: 20,
            ), // Camera icon
            label: Text(
              'Start Camera Analysis',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () {
              // Use your elegant navigation or standard navigation
              context.elegantNavigateTo(const PaletteScreen());
              // Navigator.push(context, MaterialPageRoute(builder: (context) => const PaletteScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor, // Use theme color
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14), // Good padding
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25), // Consistent rounding
              ),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Redesigned Undertone Card Widget ---
class UndertoneCard extends StatelessWidget {
  // Changed to StatelessWidget
  final String title;
  final String subtitle;
  final IconData icon; // Added icon parameter
  final Color iconColor; // Added iconColor parameter
  final List<Color> colors;

  const UndertoneCard({
    super.key, // Use super(key: key)
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    // Removed GestureDetector and animation state for simplicity in StatelessWidget
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 20,
      ), // Adjusted padding
      decoration: BoxDecoration(
        color: UndertoneAnalysisScreen
            .cardBackgroundColor, // Use defined card color
        borderRadius: BorderRadius.circular(16), // Consistent rounding
        boxShadow: [
          // Consistent shadow
          BoxShadow(
            color: Colors.black.withOpacity(0.06), // Lighter shadow
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade200,
          width: 0.5,
        ), // Subtle border
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align icon top
        children: [
          // Icon Column
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(
                    0.15,
                  ), // Use specific color with opacity
                  borderRadius: BorderRadius.circular(
                    12,
                  ), // Match card rounding
                ),
                child: Icon(
                  icon,
                  size: 26,
                  color: iconColor,
                ), // Use specific icon & color
              ),
            ],
          ),

          const SizedBox(width: 16), // Space between icon and text
          // Text and Colors Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16, // Adjusted size
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6), // Space between title and subtitle
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13, // Adjusted size
                    color: Colors.black54, // Softer color
                    height: 1.4, // Line spacing
                  ),
                ),
                const SizedBox(height: 12), // Space before colors
                // Color Palette Row
                Row(
                  children: List.generate(
                    colors.length > 4 ? 4 : colors.length, // Show max 4 colors
                    (index) => Container(
                      width: 22, // Smaller circles
                      height: 22,
                      margin: const EdgeInsets.only(right: 6), // Closer spacing
                      decoration: BoxDecoration(
                        color: colors[index],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 1.0,
                        ), // White border
                        boxShadow: [
                          // Subtle shadow for circles
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
