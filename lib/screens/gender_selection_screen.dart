import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/user_profile_model.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class GenderSelectionScreen extends StatefulWidget {
  final String name;
  final String email;
  final String password;

  const GenderSelectionScreen({
    super.key,
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  State<GenderSelectionScreen> createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  String? selectedGender;
  bool isLoading = false;

  Future<void> _handleContinue() async {
    if (selectedGender == null) return;

    setState(() => isLoading = true);

    // Call signup API with all data including gender
    final result = await AuthService.signUp(
      name: widget.name,
      email: widget.email,
      password: widget.password,
      gender: selectedGender!,
    );

    setState(() => isLoading = false);

    if (result['success']) {
      // Update UserProfileModel with user data
      final userProfile = Provider.of<UserProfileModel>(context, listen: false);
      userProfile.updateUsername(widget.name);
      userProfile.updateGender(selectedGender!);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } else {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Signup failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[100],
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Let's get your\nperfect Forma!",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Select your preference to unlock\ntailored fashion insights",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF8E7E7E),
              ),
            ),
            const SizedBox(height: 80),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ChoiceChip(
                  label: const Text("Female"),
                  selected: selectedGender == "Female",
                  onSelected: (bool selected) {
                    setState(() => selectedGender = "Female");
                  },
                  selectedColor: Colors.black,
                  backgroundColor: Colors.white,
                  labelStyle: GoogleFonts.inter(
                    color: selectedGender == "Female"
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
                ChoiceChip(
                  label: const Text("Male"),
                  selected: selectedGender == "Male",
                  onSelected: (bool selected) {
                    setState(() => selectedGender = "Male");
                  },
                  selectedColor: Colors.black,
                  backgroundColor: Colors.white,
                  labelStyle: GoogleFonts.inter(
                    color: selectedGender == "Male"
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: 250,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: (selectedGender == null || isLoading)
                    ? null
                    : _handleContinue,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Continue",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
