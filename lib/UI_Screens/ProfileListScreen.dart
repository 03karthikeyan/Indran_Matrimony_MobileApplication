import 'package:flutter/material.dart';
import 'package:matrimony/models/ProfileView.dart';

class ProfileListScreen extends StatelessWidget {
  final String title;
  final Future<List<ProfileView>> futureProfiles;

  const ProfileListScreen({
    super.key,
    required this.title,
    required this.futureProfiles,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: FutureBuilder<List<ProfileView>>(
        future: futureProfiles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No profiles found"));
          }

          final profiles = snapshot.data!;
          return ListView.builder(
            itemCount: profiles.length,
            itemBuilder: (context, index) {
              final profile = profiles[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(profile.image ?? ""),
                  ),
                  title: Text(
                    profile.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    "${profile.gender ?? ''} • ${profile.occupation ?? ''}\n${profile.city ?? ''}, ${profile.state ?? ''}",
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                  onTap: () {
                    // TODO: Navigate to profile details
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
