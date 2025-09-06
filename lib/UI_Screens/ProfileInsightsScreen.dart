import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:matrimony/UI_Screens/ProfileListScreen.dart';
import '../services/api_service.dart';

class ProfileInsightsScreen extends StatefulWidget {
  const ProfileInsightsScreen({super.key});

  @override
  State<ProfileInsightsScreen> createState() => _ProfileInsightsScreenState();
}

class _ProfileInsightsScreenState extends State<ProfileInsightsScreen> {
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString("user_id"); // 👈 fetch logged-in user id
    });
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // Set your desired color here
        ),
        title: const Text(
          "Profile Insights",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.pink.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _InsightCard(
              icon: Icons.visibility,
              title: "Who Viewed My Profile",
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => ProfileListScreen(
                          title: "Who Viewed My Profile",
                          futureProfiles: ApiService.fetchWhoViewedMyProfile(
                            userId!,
                            10,
                            0,
                            userId!,
                          ),
                        ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _InsightCard(
              icon: Icons.history,
              title: "Recently Viewed Profiles",
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => ProfileListScreen(
                          title: "Recently Viewed Profiles",
                          futureProfiles:
                              ApiService.fetchRecentlyViewedProfiles(
                                userId!,
                                10,
                                0,
                              ),
                        ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _InsightCard(
              icon: Icons.schedule,
              title: "Who Viewed Profile Recently",
              color: Colors.pink,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => ProfileListScreen(
                          title: "Who Viewed Profile Recently",
                          futureProfiles:
                              ApiService.fetchWhoViewedProfileRecently(
                                userId!,
                                10,
                                0,
                              ),
                        ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _InsightCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: onTap,
      ),
    );
  }
}
