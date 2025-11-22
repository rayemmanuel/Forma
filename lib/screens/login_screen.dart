// File: lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/user_profile_model.dart';
import 'home_screen.dart';
import 'signup_screen.dart'; // Import SignupScreen
import 'forgot_password_screen.dart'; // Import ForgotPasswordScreen

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>(); // Use a Form key for validation
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool _obscurePassword = true; // State for password visibility

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Validate form before proceeding
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => isLoading = true);

    final result = await AuthService.login(
      email: emailController.text.trim(), // Trim whitespace
      password: passwordController.text,
    );

    // Check if the widget is still mounted before updating state
    if (!mounted) return;

    setState(() => isLoading = false);

    if (result['success']) {
      final userProfile = Provider.of<UserProfileModel>(context, listen: false);
      // Let loadUserData handle updating the profile model
      // await userProfile.loadUserData(); // Call loadUserData after successful login

      // Navigate to home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      _showError(
        result['message'] ?? 'Login failed. Please check your credentials.',
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter()),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating, // Make it float
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Use Container for gradient
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
            // Allow scrolling on smaller screens
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Form(
              // Wrap everything in a Form
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment:
                    CrossAxisAlignment.stretch, // Stretch items horizontally
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
                    "Welcome Back",
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
                    "Log in to your FORMA account",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                  const SizedBox(height: 40),

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
                      // Basic email validation
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
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
                      onToggleVisibility: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      obscureState: _obscurePassword,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),

                  // Forgot Password (Optional)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Forgot Password?",
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Login Button
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
                    onPressed: isLoading ? null : _handleLogin,
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Color(0xFF8B7355),
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            "Log In",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                  const SizedBox(height: 30),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Navigate to Signup Screen
                          Navigator.pushReplacement(
                            // Replace current screen
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignupScreen(),
                            ), // Ensure SignupScreen is imported
                          );
                        },
                        child: Text(
                          "Sign Up",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            decoration:
                                TextDecoration.underline, // Add underline
                            decorationColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20), // Add some bottom spacing
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method for consistent InputDecoration
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
