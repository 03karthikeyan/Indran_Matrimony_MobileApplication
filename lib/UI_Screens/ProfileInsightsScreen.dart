import 'package:flutter/material.dart';
import 'package:matrimony/UI_Screens/ProfileListScreen.dart';
import '../services/api_service.dart';

class ProfileInsightsScreen extends StatelessWidget {
  const ProfileInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile Insights")),
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
                            "12",
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
                                "6",
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
                                "1",
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
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: onTap,
      ),
    );
  }
}
