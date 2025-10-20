import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Imports from your new code
import 'models/user_profile_model.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart'; // Renamed from home_screen for clarity

// Import from your original code to set the starting screen
import 'screens/get_started_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProfileModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FORMA',
      debugShowCheckedModeBanner: false,
      // This uses the new, modern Material 3 theme
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8B7355)),
        useMaterial3: true,
      ),
      // --- THIS IS THE ONLY CHANGE ---
      // The app's flow is preserved by starting at GetStartedScreen
      // instead of the AuthChecker.
      home: GetStartedScreen(),
    );
  }
}

// --- IMPORTANT ---
// The AuthChecker widget is still here for you to use.
// You can navigate to it from a button on your GetStartedScreen
// when you're ready to handle login.

// Check authentication status
class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // This logic now runs when you navigate TO the AuthChecker,
    // not when the app first starts.
    final isLoggedIn = await AuthService.isLoggedIn();
    if (!mounted) return;

    if (isLoggedIn) {
      final userProfile = Provider.of<UserProfileModel>(context, listen: false);
      await userProfile.loadUserData();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFE7DFD8),
      body: Center(child: CircularProgressIndicator(color: Color(0xFF8B7355))),
    );
  }
}
