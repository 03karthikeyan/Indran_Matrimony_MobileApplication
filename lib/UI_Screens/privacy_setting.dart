import 'package:flutter/material.dart';

class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pinkColor = const Color(0xFFA51C48);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Privacy Settings",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: pinkColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Privacy Settings",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "Manage how your profile and personal information are shared with other members. You can control who sees your profile, photos, and contact information.",
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 20),

            // Example Options
            Card(
              child: ListTile(
                title: const Text("Who can view my profile"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () {
                  // Can navigate to detailed settings if needed
                },
              ),
            ),
            Card(
              child: ListTile(
                title: const Text("Hide my contact information"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () {},
              ),
            ),
            Card(
              child: ListTile(
                title: const Text("Profile photo visibility"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
