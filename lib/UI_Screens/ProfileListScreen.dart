import 'package:flutter/material.dart';
import 'package:matrimony/UI_Screens/matches_details_screen.dart';
import 'package:matrimony/models/ProfileView.dart';
import 'package:shimmer/shimmer.dart';

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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // Set your desired color here
        ),
        title: Text(title, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.pink.shade700,
      ),
      body: FutureBuilder<List<ProfileView>>(
        future: futureProfiles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // ✅ Show shimmer placeholder (no profiles used here)
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: 6, // fixed placeholder count
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: const CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    title: Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        height: 14,
                        width: 100,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Container(
                            height: 12,
                            width: 150,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Container(
                            height: 12,
                            width: 120,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No profiles found"));
          }

          // ✅ Only here we use profiles
          final profiles = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: profiles.length,
            itemBuilder: (context, index) {
              final profile = profiles[index];

              final bool isWhoViewed = title == "Who Viewed My Profile";

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    radius: 32,
                    backgroundImage:
                        (profile.image != null &&
                                profile.image!.isNotEmpty &&
                                profile.image != 'default.jpg')
                            ? NetworkImage(
                              "https://pheonixconstructions.com/assets/profile_image/${profile.image}",
                            ) // Replace with your actual image base URL
                            : const AssetImage("assets/Ellipse 222.png")
                                as ImageProvider,
                  ),

                  // ✅ Dynamic title/subtitle
                  title: Text(
                    isWhoViewed
                        ? (profile.username ?? "User-${profile.username}")
                        : profile.name ?? "Unknown",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      isWhoViewed
                          ? "${profile.gender ?? ''} • Views: ${profile.totalViews}\nLast Viewed: ${profile.lastViewedAt ?? '-'}"
                          : "${profile.gender ?? ''} • ${profile.occupation ?? ''}\n${profile.city ?? ''}, ${profile.state ?? ''}",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ),

                  // trailing: ElevatedButton(
                  //   onPressed: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder:
                  //             (_) => MatchesDetailsScreen(
                  //               match: {
                  //                 "profile_id": profile.profileId,
                  //                 "user_id": profile.userId,
                  //                 "gender": profile.gender,
                  //                 "image": profile.image,
                  //                 "last_viewed_at": profile.lastViewedAt,
                  //                 "total_views": profile.totalViews,
                  //               },
                  //             ),
                  //       ),
                  //     );
                  //   },
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: Colors.pink.shade600,
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(8),
                  //     ),
                  //   ),
                  //   child: const Text(
                  //     "View",
                  //     style: TextStyle(fontSize: 13, color: Colors.white),
                  //   ),
                  // ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
