// File: lib/screens/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart'; // Keep for potential future use
import 'gender_selection_screen.dart';
import 'login_screen.dart'; // Import LoginScreen for navigation

class SignupScreen extends StatefulWidget {
  // Changed to StatefulWidget
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>(); // Form key for validation
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isLoading = false; // Keep loading state if needed later
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    // Validate the form
    if (!_formKey.currentState!.validate()) {
      return; // Stop if validation fails
    }

    // No need to set isLoading here as we navigate immediately
    // setState(() => isLoading = true);

    // Proceed to GenderSelectionScreen with the validated data
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => GenderSelectionScreen(
          name: nameController.text.trim(), // Trim whitespace
          email: emailController.text.trim(),
          password: passwordController.text,
        ),
      ),
    );

    // No need to set isLoading to false here
    // setState(() => isLoading = false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter()),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Form(
              // Wrap in a Form
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo/Icon Placeholder
                  Icon(
                    Icons.style_outlined, // Example icon
                    size: 60,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  const SizedBox(height: 25),

                  // Title
                  Text(
                    "Create Account", // Updated title
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 8.0,
                          color: Colors.black.withOpacity(0.3),
                          offset: Offset(1.0, 1.0),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "Join FORMA to get started", // Subtitle
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Name Field
                  TextFormField(
                    controller: nameController,
                    keyboardType: TextInputType.name,
                    textCapitalization:
                        TextCapitalization.words, // Capitalize words
                    style: GoogleFonts.inter(color: Colors.black87),
                    decoration: _buildInputDecoration(
                      hintText: "Your Name",
                      icon: Icons.person_outline,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),

                  // Email Field
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: GoogleFonts.inter(color: Colors.black87),
                    decoration: _buildInputDecoration(
                      hintText: "Email Address",
                      icon: Icons.email_outlined,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value.trim())) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),

                  // Password Field
                  TextFormField(
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    style: GoogleFonts.inter(color: Colors.black87),
                    decoration: _buildInputDecoration(
                      hintText: "Password",
                      icon: Icons.lock_outline,
                      isPassword: true,
                      obscureState: _obscurePassword,
                      onToggleVisibility: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),

                  // Confirm Password Field
                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    style: GoogleFonts.inter(color: Colors.black87),
                    decoration: _buildInputDecoration(
                      hintText: "Confirm Password",
                      icon: Icons.lock_outline,
                      isPassword: true,
                      obscureState: _obscureConfirmPassword,
                      onToggleVisibility: () => setState(
                        () =>
                            _obscureConfirmPassword = !_obscureConfirmPassword,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 35),

                  // Sign Up Button (Navigates to Gender Selection)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF8B7355),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 5,
                    ),
                    onPressed: isLoading
                        ? null
                        : _handleSignUp, // Keep loading state check if needed later
                    child:
                        isLoading // Keep loading indicator logic
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Color(0xFF8B7355),
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            "Next: Select Gender", // Updated button text
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                  const SizedBox(height: 30),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Navigate back to Login Screen
                          Navigator.pushReplacement(
                            // Replace current screen
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Log In",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20), // Add bottom spacing
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Reusing the Input Decoration Helper from Login Screen ---
  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    VoidCallback? onToggleVisibility,
    bool obscureState = false,
  }) {
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
      fillColor: Colors.white.withOpacity(
        0.95,
      ), // Slightly transparent white fill
      contentPadding: const EdgeInsets.symmetric(
        vertical: 15.0,
        horizontal: 15.0,
      ),
      border: OutlineInputBorder(
        // Use OutlineInputBorder for all states
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none, // No border by default (uses fill color)
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.grey.shade300.withOpacity(0.5),
        ), // Subtle border
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF8B7355),
          width: 1.5,
        ), // Theme color focus
      ),
      errorBorder: OutlineInputBorder(
        // Error state
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
