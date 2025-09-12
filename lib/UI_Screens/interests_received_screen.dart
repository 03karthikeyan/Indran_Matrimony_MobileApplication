import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'matches_details_screen.dart'; // ✅ Import your details screen

class InterestsReceivedScreen extends StatefulWidget {
  const InterestsReceivedScreen({Key? key}) : super(key: key);

  @override
  State<InterestsReceivedScreen> createState() =>
      _InterestsReceivedScreenState();
}

class _InterestsReceivedScreenState extends State<InterestsReceivedScreen> {
  List<Map<String, dynamic>> interests = [];
  bool isLoading = true;
  int? userId;
  Set<int> loadingIds = {};
  Map<int, bool> acceptingIds = {};
  Map<int, bool> decliningIds = {};

  final pink = const Color(0xFFA51C48);

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = int.tryParse(prefs.getString("user_id") ?? "1") ?? 1;
    await _loadReceivedInterests();
  }

  Future<void> _loadReceivedInterests() async {
    setState(() => isLoading = true);

    final url = Uri.parse(
      "https://pheonixconstructions.com/Matrimony API/fetch_interested_profiles.php?user_id=$userId",
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success') {
          setState(() {
            interests = List<Map<String, dynamic>>.from(
              data['interested_profiles'],
            );
            isLoading = false;
          });
        } else {
          setState(() {
            interests = [];
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        interests = [];
        isLoading = false;
      });
    }
  }

  void _handleAction(int index, String action) async {
    final interest = interests[index];
    final interestId = interest['interest_id'];

    // Mark only the correct button as loading
    setState(() {
      if (action == "accept") {
        acceptingIds[interestId] = true;
      } else {
        decliningIds[interestId] = true;
      }
    });

    final result = await ApiService.respondInterest(
      interestId,
      userId!,
      action,
    );

    if (!mounted) return;

    setState(() {
      acceptingIds[interestId] = false;
      decliningIds[interestId] = false;

      if (result['status'] == 'success') {
        // 🔹 Update status immediately
        interests[index]['status'] =
            action == "accept" ? "accepted" : "declined";
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'] ?? "$action success")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: pink,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Interests Received",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body:
          isLoading
              ? _buildShimmerLoader() // ✅ shimmer loader
              : interests.isEmpty
              ? const Center(child: Text("No interests received"))
              : ListView.builder(
                padding: const EdgeInsets.all(14),
                itemCount: interests.length,
                itemBuilder: (context, index) {
                  final interest = interests[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MatchesDetailsScreen(match: interest),
                        ),
                      );
                    },
                    child: _InterestCard(
                      interest: interest,
                      isAccepting:
                          acceptingIds[interest['interest_id']] ?? false,
                      isDeclining:
                          decliningIds[interest['interest_id']] ?? false,
                      onAccept: () => _handleAction(index, "accept"),
                      onDecline: () => _handleAction(index, "decline"),
                    ),
                  );
                },
              ),
    );
  }

  // ✅ Shimmer loader for interests list
  Widget _buildShimmerLoader() {
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: 5,
      itemBuilder:
          (_, __) => Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Container(
                    height: 160,
                    width: double.infinity,
                    color: Colors.grey[300],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 16,
                          width: 120,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 14,
                          width: 180,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 14,
                          width: 100,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 40,
                                color: Colors.grey[300],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                height: 40,
                                color: Colors.grey[300],
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
          ),
    );
  }
}

class _InterestCard extends StatelessWidget {
  final Map<String, dynamic> interest;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final bool isAccepting;
  final bool isDeclining;

  const _InterestCard({
    required this.interest,
    required this.onAccept,
    required this.onDecline,
    required this.isAccepting,
    required this.isDeclining,
  });

  @override
  Widget build(BuildContext context) {
    final pink = const Color(0xFFA51C48);
    final status = interest['status'] ?? "pending"; // 🔹 check status

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          // Profile Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(14),
              topRight: Radius.circular(14),
            ),
            child: Image.network(
              "https://pheonixconstructions.com/assets/profile_image/${interest['profile_img'] ?? ""}",
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) => Container(
                    height: 160,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${interest['name']} (${interest['age']} yrs)",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "${interest['higher_education']} • ${interest['occupation']}",
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                Text(
                  interest['city'] ?? "",
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 12),

                // 🔹 Status-based UI
                if (status == "pending") ...[
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isAccepting ? null : onAccept,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            minimumSize: const Size(0, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child:
                              isAccepting
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
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
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isDeclining ? null : onDecline,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            minimumSize: const Size(0, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child:
                              isDeclining
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : const Text(
                                    "Decline",
                                    style: TextStyle(color: Colors.white),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color:
                          status == "accepted"
                              ? Colors.green.withOpacity(0.15)
                              : Colors.red.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              status == "accepted" ? Colors.green : Colors.red,
                        ),
                      ),
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
