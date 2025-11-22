import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'package:provider/provider.dart';
import '../models/user_profile_model.dart';
import '../services/auth_service.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';

class MyFormaScreen extends StatelessWidget {
  const MyFormaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen for changes to rebuild when data loads/updates
    final userProfile = Provider.of<UserProfileModel>(context);

    return Scaffold(
      // Lighter, more neutral background
      backgroundColor: const Color(0xFFF5F5F5), // Changed background color
      appBar: AppBar(
        title: Text(
          'My Forma Profile',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white, // White app bar
        elevation: 1.0, // Subtle shadow
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          // Changed to ListView for scrollability
          padding: const EdgeInsets.all(20.0), // Consistent padding
          children: [
            // --- Profile Header ---
            _buildProfileHeader(userProfile),
            const SizedBox(height: 30),

            // --- Action Buttons ---
            _buildActionButtons(context),
            const SizedBox(height: 30),

            // --- Profile Details Section ---
            _buildProfileDetailsCard(userProfile),
            const SizedBox(height: 30), // Spacing before logout
            // --- Logout Button ---
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  // Helper Widget for Profile Header
  Widget _buildProfileHeader(UserProfileModel userProfile) {
    return Row(
      children: [
        CircleAvatar(
          radius: 50, // Slightly smaller avatar
          backgroundColor: Colors.grey.shade300,
          child: Icon(
            Icons.person_outline, // Using outline icon
            size: 50,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userProfile.username ?? "Loading...", // Show loading state
                style: GoogleFonts.inter(
                  // Use Google Fonts
                  fontWeight: FontWeight.bold,
                  fontSize: 22, // Larger username
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                // You might want to display the user's email here instead
                "@${userProfile.username?.toLowerCase() ?? "..."}",
                style: GoogleFonts.inter(fontSize: 14, color: Colors.black54),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper Widget for Edit Profile / Other Actions
  Widget _buildActionButtons(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.edit_outlined, size: 18),
      label: const Text("Edit Profile"),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EditProfileScreen()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF8B7355), // Theme color
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 2,
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
      ),
    );
  }

  // Helper Widget for Displaying Profile Details
  Widget _buildProfileDetailsCard(UserProfileModel userProfile) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your Style Profile",
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 15),
            _buildDetailItem(
              icon: Icons.wc,
              label: "Gender",
              value: userProfile.gender ?? "Not set",
            ),
            const Divider(height: 20),
            _buildDetailItem(
              icon: Icons.accessibility_new,
              label: "Body Type",
              value: userProfile.bodyType ?? "Not set",
            ),
            const Divider(height: 20),
            _buildDetailItem(
              icon: Icons.palette_outlined,
              label: "Skin Undertone",
              value: userProfile.skinUndertone ?? "Not set",
            ),
          ],
        ),
      ),
    );
  }

  // Helper for individual detail items within the card
  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 20),
        const SizedBox(width: 15),
        Text(
          "$label:",
          style: GoogleFonts.inter(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(), // Pushes value to the right
        Text(
          value,
          style: GoogleFonts.inter(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // Helper Widget for Logout Button (styled differently)
  Widget _buildLogoutButton(BuildContext context) {
    return OutlinedButton.icon(
      icon: const Icon(Icons.logout, size: 18, color: Colors.redAccent),
      label: const Text("Log Out"),
      onPressed: () => _showLogoutDialog(context),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.redAccent,
        side: const BorderSide(color: Colors.redAccent),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
      ),
    );
  }

  // Logout Dialog Function (no changes needed here)
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop(); // Close dialog
              await AuthService.logout();
              if (context.mounted) {
                // Navigate and remove all previous routes
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false, // Remove all routes
                );
              }
            },
            child: const Text("Log Out", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
