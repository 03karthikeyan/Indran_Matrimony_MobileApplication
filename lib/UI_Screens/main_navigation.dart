import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // for SystemNavigator.pop
import 'custom_nav_bar.dart';
import 'home_screen.dart';
import 'matches_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';

class MainNavigation extends StatefulWidget {
  final int userId; // 👈 Add this
  const MainNavigation({Key? key, required this.userId}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(userId: widget.userId), // ✅ Pass here
      const MatchesScreen(),
      ChatScreen(userId: widget.userId),
      ProfileScreen(userId: widget.userId),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 0) {
          // ✅ If not on Home, go back to Home
          setState(() {
            _currentIndex = 0;
          });
          return false; // prevent closing app
        } else {
          // ✅ If already on Home, close the app
          SystemNavigator.pop();
          return true;
        }
      },
      child: Scaffold(
        body: _screens[_currentIndex],
        bottomNavigationBar: CustomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
