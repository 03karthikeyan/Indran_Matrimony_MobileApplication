import 'package:flutter/material.dart';
import 'package:matrimony/UI_Screens/EditProfileScreen.dart';
import 'package:matrimony/UI_Screens/ProfileInsightsScreen.dart';
import 'package:matrimony/UI_Screens/ProfileListScreen.dart';
import 'package:matrimony/UI_Screens/interests_received_screen.dart';
import 'package:matrimony/UI_Screens/login_screen.dart';
import 'package:matrimony/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'subscription_screen.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;
  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  bool isActive = true;

  // 🔹 Subscription
  bool isSubscribed = false;
  Map<String, dynamic>? subscriptionDetails;

  @override
  void initState() {
    super.initState();
    fetchProfile();
    fetchSubscriptionStatus();
  }

  Future<void> fetchProfile() async {
    final result = await ApiService.getProfiles(widget.userId);

    if (result['success']) {
      setState(() {
        userData = result['user_data'];
        // Assume API sends status field: 1 = active, 0 = deactive
        isActive = userData?['status'].toString() == "1";
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      print(result['error']);
    }
  }

  //fetch Subscription Status

  Future<void> fetchSubscriptionStatus() async {
    try {
      final result = await ApiService.getSubscriptionStatus(widget.userId);
      if (!mounted) return;

      if (result['status'] == 'success') {
        final v = result['subscribed'];
        setState(() {
          // handle true/false, 1/0, or "true"/"false"
          isSubscribed = v == true || v == 1 || v == 'true';
          subscriptionDetails = result['subscription_details'];
        });
      } else {
        // optional: log or show a toast
        debugPrint('Subscription check failed: ${result['message']}');
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint('Subscription fetch error: $e');
    }
  }

  //active & De-active

  Future<void> toggleUserStatus() async {
    // Show loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response =
          isActive
              ? await ApiService.deactivateUser(widget.userId)
              : await ApiService.activateUser(widget.userId);

      Navigator.pop(context); // Close loader

      if (response['success'] == true) {
        // Flip status only if API succeeded
        setState(() => isActive = !isActive);

        _showAlertDialog(
          "Success",
          response['message'] ?? "Status updated successfully",
          Colors.green,
        );
      } else {
        _showAlertDialog(
          "Error",
          response['message'] ?? "Something went wrong",
          Colors.red,
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loader on error
      _showAlertDialog("Error", "Network error: $e", Colors.red);
    }
  }

  void _showAlertDialog(String title, String message, Color color) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Row(
              children: [
                Icon(Icons.info, color: color),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(color: color)),
              ],
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

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
                      if (isSubscribed) // show badge for premium
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Premium",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: () async {
                          if (userData != null) {
                            final updated = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => EditProfileScreen(
                                      userId: widget.userId,
                                      profileData: userData!,
                                    ),
                              ),
                            );

                            if (updated == true) {
                              fetchProfile();
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 22,
                    backgroundImage:
                        isLoading
                            ? const AssetImage('assets/Ellipse222(1).png')
                            : (userData != null &&
                                userData!['profile_img'] != null &&
                                userData!['profile_img'].toString().isNotEmpty)
                            ? NetworkImage(userData!['profile_img'])
                            : const AssetImage('assets/Ellipse222(1).png')
                                as ImageProvider,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    (userData?['name'] ?? "Unknown User"),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // 🔹 Membership Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isSubscribed ? 'Premium Member' : 'Free Member',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (!isSubscribed) // only show upgrade if free
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
            //intrestRecived SCreen
            _MenuItem(
              icon: Icons.favorite,
              title: 'Interests Received',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => InterestsReceivedScreen()),
                );
              },
            ),
            //Viewed Profile list showing method
            _MenuItem(
              icon: Icons.history,
              title: 'Viewed Profiles',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ProfileInsightsScreen()),
                );
              },
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
              icon: isActive ? Icons.visibility : Icons.visibility_off,
              title: isActive ? "Deactivate Profile" : "Activate Profile",
              onTap: () {
                showDialog(
                  context: context,
                  builder:
                      (_) => AlertDialog(
                        title: Text(
                          isActive ? "Deactivate Profile" : "Activate Profile",
                        ),
                        content: Text(
                          "Are you sure you want to ${isActive ? "deactivate" : "activate"} your profile?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              toggleUserStatus();
                            },
                            child: Text(isActive ? "Deactivate" : "Activate"),
                          ),
                        ],
                      ),
                );
              },
            ),

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
