import 'package:flutter/material.dart';
import 'package:matrimony/UI_Screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Indran Matrimony',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink.shade800),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
