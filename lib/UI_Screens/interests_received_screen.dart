import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

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
    // 🔹 Replace with API call like: ApiService.getReceivedInterests(userId!)
    // For demo, using static data
    setState(() {
      interests = [
        {
          "interest_id": 1,
          "sender_id": 6,
          "sender_name": "Priya",
          "age": 25,
          "city": "Chennai",
          "degree": "MBA",
          "job": "Software Engineer",
          "profile_img":
              "https://pheonixconstructions.com/assets/profile_image/profile.jpg",
        },
        {
          "interest_id": 2,
          "sender_id": 7,
          "sender_name": "Anitha",
          "age": 27,
          "city": "Bangalore",
          "degree": "B.Tech",
          "job": "Designer",
          "profile_img":
              "https://pheonixconstructions.com/assets/profile_image/profile.jpg",
        },
      ];
      isLoading = false;
    });
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
              ? Center(child: CircularProgressIndicator(color: pink))
              : interests.isEmpty
              ? const Center(child: Text("No interests received"))
              : ListView.builder(
                padding: const EdgeInsets.all(14),
                itemCount: interests.length,
                itemBuilder: (context, index) {
                  final interest = interests[index];
                  return _InterestCard(
                    interest: interest,
                    receiverId: userId!,
                    onActionCompleted: _loadReceivedInterests,
                  );
                },
              ),
    );
  }
}

class _InterestCard extends StatelessWidget {
  final Map<String, dynamic> interest;
  final int receiverId;
  final VoidCallback onActionCompleted;

  const _InterestCard({
    required this.interest,
    required this.receiverId,
    required this.onActionCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final pink = const Color(0xFFA51C48);

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
              interest['profile_img'] ?? "",
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stack) => Container(
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
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + Age + City
                Text(
                  "${interest['sender_name']} (${interest['age']} yrs)",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "${interest['degree']} • ${interest['job']}",
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                Text(
                  interest['city'] ?? "",
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 12),

                // Accept / Decline Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final result = await ApiService.respondInterest(
                            interest['interest_id'],
                            receiverId,
                            "accept",
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(result['message'] ?? "Accepted"),
                            ),
                          );
                          onActionCompleted();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: const Size(0, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Accept",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final result = await ApiService.respondInterest(
                            interest['interest_id'],
                            receiverId,
                            "decline",
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(result['message'] ?? "Declined"),
                            ),
                          );
                          onActionCompleted();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          minimumSize: const Size(0, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Decline",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
