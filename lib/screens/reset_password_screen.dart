// lib/screens/reset_password_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart'; // You'll add a method here
import 'login_screen.dart'; // Navigate back to login after reset

class ResetPasswordScreen extends StatefulWidget {
  final String email; // Receive email from previous screen
  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // --- Backend Call ---
    // You need to add this resetPassword method to AuthService
    final result = await AuthService.resetPassword(
      email: widget.email,
      newPassword: _newPasswordController.text,
    );
    // --------------------

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Password reset successfully! Please log in.',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(10),
        ),
      );
      // Navigate back to Login Screen, clearing this screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false, // Remove all previous routes
      );
    } else {
      _showError(result['message'] ?? 'Password reset failed.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Reusing styles
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          /* Gradient like LoginScreen */
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFB5A491), Color(0xFF8B7355)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icon( /* Your App Icon */ ),
                  const SizedBox(height: 25),
                  Text(
                    "Reset Your Password",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Enter a new password for ${widget.email}",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // New Password Field
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: _obscureNew,
                    style: GoogleFonts.inter(color: Colors.black87),
                    decoration: _buildInputDecoration(
                      // Use helper
                      hintText: "New Password",
                      icon: Icons.lock_outline,
                      isPassword: true,
                      obscureState: _obscureNew,
                      onToggleVisibility: () =>
                          setState(() => _obscureNew = !_obscureNew),
                    ),
                    validator: (value) {
                      /* Password validation like SignupScreen */
                      if (value == null || value.isEmpty)
                        return 'Please enter a new password';
                      if (value.length < 6)
                        return 'Password must be at least 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),

                  // Confirm New Password Field
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirm,
                    style: GoogleFonts.inter(color: Colors.black87),
                    decoration: _buildInputDecoration(
                      // Use helper
                      hintText: "Confirm New Password",
                      icon: Icons.lock_outline,
                      isPassword: true,
                      obscureState: _obscureConfirm,
                      onToggleVisibility: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                    validator: (value) {
                      /* Confirm password validation like SignupScreen */
                      if (value == null || value.isEmpty)
                        return 'Please confirm your new password';
                      if (value != _newPasswordController.text)
                        return 'Passwords do not match';
                      return null;
                    },
                  ),
                  const SizedBox(height: 35),

                  // Submit Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      /* Style like LoginScreen */
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF8B7355),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 5,
                    ),
                    onPressed: _isLoading ? null : _handleResetPassword,
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Color(0xFF8B7355),
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            "Reset Password",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Copy Input Decoration Helper from Login Screen ---
  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    VoidCallback? onToggleVisibility,
    bool obscureState = false,
  }) {
    // ... Paste the _buildInputDecoration method from LoginScreen here ...
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.inter(color: Colors.grey.shade500),
      prefixIcon: Icon(icon, color: Colors.grey.shade600, size: 20),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                obscureState
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.grey.shade500,
                size: 20,
              ),
              onPressed: onToggleVisibility,
            )
          : null,
      filled: true,
      fillColor: Colors.white.withOpacity(0.95),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 15.0,
        horizontal: 15.0,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF8B7355), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }
}
