import 'package:flutter/material.dart';
import 'package:matrimony/UI_Screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'subscription_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pinkColor = const Color(0xFFA51C48);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with profile info
            Container(
              padding: const EdgeInsets.only(
                top: 44,
                left: 18,
                right: 18,
                bottom: 20,
              ),
              decoration: BoxDecoration(
                color: pinkColor,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text(
                        'My Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey[300],
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Mr. Karthick',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Free Member',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SubscriptionScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Upgrade',
                            style: TextStyle(
                              color: pinkColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Profile completion
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  const BoxShadow(color: Colors.black12, blurRadius: 4),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Profile Completion',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '80%',
                        style: TextStyle(
                          color: pinkColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: 0.8,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(pinkColor),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Complete your profile to get more matches',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Menu items
            _MenuItem(
              icon: Icons.person,
              title: 'Personal Details',
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.family_restroom,
              title: 'Family Details',
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.school,
              title: 'Education & Career',
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.temple_hindu,
              title: 'Religious Background',
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.favorite,
              title: 'Partner Preferences',
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.photo_library,
              title: 'Photo Gallery',
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.workspace_premium,
              title: 'Subscription',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
                );
              },
            ),
            _MenuItem(
              icon: Icons.privacy_tip,
              title: 'Privacy Settings',
              onTap: () {},
            ),
            _MenuItem(icon: Icons.help, title: 'Help & Support', onTap: () {}),
            _MenuItem(
              icon: Icons.logout,
              title: 'Logout',
              onTap: () {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: Text('Logout'),
                        content: Text('Are you sure you want to log out?'),
                        actions: [
                          TextButton(
                            onPressed:
                                () => Navigator.pop(context), // Close dialog
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              // Close the dialog first
                              Navigator.of(context, rootNavigator: true).pop();

                              // Clear user_id from SharedPreferences
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.remove('user_id');

                              // Navigate to login and clear all previous routes
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => LoginScreen(),
                                  ),
                                  (route) => false,
                                );
                              });
                            },
                            child: Text('Logout'),
                          ),
                        ],
                      ),
                );
              },
              isLast: true,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isLast;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final pinkColor = const Color(0xFFA51C48);

    return Container(
      margin: EdgeInsets.only(left: 16, right: 16, bottom: isLast ? 0 : 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: pinkColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: pinkColor, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.black54,
        ),
        onTap: onTap,
      ),
    );
  }
}
