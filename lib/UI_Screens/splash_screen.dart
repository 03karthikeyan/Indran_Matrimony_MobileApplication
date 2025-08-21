import 'package:flutter/material.dart';
import 'package:matrimony/UI_Screens/main_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 3)); // Splash duration

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (mounted) {
      if (userId != null && userId.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainNavigation()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => OnboardingScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA32046),
      body: Center(
        child: Image.asset(
          'assets/SplashScreen.png',
          fit: BoxFit.contain,
          width: MediaQuery.of(context).size.width * 0.6,
        ),
      ),
    );
  }
}
