import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:matrimony/UI_Screens/ProfileListScreen.dart';
import 'package:matrimony/UI_Screens/interests_received_screen.dart';
import 'package:matrimony/UI_Screens/matches_screen.dart';
import 'package:matrimony/UI_Screens/subscription_screen.dart';
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
        return profiles.map((e) => InterestedProfile.fromJson(e)).toList();
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
                bottom: 12,
              ),
              decoration: BoxDecoration(
                color: pinkColor,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Info Row
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
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
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (userData?['name'] ?? "Unknown User"),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 17,
                            ),
                          ),
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
                                        builder:
                                            (_) => const SubscriptionScreen(),
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
                      const Spacer(),
                      const Icon(
                        Icons.notifications_none,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.search, color: Colors.white, size: 28),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFBF406D),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          "Profile Completion",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          "80%",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    height: 7,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Stack(
                      children: [
                        FractionallySizedBox(
                          widthFactor: profileCompletion,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFC954),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
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
                    return const Center(child: Text("No profiles found"));
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
                  const Text(
                    "New Matches (234)",
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
            Container(
              height: 170,
              margin: const EdgeInsets.only(left: 18),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _MatchCard(
                    name: "Priya",
                    age: 24,
                    job: "Software Engineer",
                    location: "Chennai",
                  ),
                  _MatchCard(
                    name: "Seetha",
                    age: 29,
                    job: "Doctor",
                    location: "Coimbatore",
                  ),
                  _MatchCard(
                    name: "Ramya Varanasi",
                    age: 28,
                    job: "Business Analyst",
                    location: "Madurai",
                  ),
                ],
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
                            name: profile.name,
                            age: profile.age,
                            time: _getTimeAgo(profile.createdAt),
                            city: "${profile.city}, ${profile.state}",
                            tags: [profile.higherEducation, profile.occupation],
                            profileImg:
                                profile
                                    .profileImg, // 👉 only file name like "profile.jpg"
                          );
                        }).toList(),
                  );
                }
              },
            ),

            // Success Stories
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: const Text(
                "Success Stories",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE4EC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: AssetImage('assets/user.png'),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Arun & Meena",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Matched in June 2023",
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "\"We found each other on Indran Matrimony and instantly connected. After 6 months of getting to know each other, we're now happily married!\"",
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Read their story >",
                    style: TextStyle(
                      color: pinkColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
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

  const _RecommendationCard({
    Key? key,
    required this.name,
    required this.age,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  (context, error, stackTrace) => Icon(Icons.person, size: 70),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          Text("$age yrs", style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
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
  final int age;
  final String job;
  final String location;
  const _MatchCard({
    required this.name,
    required this.age,
    required this.job,
    required this.location,
  });
  @override
  Widget build(BuildContext context) {
    final pinkColor = const Color(0xFFA51C48);
    return Container(
      width: 145,
      margin: const EdgeInsets.only(right: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 7)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 78,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(11),
              ),
              color: Colors.grey[300],
            ),
            child: const Center(
              child: Icon(Icons.person, color: Colors.white, size: 36),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  '$age yrs',
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                Text(
                  job,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                Text(
                  location,
                  style: const TextStyle(fontSize: 13, color: Colors.black45),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pinkColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Connect Now',
                      style: TextStyle(fontSize: 13, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InterestCard extends StatelessWidget {
  final String name;
  final int age;
  final String profileImg;
  final String time;
  final String city;
  final List<String> tags;

  const _InterestCard({
    required this.name,
    required this.age,
    required this.time,
    required this.city,
    required this.tags,
    required this.profileImg,
  });

  @override
  Widget build(BuildContext context) {
    final pinkColor = const Color(0xFFA51C48);

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        // 👇 Navigate to InterestsReceivedScreen when card is tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const InterestsReceivedScreen(),
          ),
        );
      },
      child: Container(
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
                  profileImg.isNotEmpty
                      ? NetworkImage(
                        "https://pheonixconstructions.com/assets/profile_image/$profileImg",
                      )
                      : const AssetImage("assets/user.png") as ImageProvider,
              onBackgroundImageError: (_, __) {},
            ),
            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "$name, $age",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.verified, color: Colors.green, size: 14),
                      const Spacer(),
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    city,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 4),

                  // tags
                  Row(
                    children:
                        tags
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

                  // action buttons
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          // 👇 keep decline separate
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Declined")),
                          );
                        },
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
                        child: const Text(
                          "Decline",
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          // 👇 keep accept separate
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Accepted")),
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
                        child: const Text(
                          "Accept",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
