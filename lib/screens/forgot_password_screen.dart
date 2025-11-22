// lib/screens/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart'; // You'll add a method here
import 'reset_password_screen.dart'; // The next screen

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleRequestReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // --- Backend Call ---
    // You need to add this requestReset method to AuthService
    final result = await AuthService.requestReset(
      email: _emailController.text.trim(),
    );
    // --------------------

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success']) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ResetPasswordScreen(email: _emailController.text.trim()),
        ),
      );
    } else {
      _showError(result['message'] ?? 'Could not find account.');
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
    // Reusing styles from Login/Signup
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
                    "Forgot Password?",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Enter the email associated with your account.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: GoogleFonts.inter(color: Colors.black87),
                    decoration: _buildInputDecoration(
                      hintText: "Email Address",
                      icon: Icons.email_outlined,
                    ), // Use helper
                    validator: (value) {
                      /* Email validation like SignupScreen */
                      if (value == null || value.trim().isEmpty)
                        return 'Please enter your email';
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value.trim()))
                        return 'Please enter a valid email address';
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

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
                    onPressed: _isLoading ? null : _handleRequestReset,
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
                            "Find Account",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Back to Login",
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
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
  }) {
    // ... Paste the _buildInputDecoration method from LoginScreen here ...
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.inter(color: Colors.grey.shade500),
      prefixIcon: Icon(icon, color: Colors.grey.shade600, size: 20),
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
