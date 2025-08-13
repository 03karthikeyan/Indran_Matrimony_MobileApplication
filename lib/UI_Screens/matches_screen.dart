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

    print('Full API Result: $result');

    if (result['success'] && mounted) {
      final data = result['data'];

      if (data is Map) {
        // Extract matches list
        final matchesList = data['matches'] ?? [];

        // Extract total matches count
        totalMatches = data['total_matches'] ?? 0;

        setState(() {
          matches = List<Map<String, dynamic>>.from(matchesList);
          isLoading = false;
        });

        print('Total Matches: $totalMatches');
        print('Matches count: ${matches.length}');
      } else {
        setState(() {
          matches = [];
          totalMatches = 0;
          isLoading = false;
        });
      }
    } else if (mounted) {
      print('API failed: ${result['error']}');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pink = const Color(0xFFA51C48);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Column(
        children: [
          // AppBar substitute
          Container(
            padding: const EdgeInsets.only(
              top: 44,
              left: 20,
              right: 10,
              bottom: 0,
            ),
            decoration: BoxDecoration(
              color: pink,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(22),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tabs and more icon
                Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _TopTab(title: "All matches", selected: true),
                            _TopTab(title: "Newly joined"),
                            _TopTab(title: "Nearby matches"),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
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
                    : matches.isEmpty
                    ? Center(child: Text('No matches found'))
                    : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: matches.length,
                      itemBuilder: (context, index) {
                        final match = matches[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _MatchCard(
                            image: match['profile_img'] ?? 'assets/user1.jpg',
                            name: match['name'] ?? 'Unknown',
                            code: match['user_id']?.toString() ?? '',
                            age: '${match['age'] ?? 0} years',
                            height: match['height'] ?? '',
                            caste: match['caste'] ?? '',
                            location: match['city'] ?? '',
                            degree: match['higher_education'] ?? '',
                            job: match['occupation'] ?? '',
                            membership: true,
                            idVerified: true,
                            lastSeen: '2m ago',
                            matchPercent: 95,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (_) => MatchesDetailsScreen(match: match),
                                ),
                              );
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
  final String code;
  final String age;
  final String height;
  final String caste;
  final String location;
  final String degree;
  final String job;
  final bool idVerified;
  final bool membership;
  final String lastSeen;
  final int matchPercent;
  final VoidCallback onTap;

  const _MatchCard({
    required this.image,
    required this.name,
    required this.code,
    required this.age,
    required this.height,
    required this.caste,
    required this.location,
    required this.degree,
    required this.job,
    required this.idVerified,
    required this.membership,
    required this.lastSeen,
    required this.matchPercent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pink = const Color(0xFFA51C48);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 13),
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
        child: Padding(
          padding: const EdgeInsets.all(0),
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
                    image.startsWith('http')
                        ? Image.network(
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
                        )
                        : Container(
                          width: double.infinity,
                          height: 180,
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
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
                        child: Icon(
                          Icons.favorite_border,
                          color: pink,
                          size: 26,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Verified and Membership row
                    Row(
                      children: [
                        if (idVerified)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE7F7F0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.verified,
                                  color: Color(0xFF57BB7A),
                                  size: 15,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "ID Verified",
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: Color(0xFF57BB7A),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (membership)
                          Container(
                            margin: const EdgeInsets.only(left: 7),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF6FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.workspace_premium,
                                  color: Color(0xFF1D7AF5),
                                  size: 15,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "Membership",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF1D7AF5),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const Spacer(),
                        Text(
                          "Last seen $lastSeen",
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Name, code, match %
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEBF7F0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "$matchPercent% Match",
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF16C93B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      code,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 7),
                    // Age line
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            "$age • $height • $caste • $location",
                            style: const TextStyle(
                              fontSize: 14.5,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    // Degree / Job
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
                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 38),
                              padding: EdgeInsets.zero,
                              side: BorderSide(color: Colors.grey.shade400),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {},
                            child: const Text(
                              "Don't Show",
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(0, 38),
                              backgroundColor: pink,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {},
                            child: const Text(
                              "Send Interest",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
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
        ),
      ),
    );
  }
}
