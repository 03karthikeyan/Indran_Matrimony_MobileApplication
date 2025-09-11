import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:matrimony/UI_Screens/Message_Screen.dart';
import 'package:matrimony/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'subscription_screen.dart';

class MatchesDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> match;

  const MatchesDetailsScreen({Key? key, required this.match}) : super(key: key);

  @override
  State<MatchesDetailsScreen> createState() => _MatchesDetailsScreenState();
}

class _MatchesDetailsScreenState extends State<MatchesDetailsScreen> {
  bool isPremiumUser = false;
  bool isLoading = true;
  double matchPercentage = 0.0; // dynamic match %

  bool isSubscribed = false;
  Map<String, dynamic>? subscriptionDetails;

  @override
  void initState() {
    super.initState();
    // _loadUserPremiumStatus();
    _checkSubscription();
  }

  Future<void> _checkSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    int? loggedInUserId = int.tryParse(prefs.getString("user_id") ?? "");

    if (loggedInUserId == null) {
      setState(() {
        isLoading = false;
        isPremiumUser = false; // default to free user
      });
      return;
    }

    try {
      final response = await ApiService.getSubscriptionStatus(loggedInUserId);

      if (response["status"] == "success") {
        final v = response["subscribed"];
        setState(() {
          // handle bool / int / string values
          isPremiumUser = v == true || v == 1 || v == "true";
          subscriptionDetails = response["subscription_details"];
          isLoading = false;
        });
      } else {
        setState(() {
          isPremiumUser = false;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isPremiumUser = false;
        isLoading = false;
      });
      debugPrint("Subscription check error: $e");
    }
  }

  Future<void> openDialer(String number) async {
    final Uri callUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      print("Cannot open dialer");
    }
  }

  Future<void> openWhatsApp(String number, String message) async {
    // Remove + or spaces
    number = number.replaceAll(RegExp(r'\s+|\+'), '');
    final Uri whatsappUri = Uri.parse(
      "whatsapp://send?phone=$number&text=${Uri.encodeComponent(message)}",
    );
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      print("WhatsApp not installed");
    }
  }

  // Example: Load from SharedPreferences or API
  // Future<void> _loadUserPremiumStatus() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     isPremiumUser = prefs.getBool('isPremium') ?? false;
  //   });
  // }

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
          "${widget.match['name']} ",
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
                          // ✅ Always show Verified
                          Container(
                            margin: const EdgeInsets.only(left: 7),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 3,
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
                                  size: 15,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "Verified",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF16C93B),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ✅ Show Membership + actions only for premium
                          if (isPremiumUser) ...[
                            const SizedBox(width: 6),
                            Container(
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
                              icon: const Icon(Icons.call),
                              onPressed:
                                  () => openDialer(
                                    widget.match['contact_no'] ?? '',
                                  ),
                            ),

                            IconButton(
                              icon: const FaIcon(
                                FontAwesomeIcons.whatsapp,
                                color: Colors.green,
                              ),
                              onPressed:
                                  () => openWhatsApp(
                                    widget.match['contact_no'] ?? '',
                                    "Hi, I am interested in connecting with you.",
                                  ),
                            ),
                          ],
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
                        ],
                      ),
                      const SizedBox(height: 2),
                      // const Text(
                      //   "TN12KLMI981 | Last seen 2m ago",
                      //   style: TextStyle(fontSize: 12, color: Colors.black54),
                      // ),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          Text(
                            "${widget.match['age'] ?? '29'} years • ${widget.match['caste'] ?? 'Others'} • ${widget.match['city'] ?? '--'}",
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
                            widget.match['higher_education'] ?? "MCA",
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
                    : "Hi Thanks for visiting my profile..",
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
                    Text("${widget.match['age'] ?? '29'} Years"),
                  ],
                ),

                TableRow(
                  children: [
                    const Text("Language"),
                    Text('Tamil,English,Hindi'),
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
                    const Text("State"),
                    Text(widget.match['state'] ?? '--'),
                  ],
                ),
                TableRow(children: [const Text("Smoking Habits"), Text('No')]),
                TableRow(children: [const Text("Drinking Habits"), Text('No')]),
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
                  const SizedBox(height: 5),
                  Text(
                    formatContact(
                      widget.match['contact_no'] ?? '9876543210',
                      isPremiumUser,
                    ),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),

                  // ✅ Show WhatsApp & Chat only if Premium
                  if (isPremiumUser) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          onPressed: () async {
                            String contact = widget.match['contact_no'] ?? '';

                            if (contact.isEmpty) return;

                            // Remove spaces or dashes
                            contact = contact.replaceAll(RegExp(r'\s+|-'), '');

                            // Add country code if missing
                            if (!contact.startsWith('+')) {
                              contact = '+91$contact';
                            }

                            // Use WhatsApp custom scheme
                            final whatsappUrl = Uri.parse(
                              "whatsapp://send?phone=${contact.replaceAll('+', '')}&text=${Uri.encodeComponent("Hi, I am interested in connecting with you.")}",
                            );

                            try {
                              if (await canLaunchUrl(whatsappUrl)) {
                                await launchUrl(
                                  whatsappUrl,
                                  mode: LaunchMode.externalApplication,
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "WhatsApp is not installed on this device.",
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Error opening WhatsApp: $e"),
                                ),
                              );
                            }
                          },
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
                          ),
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            String? senderId = prefs.getString('user_id');
                            if (senderId == null) return;

                            String receiverId =
                                widget.match['user_id'].toString();
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
                  ] else ...[
                    // ✅ Show Upgrade button only if NOT premium
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: pink),
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
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
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
                    Text("${widget.match['higher_education'] ?? 'MCA'}"),
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
                    Text("${widget.match['employee_in'] ?? 'Private'}"),
                  ],
                ),
                TableRow(
                  children: [
                    Text("Income"),
                    Text("${widget.match['annual_income'] ?? '3LPA'}"),
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
                    Text("${widget.match['religion'] ?? 'Hindu'}"),
                  ],
                ),
                TableRow(
                  children: [
                    Text("Caste"),
                    Text("${widget.match['caste'] ?? 'Others'}"),
                  ],
                ),
                TableRow(
                  children: [
                    Text("Sub-caste"),
                    Text("${widget.match['sub_caste'] ?? 'Subcaste1'}"),
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
              child:
                  isPremiumUser
                      ? Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.star),
                              Text(
                                'Star',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              Text("Bharani"),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.brightness_3),
                              Text(
                                'Rasi',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              Text("Cancer"),
                            ],
                          ),
                        ],
                      )
                      : Column(
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.lock),
                              Text(
                                'Star',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Spacer(),
                              Text("**********"),
                            ],
                          ),
                          Row(
                            children: const [
                              Icon(Icons.lock),
                              Text(
                                'Rasi',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Spacer(),
                              Text("*******"),
                            ],
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: pink,
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
                              style: TextStyle(color: Colors.white),
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
