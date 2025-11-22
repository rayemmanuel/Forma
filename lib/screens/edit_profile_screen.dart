import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/user_profile_model.dart';
import '../services/auth_service.dart'; // To save data
import 'change_password_screen.dart'; // Import the Change Password screen

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Controllers to manage text field input
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  // Email is usually not editable after signup
  // Password changes often have their own dedicated screen for security

  bool _isLoading = false; // To show loading indicator

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current user data
    final userProfile = Provider.of<UserProfileModel>(context, listen: false);
    _nameController = TextEditingController(text: userProfile.username ?? '');
    // Assuming username is derived from the name or stored separately
    _usernameController = TextEditingController(
      text: userProfile.username?.toLowerCase() ?? '',
    );
  }

  @override
  void dispose() {
    // Dispose controllers when the widget is removed
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  // --- Save Functionality ---
  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    final userProfile = Provider.of<UserProfileModel>(context, listen: false);
    final updates = <String, dynamic>{};

    // Check which fields have actually changed
    if (_nameController.text != (userProfile.username ?? '')) {
      updates['name'] = _nameController.text;
    }
    // Add other fields if you make them editable (e.g., username if separate)

    if (updates.isNotEmpty) {
      final result = await AuthService.updateProfile(updates);

      if (result['success']) {
        // Update the local state in UserProfileModel
        if (updates.containsKey('name')) {
          userProfile.updateUsername(updates['name']);
        }
        // Add updates for other fields if needed

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // Go back to the previous screen
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Update failed: ${result['message']}'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } else {
      // No changes detected
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No changes detected.')));
        Navigator.pop(context); // Still navigate back if no changes
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get email once, assuming it's not editable
    final userEmail =
        Provider.of<UserProfileModel>(context, listen: false).username ??
        'Not available'; // Replace with actual email if stored

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Lighter background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1.0,
        leading: IconButton(
          icon: const Icon(
            Icons.close,
            color: Colors.black54,
          ), // Use close icon
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Edit Profile",
          style: GoogleFonts.inter(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          // Save Button
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    // Show spinner when loading
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF8B7355),
                    ),
                  )
                : const Icon(
                    Icons.check,
                    color: Color(0xFF8B7355),
                  ), // Theme color
            onPressed: _isLoading
                ? null
                : _saveProfile, // Disable button when loading
          ),
        ],
      ),
      body: ListView(
        // Use ListView for scrollability
        padding: const EdgeInsets.all(24.0),
        children: [
          // Profile Picture Placeholder
          Center(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey.shade300,
                  child: Icon(
                    Icons.person_outline,
                    size: 60,
                    color: Colors.grey.shade600,
                  ),
                ),
                // Small edit icon overlay (visual only for now)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF8B7355),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Name Field
          _buildTextField(
            controller: _nameController,
            label: "Name",
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 20),

          // Username Field (if you have a separate username)
          _buildTextField(
            controller: _usernameController,
            label: "Username",
            icon: Icons.alternate_email,
          ),
          const SizedBox(height: 20),

          // Email Field (Read-only)
          _buildReadOnlyField(
            label: "Email Address",
            value: userEmail, // Display the user's email
            icon: Icons.email_outlined,
          ),
          const SizedBox(height: 20),

          // Placeholder for "Change Password" - Link to a separate screen
          ListTile(
            leading: Icon(Icons.lock_outline, color: Colors.grey.shade600),
            title: Text('Change Password', style: GoogleFonts.inter()),
            trailing: const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ), // Added color
            onTap: () {
              // --- THIS IS THE FIX ---
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
              );
              // -----------------------
            },
            // Added some visual polish
            tileColor: Colors.white, // Match card background
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ), // Rounded corners
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 4.0,
            ), // Adjust padding
          ),
        ],
      ),
    );
  }

  // Helper Widget for styled TextFields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      // Use TextFormField for validation potential
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: Colors.grey.shade600),
        prefixIcon: Icon(icon, color: Colors.grey.shade600, size: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15.0,
          horizontal: 15.0,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF8B7355),
            width: 1.5,
          ), // Theme color focus
        ),
        // Add errorBorder, focusedErrorBorder etc. if using validation
      ),
    );
  }

  // Helper Widget for Read-only fields
  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: Colors.grey.shade600),
        prefixIcon: Icon(icon, color: Colors.grey.shade600, size: 20),
        filled: true,
        fillColor:
            Colors.grey.shade100, // Slightly different background for read-only
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15.0,
          horizontal: 15.0,
        ),
        border: OutlineInputBorder(
          // Consistent border style
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Text(
        value,
        style: GoogleFonts.inter(
          color: Colors.black54,
          fontSize: 16,
        ), // Style for the value
      ),
    );
  }
}
