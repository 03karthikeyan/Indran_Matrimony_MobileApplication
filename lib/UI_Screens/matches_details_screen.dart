import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:matrimony/UI_Screens/Message_Screen.dart';
import 'package:matrimony/UI_Screens/chat_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'subscription_screen.dart';

class MatchesDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> match;

  const MatchesDetailsScreen({Key? key, required this.match}) : super(key: key);

  @override
  State<MatchesDetailsScreen> createState() => _MatchesDetailsScreenState();
}

class _MatchesDetailsScreenState extends State<MatchesDetailsScreen> {
  bool isPremiumUser = false; // Default to false

  @override
  void initState() {
    super.initState();
    _loadUserPremiumStatus();
  }

  // Example: Load from SharedPreferences or API
  Future<void> _loadUserPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isPremiumUser = prefs.getBool('isPremium') ?? false;
    });
  }

  String formatContact(String contact, bool isPremium) {
    if (contact.isEmpty) return "--";
    if (isPremium) {
      return "+91 $contact";
    } else {
      return "+91 ${contact.substring(0, 2)}**** *****";
    }
  }

  @override
  Widget build(BuildContext context) {
    final pink = const Color(0xFFA51C48);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: pink,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // Set your desired color here
        ),
        title: Text(
          "${widget.match['name']} (${widget.match['age']} yrs)",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          // Profile Card
          Container(
            margin: const EdgeInsets.fromLTRB(12, 16, 12, 10),
            padding: const EdgeInsets.all(0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                        "https://pheonixconstructions.com/assets/profile_image/${widget.match['profile_img']}",
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              width: double.infinity,
                              height: 180,
                              color: Colors.grey[300],
                              child: const Icon(
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
                      // Verified, membership, phone/whatsapp row
                      Row(
                        children: [
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
                          IconButton(
                            icon: const Icon(
                              Icons.call,
                              color: Color(0xFFA51C48),
                              size: 22,
                            ),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const FaIcon(
                              FontAwesomeIcons.whatsapp,
                              color: Colors.green,
                              size: 22,
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Name, match %
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.match['name'] ?? "Unknown",
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
                            child: const Text(
                              "95% Match",
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF16C93B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "TN12KLMI981 | Last seen 2m ago",
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          Text(
                            "${widget.match['age'] ?? '--'} years • ${widget.match['caste'] ?? '--'} • ${widget.match['city'] ?? '--'}",
                            style: TextStyle(
                              fontSize: 14.5,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          Icon(
                            Icons.school,
                            size: 15,
                            color: Color(0xFFA51C48),
                          ),
                          SizedBox(width: 4),
                          Text(
                            widget.match['higher_education'] ?? "Not specified",
                            style: TextStyle(
                              fontSize: 13.5,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(width: 13),
                          Icon(Icons.work, size: 15, color: Color(0xFFA51C48)),
                          SizedBox(width: 4),
                          Text(
                            widget.match['occupation']
                                        ?.toString()
                                        .trim()
                                        .isNotEmpty ==
                                    true
                                ? widget.match['occupation']
                                : "Not specified",
                            style: TextStyle(
                              fontSize: 13.5,
                              color: Colors.black87,
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
          // About Section
          _SectionCard(
            title: "About ${widget.match['name'] ?? 'User'}",
            body:
                widget.match['about_yourself']?.toString().trim().isNotEmpty ==
                        true
                    ? widget.match['about_yourself']
                    : "No description provided.",
          ),
          // Basic Details
          _SectionCard(
            title: "Her Basic Details",
            bodyWidget: Table(
              columnWidths: const {
                0: FlexColumnWidth(1.7),
                1: FlexColumnWidth(2.3),
              },
              children: [
                TableRow(
                  children: [
                    const Text("Age"),
                    Text("${widget.match['age'] ?? '--'} Years"),
                  ],
                ),
                TableRow(
                  children: [
                    const Text("Physique"),
                    Text(
                      "${widget.match['weight'] ?? '--'} Kg | ${widget.match['height'] ?? '--'}",
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    const Text("Language"),
                    Text(widget.match['languages'] ?? '--'),
                  ],
                ),
                TableRow(
                  children: [
                    const Text("Marital Status"),
                    Text(widget.match['marital_status'] ?? '--'),
                  ],
                ),
                TableRow(
                  children: [
                    const Text("Lives in"),
                    Text(widget.match['city'] ?? '--'),
                  ],
                ),
                TableRow(
                  children: [
                    const Text("Citizenship"),
                    Text(widget.match['citizenship'] ?? '--'),
                  ],
                ),
                TableRow(
                  children: [
                    const Text("Smoking Habits"),
                    Text(widget.match['smoking'] ?? '--'),
                  ],
                ),
                TableRow(
                  children: [
                    const Text("Drinking Habits"),
                    Text(widget.match['drinking'] ?? '--'),
                  ],
                ),
              ],
            ),
          ),
          // Contact Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            child: Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(11),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.lock, size: 19, color: Colors.grey[700]),
                      const SizedBox(width: 4),
                      const Text(
                        "Contact Details ",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        formatContact(
                          widget.match['contact_no'] ?? '',
                          isPremiumUser, // boolean value you get from login/user data
                        ),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBF7F0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.verified,
                              color: Color(0xFF16C93B),
                              size: 13,
                            ),
                            SizedBox(width: 1),
                            Text(
                              "Mobile No. Verified",
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF16C93B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {},
                        icon: const FaIcon(
                          FontAwesomeIcons.whatsapp,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: const Text(
                          "Whatsapp",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          String? senderId = prefs.getString('user_id');

                          if (senderId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("User not logged in"),
                              ),
                            );
                            return;
                          }

                          String receiverId =
                              widget.match['user_id'].toString();

                          // Navigate to chat screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => MessageScreen(
                                    senderId: senderId,
                                    receiverId: receiverId,
                                    receiverName:
                                        widget.match['name'] ?? "User",
                                  ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.chat, color: Colors.white),
                        label: const Text(
                          "Chat",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pink,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SubscriptionScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Upgrade to view contact number",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Family Details
          _SectionCard(
            title: "Family Details",
            bodyWidget: Table(
              columnWidths: const {
                0: FlexColumnWidth(1.7),
                1: FlexColumnWidth(2.3),
              },
              children: const [
                TableRow(
                  children: [
                    Text("Father"),
                    Text("Ramesh Kumar, Retired Government Officer"),
                  ],
                ),
                TableRow(
                  children: [Text("Mother"), Text("Lakshmi, Homemaker")],
                ),
                TableRow(
                  children: [
                    Text("Siblings"),
                    Text("1 Brother (Married), 1 Sister (Studying)"),
                  ],
                ),
                TableRow(
                  children: [Text("Family Type"), Text("Nuclear Family")],
                ),
                TableRow(
                  children: [
                    Text("Family Values"),
                    Text("Traditional with Modern"),
                  ],
                ),
              ],
            ),
          ),
          // Education & Career
          _SectionCard(
            title: "Education & Career",
            bodyWidget: Table(
              columnWidths: const {
                0: FlexColumnWidth(1.7),
                1: FlexColumnWidth(2.3),
              },
              children: [
                TableRow(
                  children: [
                    Text("Education"),
                    Text("${widget.match['higher_education'] ?? '--'}"),
                  ],
                ),
                TableRow(
                  children: [Text("College"), Text("Anna University, Chennai")],
                ),
                TableRow(
                  children: [
                    Text("Profession"),
                    Text("${widget.match['occupation'] ?? '--'}"),
                  ],
                ),
                TableRow(
                  children: [
                    Text("Company"),
                    Text("${widget.match['employee_in'] ?? '--'}"),
                  ],
                ),
                TableRow(
                  children: [
                    Text("Income"),
                    Text("${widget.match['annual_income'] ?? '--'}"),
                  ],
                ),
              ],
            ),
          ),
          // Religious Background
          _SectionCard(
            title: "Religious Background",
            bodyWidget: Table(
              columnWidths: const {
                0: FlexColumnWidth(1.7),
                1: FlexColumnWidth(2.3),
              },
              children: [
                TableRow(
                  children: [
                    Text("Religion"),
                    Text("${widget.match['religion'] ?? '--'}"),
                  ],
                ),
                TableRow(
                  children: [
                    Text("Caste"),
                    Text("${widget.match['caste'] ?? '--'}"),
                  ],
                ),
                TableRow(
                  children: [
                    Text("Sub-caste"),
                    Text("${widget.match['sub_caste'] ?? '--'}"),
                  ],
                ),
                TableRow(
                  children: [
                    Text("Gothram"),
                    Text("${widget.match['Gothram'] ?? '--'}"),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            child: Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lock, size: 19, color: Colors.grey),
                      const SizedBox(width: 6),
                      const Text("Star"),
                      const Spacer(),
                      const Text("**********"),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.lock, size: 19, color: Colors.grey),
                      const SizedBox(width: 6),
                      const Text("Rasi"),
                      const Spacer(),
                      const Text("*******"),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pink,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SubscriptionScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Upgrade to view horoscope",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Partner Preferences
          _SectionCard(
            title: "Partner Preferences",
            bodyWidget: Table(
              columnWidths: const {
                0: FlexColumnWidth(1.7),
                1: FlexColumnWidth(2.3),
              },
              children: const [
                TableRow(children: [Text("Age"), Text("28–32 years")]),
                TableRow(children: [Text("Height"), Text("5'8\"–6'0\"")]),
                TableRow(
                  children: [
                    Text("Education"),
                    Text("Any Professional Degree"),
                  ],
                ),
                TableRow(
                  children: [
                    Text("Profession"),
                    Text("IT, Engineering, Medical,"),
                  ],
                ),
                TableRow(
                  children: [
                    Text("Location"),
                    Text("Chennai, Bangalore, Open to relocate"),
                  ],
                ),
                TableRow(
                  children: [
                    Text("Expectations"),
                    Text(
                      "Well-educated, family-oriented, respectful, ambitious",
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Profiles you may like
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Text(
                  "Profiles you may like",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const Spacer(),
                Text(
                  "View All",
                  style: TextStyle(
                    color: pink,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 98,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 12),
              children: [
                _ProfileSuggestionCard(
                  name: "Sri",
                  age: 26,
                  image: 'assets/images/user2.jpg',
                ),
                _ProfileSuggestionCard(
                  name: "Ramya Varanasi",
                  age: 24,
                  image: 'assets/images/user1.jpg',
                ),
                _ProfileSuggestionCard(
                  name: "Shalini M",
                  age: 24,
                  image: 'assets/images/user2.jpg',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String? body;
  final Widget? bodyWidget;
  const _SectionCard({required this.title, this.body, this.bodyWidget});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 6),
            if (body != null)
              Text(
                body!,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            if (bodyWidget != null) bodyWidget!,
          ],
        ),
      ),
    );
  }
}

class _ProfileSuggestionCard extends StatelessWidget {
  final String name;
  final int age;
  final String image;
  const _ProfileSuggestionCard({
    required this.name,
    required this.age,
    required this.image,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 95,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 7)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 58,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(11),
              ),
              color: Colors.grey[300],
              image: DecorationImage(
                image: AssetImage(image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          Text(
            '$age yrs',
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
