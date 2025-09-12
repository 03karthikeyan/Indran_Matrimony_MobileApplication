import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:matrimony/UI_Screens/EditProfileScreen.dart';
import 'package:matrimony/UI_Screens/Message_Screen.dart';
import 'package:matrimony/UI_Screens/ProfileListScreen.dart';
import 'package:matrimony/UI_Screens/interests_received_screen.dart';
import 'package:matrimony/UI_Screens/matches_details_screen.dart';
import 'package:matrimony/UI_Screens/matches_screen.dart';
import 'package:matrimony/UI_Screens/profile_screen.dart';
import 'package:matrimony/UI_Screens/subscription_screen.dart';
import 'package:matrimony/models/ProfileView.dart';
import 'package:matrimony/models/interest_Profile_Model.dart';
import 'package:matrimony/models/profile_model.dart';
import 'package:matrimony/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  final int userId; // Pass userId from login/register
  const HomeScreen({super.key, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  int profileViewsCount = 0;
  int matchesCount = 0;
  int pendingCount = 0;
  List<ProfileView> recentlyViewed = [];
  int totalCount = 0;

  // 🔹 Subscription
  bool isSubscribed = false;
  Map<String, dynamic>? subscriptionDetails;

  late Future<List<Profile>> _profilesFuture;
  late Future<List<InterestedProfile>> _interestsFuture;

  @override
  void initState() {
    super.initState();
    fetchProfile();
    _profilesFuture = fetchProfiles(); // ✅ cache once
    _interestsFuture = fetchInterestedProfiles(); // ✅ cache once
    _fetchStats();
    fetchSubscriptionStatus();
    _fetchRecentlyViewed();
  }

  //Recent view
  Future<void> _fetchRecentlyViewed() async {
    try {
      final profiles = await ApiService.fetchRecentlyViewedProfiles(
        widget.userId.toString(), // 🔹 convert int → String
        10, // limit
        0, // offset
      );

      setState(() {
        recentlyViewed = profiles;
        totalCount =
            profiles.length; // you can replace with API pagination if available
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching recently viewed: $e");
      setState(() => isLoading = false);
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

  //Fetch Stats Count
  Future<void> _fetchStats() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString("user_id") ?? "0"; // default 0 if null
      // 👇 Profile views
      final profileViews = await ApiService.fetchWhoViewedMyProfile(
        userId, // dynamic user_id
        10,
        0,
        userId,
      );
      setState(() {
        profileViewsCount = profileViews.length;
      });

      // 👇 Matches
      final matchesRes = await ApiService.getMatchingProfiles(
        int.parse(userId),
      );
      if (matchesRes['success']) {
        setState(() {
          matchesCount = matchesRes['data']['total_matches'] ?? 0;
        });
      }

      // 👇 Pending interests
      final pendingProfiles = await fetchInterestedProfiles();
      setState(() {
        pendingCount =
            pendingProfiles.length; // or use total_interests from API
      });
    } catch (e) {
      debugPrint("Error fetching stats: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  //Daily recomend profile list API

  Future<List<Profile>> fetchProfiles() async {
    final response = await http.get(
      Uri.parse(
        "https://pheonixconstructions.com/Matrimony API/fetch_recent_profile.php?user_id=${widget.userId}",
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        final List profiles = data['profiles'];
        return profiles.map((e) => Profile.fromJson(e)).toList();
      } else {
        return [];
      }
    } else {
      throw Exception("Failed to load profiles");
    }
  }

  //intrest Profile LIST showing API

  Future<List<InterestedProfile>> fetchInterestedProfiles() async {
    final response = await http.get(
      Uri.parse(
        "https://pheonixconstructions.com/Matrimony API/fetch_interested_profiles.php?user_id=${widget.userId}",
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        final List profiles = data['interested_profiles'];
        return profiles
            .map(
              (e) => InterestedProfile.fromJson(
                e,
                loggedInUserId: widget.userId.toString(),
              ),
            )
            .toList();
      } else {
        return [];
      }
    } else {
      throw Exception("Failed to load interested profiles");
    }
  }

  //Time AGo Interest Profile
  String _getTimeAgo(String createdAt) {
    try {
      final createdDate = DateTime.parse(createdAt);
      final diff = DateTime.now().difference(createdDate);

      if (diff.inMinutes < 60) {
        return "${diff.inMinutes}m ago";
      } else if (diff.inHours < 24) {
        return "${diff.inHours}h ago";
      } else {
        return "${diff.inDays}d ago";
      }
    } catch (e) {
      return "";
    }
  }

  //Profile Data showing API

  Future<void> fetchProfile() async {
    final result = await ApiService.getProfiles(widget.userId);

    if (result['success']) {
      setState(() {
        userData = result['user_data'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print(result['error']); // Handle error gracefully
    }
  }

  @override
  Widget build(BuildContext context) {
    final pinkColor = const Color(0xFFA51C48);
    final profileCompletion = 0.8;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.only(
                top: 44,
                left: 18,
                right: 18,
                bottom: 16,
              ),
              decoration: BoxDecoration(
                color: pinkColor,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Profile Image
                      InkWell(
                        borderRadius: BorderRadius.circular(
                          30,
                        ), // optional, matches avatar shape
                        onTap: () {
                          if (userData != null &&
                              userData!['user_id'] != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ProfileScreen(
                                      userId: int.parse(
                                        userData!['user_id'].toString(),
                                      ),
                                    ),
                              ),
                            );
                          }
                        },
                        child: CircleAvatar(
                          radius: 26,
                          backgroundImage:
                              isLoading
                                  ? const AssetImage('assets/user.png')
                                  : (userData != null &&
                                      userData!['profile_img'] != null &&
                                      userData!['profile_img']
                                          .toString()
                                          .isNotEmpty)
                                  ? NetworkImage(userData!['profile_img'])
                                  : const AssetImage('assets/user.png')
                                      as ImageProvider,
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Name + Membership
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (userData?['name'] ?? "Guest User"),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                isSubscribed ? Icons.verified : Icons.lock_open,
                                size: 16,
                                color:
                                    isSubscribed
                                        ? Colors.green
                                        : Colors.white70,
                              ),

                              const SizedBox(width: 4),
                              Text(
                                isSubscribed ? 'Premium Member' : 'Free Member',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                              if (!isSubscribed) ...[
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => const SubscriptionScreen(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
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
                            ],
                          ),
                        ],
                      ),

                      const Spacer(),
                      // Search
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.white24,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Stats Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child:
                  isLoading
                      ? _buildShimmerLoader()
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _StatCard(
                            icon: Icons.remove_red_eye,
                            value: profileViewsCount.toString(),
                            label: "Profile Views",
                            color: pinkColor.withOpacity(0.09),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => ProfileListScreen(
                                        title: "Who Viewed My Profile",
                                        futureProfiles:
                                            ApiService.fetchWhoViewedMyProfile(
                                              widget.userId
                                                  .toString(), // ✅ use dynamic userId
                                              10,
                                              0,
                                              widget.userId.toString(),
                                            ),
                                      ),
                                ),
                              );
                            },
                          ),
                          _StatCard(
                            icon: Icons.favorite,
                            value: matchesCount.toString(),
                            label: "Matches",
                            color: Colors.blue.withOpacity(0.08),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const MatchesScreen(),
                                ),
                              );
                            },
                          ),
                          _StatCard(
                            icon: Icons.pending_actions,
                            value: pendingCount.toString(),
                            label: "Pending",
                            color: Colors.orange.withOpacity(0.08),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => const InterestsReceivedScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
            ),

            // Daily Recommendation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Daily Recommendation",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => MatchesScreen()),
                      );
                    },
                    child: Text(
                      "See all",
                      style: TextStyle(
                        color: pinkColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 120,
              child: FutureBuilder<List<Profile>>(
                future: _profilesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // ✅ Show shimmer loader instead of CircularProgressIndicator
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 6, // number of shimmer cards
                      itemBuilder:
                          (context, index) => const RecommendationShimmerCard(),
                    );
                  } else if (snapshot.hasError) {
                    return const Center(child: Text("Error loading profiles"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Decorative icon
                            Container(
                              decoration: BoxDecoration(
                                color: pinkColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(24),
                              child: Icon(
                                Icons.person_off,
                                color: pinkColor,
                                size: 48,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Title
                            const Text(
                              "No Recommendations Yet",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Subtitle
                            const Text(
                              "Complete your profile or update preferences to see personalized matches.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Call-to-action button
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: pinkColor,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                // Navigate to profile edit or preferences page
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => EditProfileScreen(
                                          userId: widget.userId,
                                          profileData: userData!,
                                        ),
                                  ),
                                );
                              },
                              child: const Text(
                                "Update Profile",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    final profiles = snapshot.data!.take(10).toList();
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: profiles.length,
                      itemBuilder: (context, index) {
                        final profile = profiles[index];
                        return _RecommendationCard(
                          name: profile.name,
                          age: profile.age,
                          imageUrl:
                              "https://pheonixconstructions.com/assets/profile_image/${profile.profileImg}",
                          match: profile.toJson(), // pass map here
                        );
                      },
                    );
                  }
                },
              ),
            ),

            // Explore Premium
            Padding(
              padding: const EdgeInsets.all(18),
              child: InkWell(
                borderRadius: BorderRadius.circular(
                  12,
                ), // ripple matches container radius
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SubscriptionScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF3D8E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Explore Premium",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              "Get 3x more responses & matches",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Container(
                        padding: const EdgeInsets.all(13),
                        decoration: const BoxDecoration(
                          color: Colors.white24,
                          shape: BoxShape.circle,
                        ),
                        child: const FaIcon(
                          FontAwesomeIcons.crown,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // New Matches
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Recently Viewed ($totalCount)",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigate to full list screen
                    },
                    child: Text(
                      "See all",
                      style: TextStyle(
                        color: pinkColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // List
            SizedBox(
              height: 170,
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : recentlyViewed.isEmpty
                      ? SingleChildScrollView(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: pinkColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(24),
                                  child: Icon(
                                    Icons.remove_red_eye_outlined,
                                    color: pinkColor,
                                    size: 40,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  "No Recently Viewed Profiles",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  "Start browsing profiles to see your recently viewed members here.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: pinkColor,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => MatchesScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "Browse Profiles",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: recentlyViewed.length,
                        itemBuilder: (context, index) {
                          final profile = recentlyViewed[index];
                          return _MatchCard(
                            name: profile.name,
                            job: profile.occupation ?? "",
                            location: profile.city ?? "",
                            imageUrl: profile.image,
                            view: profile.totalViews ?? 0,
                            ProfileView: profile.toJson(),
                          );
                        },
                      ),
            ),

            // Recent Interest
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Recent Interests",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  Text(
                    "See all",
                    style: TextStyle(
                      color: pinkColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            FutureBuilder<List<InterestedProfile>>(
              future: _interestsFuture, // ✅ use cached future
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(); // no flicker
                } else if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(18),
                    child: Text("Failed to load interests"),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(18),
                    child: Text("No recent interests found"),
                  );
                } else {
                  final profiles = snapshot.data!;
                  return Column(
                    children:
                        profiles.map((profile) {
                          return _InterestCard(
                            profileId: profile.profileId, // ✅ sender user id
                            userId:
                                widget.userId.toString(), // ✅ logged-in user id
                            interestId: profile.interestId, // ✅ interest row id
                            status: profile.status,
                            name: profile.name,
                            age: profile.age,
                            time: _getTimeAgo(profile.time),
                            city: profile.city,
                            tags: profile.tags,
                            profileImg: profile.profileImg,
                          );
                        }).toList(),
                  );
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, // 👈 added
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 98,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFA51C48), size: 28),
            const SizedBox(height: 7),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

//stats shimmer loader

Widget _buildShimmerLoader() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: List.generate(
      3,
      (index) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          width: 98,
          height: 90,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    ),
  );
}

class _RecommendationCard extends StatelessWidget {
  final String name;
  final int age;
  final String imageUrl;
  final Map<String, dynamic> match; // pass entire profile

  const _RecommendationCard({
    Key? key,
    required this.name,
    required this.age,
    required this.imageUrl,
    required this.match, // new
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigate to MatchesDetailsScreen with selected profile
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MatchesDetailsScreen(match: match),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.network(
                imageUrl,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) =>
                        const Icon(Icons.person, size: 70),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              "$age yrs",
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

//Recomentational shimmer card

class RecommendationShimmerCard extends StatelessWidget {
  const RecommendationShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 12,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 10,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final String name;
  final int view;
  final String job;
  final String location;
  final String? imageUrl;
  final Map<String, dynamic> ProfileView;

  const _MatchCard({
    required this.name,
    required this.view,
    required this.job,
    required this.location,
    this.imageUrl,
    required this.ProfileView,
  });

  @override
  Widget build(BuildContext context) {
    final pinkColor = const Color(0xFFA51C48);

    return InkWell(
      borderRadius: BorderRadius.circular(8), // ripple matches card shape
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MatchesDetailsScreen(match: ProfileView),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 10, bottom: 1),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image Section
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child:
                  imageUrl != null && imageUrl!.isNotEmpty
                      ? Image.network(
                        "https://pheonixconstructions.com/assets/profile_image/$imageUrl",
                        height: 100,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 100,
                            width: double.infinity,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 40,
                            ),
                          );
                        },
                      )
                      : Container(
                        height: 100,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
            ),

            // Profile Info Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 1),
                    Row(
                      children: [
                        // Job
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.work,
                                size: 14,
                                color: Colors.brown,
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  job,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Location
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.redAccent,
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 1),
                    Center(
                      child: Text(
                        'Viewed $view times',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InterestCard extends StatefulWidget {
  final String profileId; // other person (sender)
  final String userId; // logged-in user (receiver)
  final int interestId; // interest row id
  final String status;
  final String name;
  final int age;
  final String profileImg;
  final String time;
  final String city;
  final List<String> tags;

  const _InterestCard({
    required this.profileId,
    required this.userId,
    required this.interestId,
    required this.status,
    required this.name,
    required this.age,
    required this.time,
    required this.city,
    required this.tags,
    required this.profileImg,
    Key? key,
  }) : super(key: key);

  @override
  State<_InterestCard> createState() => _InterestCardState();
}

class _InterestCardState extends State<_InterestCard> {
  late String _status;
  bool _accepting = false;
  bool _declining = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _status = widget.status.toLowerCase(); // set from API
  }

  Future<void> _acceptProfile() async {
    setState(() => _accepting = true);

    final result = await ApiService.respondInterest(
      widget.interestId,
      int.tryParse(widget.userId) ?? 0, // ✅ logged-in user id
      "accept",
    );

    print(
      "➡️ Sending: interestId=${widget.interestId}, "
      "receiverId=${widget.userId}, action=accept",
    );
    print("⬅️ Response: $result");

    setState(() => _accepting = false);

    if (result["success"] == true) {
      setState(() => _status = "accepted");
    } else {
      _showError(result["message"]);
    }
  }

  Future<void> _declineProfile() async {
    setState(() => _declining = true);

    final result = await ApiService.respondInterest(
      widget.interestId,
      int.tryParse(widget.userId) ?? 0, // ✅ logged-in user id
      "decline",
    );

    print(
      "➡️ Sending: interestId=${widget.interestId}, "
      "receiverId=${widget.userId}, action=decline",
    );
    print("⬅️ Response: $result");

    setState(() => _declining = false);

    if (result["success"] == true) {
      setState(() => _status = "declined");
    } else {
      _showError(result["message"]);
    }
  }

  void _showError(String? msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg ?? "Something went wrong")));
  }

  @override
  Widget build(BuildContext context) {
    final pinkColor = const Color(0xFFA51C48);

    // 👇 Hide declined profiles
    if (_status == "declined") return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage:
                widget.profileImg.isNotEmpty
                    ? NetworkImage(
                      "https://pheonixconstructions.com/assets/profile_image/${widget.profileImg}",
                    )
                    : const AssetImage("assets/user.png") as ImageProvider,
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // name + age + time
                Row(
                  children: [
                    Text(
                      "${widget.name}, ${widget.age}",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Text(
                      widget.time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                Text(
                  widget.city,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 6),

                // tags
                Row(
                  children:
                      widget.tags
                          .map(
                            (t) => Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: pinkColor.withOpacity(0.15),
                                ),
                              ),
                              child: Text(
                                t,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          )
                          .toList(),
                ),
                const SizedBox(height: 6),

                // 🔹 Action buttons
                if (_loading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(
                        color: Color(0xFFA51C48),
                      ),
                    ),
                  )
                else if (_status == "pending") ...[
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: _declining ? null : _declineProfile,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 6,
                          ),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child:
                            _declining
                                ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text(
                                  "Decline",
                                  style: TextStyle(color: Colors.black54),
                                ),
                      ),

                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _accepting ? null : _acceptProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: pinkColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          elevation: 0,
                        ),
                        child:
                            _accepting
                                ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : const Text(
                                  "Accept",
                                  style: TextStyle(color: Colors.white),
                                ),
                      ),
                    ],
                  ),
                ] else if (_status == "accepted") ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      // ...inside _InterestCardState, before Navigator.push...
                      print(
                        "Navigating to MessageScreen with senderId=${widget.userId}, receiverId=${widget.profileId}, name=${widget.name}",
                      );
                      // ...inside _InterestCardState, before Navigator.push...
                      if (widget.profileId.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Cannot chat: Profile ID missing"),
                          ),
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => MessageScreen(
                                senderId: widget.userId,
                                receiverId: widget.profileId,
                                receiverName: widget.name,
                              ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pinkColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.chat, color: Colors.white, size: 16),
                    label: const Text(
                      "Chat",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
