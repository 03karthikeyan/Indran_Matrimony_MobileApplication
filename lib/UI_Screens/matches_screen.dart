import 'package:flutter/material.dart';
import 'package:matrimony/UI_Screens/filter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'matches_details_screen.dart';
import '../services/api_service.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({Key? key}) : super(key: key);

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  List<Map<String, dynamic>> matches = [];
  bool isLoading = true;
  int totalMatches = 0;
  int? userId;
  Map<String, dynamic> currentFilters = {};

  TextEditingController _searchController = TextEditingController();
  bool isSearching = false;
  List<Map<String, dynamic>> filteredMatches = [];

  String baseUrl = "https://pheonixconstructions.com/assets/profile_image/";

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userIdString =
        prefs.getString('user_id') ?? '1'; // get string from prefs

    userId = int.tryParse(userIdString) ?? 1;

    await _loadMatches();
  }

  Future<void> _loadMatches() async {
    setState(() => isLoading = true);

    final result =
        currentFilters.isEmpty
            ? await ApiService.getMatchingProfiles(userId!)
            : await ApiService.getFilteredMatches(
              userId!,
              fromAge: currentFilters['from_age'],
              toAge: currentFilters['to_age'],
              higherEducation: currentFilters['higher_education'],
              employeeIn: currentFilters['employee_in'],
              city: currentFilters['city'],
              fromIncome: currentFilters['from_income'],
              toIncome: currentFilters['to_income'],
            );

    if (result['success'] && mounted) {
      final data = result['data'];
      final matchesList = List<Map<String, dynamic>>.from(
        data['matches'] ?? [],
      );
      totalMatches = data['total_matches'] ?? 0;

      // Add match percentage for each user
      final updatedMatches = await Future.wait(
        matchesList.map<Future<Map<String, dynamic>>>((match) async {
          final matchPercent = await MatchStorage.getMatchPercentage(
            match['user_id'],
          );
          match['matchPercent'] = matchPercent;
          return match;
        }).toList(),
      ); // ✅ convert to List

      setState(() {
        matches = updatedMatches;
        isLoading = false;
      });
    } else if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Future<void> sendInterest(int receiverId) async {
    final prefs = await SharedPreferences.getInstance();
    final userIdString = prefs.getString('user_id') ?? '1';
    final senderId = int.tryParse(userIdString) ?? 1;

    final response = await ApiService.sendInterest(senderId, receiverId);

    if (!mounted) return;

    if (response['success'] == true) {
      // ✅ New interest sent
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? "Interest sent successfully!"),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        // update UI to pending state
        final match = matches.firstWhere(
          (m) => m['user_id'] == receiverId,
          orElse: () => {},
        );
        if (match.isNotEmpty) {
          match['interest_status'] = response['status'] ?? "pending";
        }
      });
    } else {
      // ✅ Already sent or failed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? "Failed to send interest"),
          backgroundColor: Colors.orange,
        ),
      );
      setState(() {
        final match = matches.firstWhere(
          (m) => m['user_id'] == receiverId,
          orElse: () => {},
        );
        if (match.isNotEmpty) {
          match['interest_status'] = response['status'] ?? "pending";
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pink = const Color(0xFFA51C48);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(
              top: 44,
              left: 18,
              right: 18,
              bottom: 16,
            ),
            decoration: BoxDecoration(
              color: pink,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                isSearching
                    ? Expanded(
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: "Search by name",
                          hintStyle: TextStyle(color: Colors.white70),
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          setState(() {
                            filteredMatches =
                                matches
                                    .where(
                                      (match) => (match['name'] ?? '')
                                          .toString()
                                          .toLowerCase()
                                          .contains(value.toLowerCase()),
                                    )
                                    .toList();
                          });
                        },
                      ),
                    )
                    : const Text(
                      'All Matches',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                const Spacer(),
                isSearching
                    ? IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          isSearching = false;
                          _searchController.clear();
                        });
                      },
                    )
                    : IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          isSearching = true;
                          filteredMatches = List.from(matches);
                        });
                      },
                    ),
              ],
            ),
          ),
          // Matches filter and filter button row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.verified, size: 19, color: Color(0xFF57BB7A)),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    "$totalMatches Matches your preferences",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.grey[900],
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  icon: const Icon(
                    Icons.filter_list,
                    color: Color(0xFFA51C48),
                    size: 20,
                  ),
                  label: const Text(
                    "Filters",
                    style: TextStyle(
                      color: Color(0xFFA51C48),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFA51C48)),
                    minimumSize: const Size(0, 34),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _openFilterScreen,
                ),
              ],
            ),
          ),
          // Matches List
          Expanded(
            child:
                isLoading
                    ? Center(child: CircularProgressIndicator(color: pink))
                    : (isSearching ? filteredMatches : matches).isEmpty
                    ? Center(child: Text('No matches found'))
                    : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount:
                          isSearching ? filteredMatches.length : matches.length,
                      itemBuilder: (context, index) {
                        final match =
                            isSearching
                                ? filteredMatches[index]
                                : matches[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _MatchCard(
                            image: baseUrl + match['profile_img'],
                            name: match['name'] ?? 'Unknown',
                            age: '${match['age'] ?? 0} years',
                            height: match['height'] ?? '',
                            caste: match['caste'] ?? '',
                            location: match['city'] ?? '',
                            degree: match['higher_education'] ?? '',
                            job: match['occupation'] ?? '',
                            membership: true,
                            idVerified: true,
                            matchPercent: match['matchPercent'] ?? 60,
                            interestStatus: match['interest_status'],
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (_) => MatchesDetailsScreen(match: match),
                                ),
                              );
                            },
                            onSendInterest: () async {
                              await sendInterest(match['user_id']);
                              setState(() {
                                match['interest_status'] = 'pending';
                              });
                            },
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Future<void> _openFilterScreen() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => FilterScreen(currentFilters: currentFilters),
      ),
    );

    if (result != null) {
      setState(() {
        currentFilters = result;
      });
      await _loadMatches();
    }
  }
}

class _TopTab extends StatelessWidget {
  final String title;
  final bool selected;
  const _TopTab({required this.title, this.selected = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 18),
      padding: EdgeInsets.only(bottom: 8),
      decoration:
          selected
              ? const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.white, width: 3),
                ),
              )
              : null,
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withOpacity(selected ? 1 : 0.7),
          fontWeight: selected ? FontWeight.bold : FontWeight.w500,
          fontSize: 16,
        ),
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final String image;
  final String name;
  final String age;
  final String height;
  final String caste;
  final String location;
  final String degree;
  final String job;
  final bool idVerified;
  final bool membership;
  final int matchPercent;
  final String? interestStatus; // 'pending', 'accepted', 'declined' or null
  final VoidCallback onTap;
  final VoidCallback? onSendInterest;

  const _MatchCard({
    required this.image,
    required this.name,
    required this.age,
    required this.height,
    required this.caste,
    required this.location,
    required this.degree,
    required this.job,
    required this.idVerified,
    required this.membership,
    required this.matchPercent,
    this.interestStatus,
    required this.onTap,
    this.onSendInterest,
  });

  @override
  Widget build(BuildContext context) {
    final pink = const Color(0xFFA51C48);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  Image.network(
                    image,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          width: double.infinity,
                          height: 180,
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 13, right: 13),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      // child: Icon(Icons.favorite_border, color: pink, size: 26),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Verified and Membership row
                  Row(
                    children: [
                      if (idVerified)
                        _StatusTag(
                          label: "ID Verified",
                          icon: Icons.verified,
                          color: Color(0xFF57BB7A),
                        ),
                      if (membership)
                        _StatusTag(
                          label: "Membership",
                          icon: Icons.workspace_premium,
                          color: Color(0xFF1D7AF5),
                        ),
                      Spacer(),
                      Text(
                        "$matchPercent% Match",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF16C93B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    "$age • $location • $caste ",
                    style: const TextStyle(
                      fontSize: 14.5,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Icon(Icons.school, size: 15, color: pink),
                      const SizedBox(width: 4),
                      Text(
                        degree,
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 13),
                      Icon(Icons.work, size: 15, color: pink),
                      const SizedBox(width: 4),
                      Text(
                        job,
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 13),
                  // Only Send Interest button or status
                  _buildInterestButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestButton(BuildContext context) {
    final pink = const Color(0xFFA51C48);

    if (interestStatus == null) {
      // ✅ Not sent yet → show button
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: pink,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: onSendInterest,
          child: const Text(
            "Send Interest",
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
        ),
      );
    } else {
      // ✅ Already sent → show info box instead of Pending button
      Color statusColor;
      String text;

      if (interestStatus == "accepted") {
        statusColor = Colors.green;
        text = "INTEREST ACCEPTED";
      } else if (interestStatus == "declined") {
        statusColor = Colors.red;
        text = "INTEREST DECLINED";
      } else {
        statusColor = Colors.orange;
        text = "INTEREST ALREADY SENT"; // 👈 instead of PENDING
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      );
    }
  }
}

class _StatusTag extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _StatusTag({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 7),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class MatchStorage {
  static Future<int> getMatchPercentage(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'match_$userId';
    if (prefs.containsKey(key)) return prefs.getInt(key)!;

    int percentage = _calculateMatchPercentage(userId);
    await prefs.setInt(key, percentage);
    return percentage;
  }

  static int _calculateMatchPercentage(int userId) {
    final seed = userId;
    final random = (seed * 9301 + 49297) % 233280;
    final normalized = random / 233280;
    return (60 + (normalized * 35)).floor(); // 60-95%
  }
}
