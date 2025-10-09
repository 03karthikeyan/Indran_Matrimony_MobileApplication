import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:matrimony/UI_Screens/Message_Screen.dart';
import 'package:matrimony/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
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

  Future<void> openWhatsApp(String phone, String message) async {
    final encodedMessage = Uri.encodeComponent(message);
    final whatsappAppUrl = "whatsapp://send?phone=$phone&text=$encodedMessage";
    final whatsappWebUrl = "https://wa.me/$phone?text=$encodedMessage";

    try {
      // Try WhatsApp App first
      if (await launchUrlString(
        whatsappAppUrl,
        mode: LaunchMode.externalApplication,
      )) {
        print("Opened WhatsApp app");
      } else {
        // fallback to WhatsApp Web
        if (await launchUrlString(
          whatsappWebUrl,
          mode: LaunchMode.externalApplication,
        )) {
          print("Opened WhatsApp Web");
        } else {
          print("Cannot launch WhatsApp Web either");
        }
      }
    } catch (e) {
      print("Error opening WhatsApp: $e");
    }
  }

  String formatContact(String contact, bool isPremium) {
    if (contact.isEmpty) return "--";

    if (isPremium) {
      // show full number
      return "+91 $contact";
    } else {
      if (contact.length < 4) {
        // safety: if number is too short
        return "+91 ****";
      }
      String firstTwo = contact.substring(0, 2);
      String lastTwo = contact.substring(contact.length - 2);
      String masked = "*" * (contact.length - 4); // mask middle part
      return "+91 $firstTwo$masked$lastTwo";
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
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "${widget.match['name']} ",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          // Profile Card
          Container(
            margin: const EdgeInsets.fromLTRB(12, 16, 12, 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Image with Match % overlay
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: Image.network(
                        "https://pheonixconstructions.com/assets/profile_image/${widget.match['profile_img']}",
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              width: double.infinity,
                              height: 200,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.white,
                              ),
                            ),
                      ),
                    ),

                    // Match Percentage Circle on top-left
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 55,
                            height: 55,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[200],
                            ),
                          ),
                          SizedBox(
                            width: 55,
                            height: 55,
                            child: CircularProgressIndicator(
                              value: (widget.match['matchPercent'] ?? 60) / 100,
                              strokeWidth: 5,
                              color: Color(0xFF16C93B),
                              backgroundColor: Colors.grey[300],
                            ),
                          ),
                          Text(
                            "${widget.match['matchPercent'] ?? 60}%",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Verified Badge top-right
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBF7F0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.verified,
                              color: Color(0xFF16C93B),
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              "Verified",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF16C93B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + Age/Location/Caste
                      Text(
                        widget.match['name'] ?? "Unknown",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.match['user_code'] ?? "--",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "${widget.match['age'] ?? '--'} yrs • ${widget.match['caste'] ?? '--'} • ${widget.match['city'] ?? '--'}",
                        style: const TextStyle(
                          fontSize: 14.5,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Education & Job Row
                      Row(
                        children: [
                          Icon(
                            Icons.school,
                            size: 16,
                            color: Color(0xFFA51C48),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.match['higher_education'] ?? "--",
                              style: const TextStyle(
                                fontSize: 13.5,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Icon(Icons.work, size: 16, color: Color(0xFFA51C48)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.match['occupation']?.trim().isNotEmpty ==
                                      true
                                  ? widget.match['occupation']
                                  : "Not specified",
                              style: const TextStyle(
                                fontSize: 13.5,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Premium / Free Chip & Actions
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isPremiumUser
                                      ? Color(0xFFEAF6FF)
                                      : Color(0xFFFFF0F0),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isPremiumUser
                                      ? Icons.workspace_premium
                                      : Icons.person_outline,
                                  color:
                                      isPremiumUser
                                          ? Color(0xFF1D7AF5)
                                          : Colors.red,
                                  size: 16,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  isPremiumUser
                                      ? "Premium Member"
                                      : "Free Member",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        isPremiumUser
                                            ? Color(0xFF1D7AF5)
                                            : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Spacer(),

                          // Only Premium users see contact options
                          if (isPremiumUser) ...[
                            IconButton(
                              icon: const Icon(
                                Icons.call,
                                color: Color(0xFFA51C48),
                              ),
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
                    ],
                  ),
                ),
              ],
            ),
          ),
          // About Section
          _SectionCard(
            title: "About ${widget.match['name'] ?? '--'}",
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
                    Text("${widget.match['age'] ?? '--'} Years"),
                  ],
                ),

                TableRow(
                  children: [
                    const Text("Gender"),
                    Text(widget.match['gender'] ?? '--'),
                  ],
                ),
                TableRow(
                  children: [
                    const Text("Martial Status"),
                    Text(widget.match['marital_status'] ?? '--'),
                  ],
                ),
                TableRow(
                  children: [
                    const Text("Physical Status"),
                    Text(widget.match['physical_status'] ?? '--'),
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
                TableRow(
                  children: [
                    const Text("Height"),
                    Text(widget.match['height'] ?? '--'),
                  ],
                ),
                TableRow(
                  children: [
                    const Text("Weight"),
                    Text(widget.match['weight'] ?? '--'),
                  ],
                ),
                TableRow(
                  children: [
                    const Text("Mother Tongue"),
                    Text(widget.match['mother_tongue'] ?? '--'),
                  ],
                ),
                TableRow(
                  children: [
                    const Text("Diet"),
                    Text(widget.match['diet'] ?? '--'),
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            isPremiumUser
                                ? Colors.green.shade400
                                : Colors.grey.shade400,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 🇮🇳 Indian Flag
                            Text(
                              "🇮🇳",
                              style: const TextStyle(
                                fontSize: 20,
                              ), // adjust size
                            ),

                            const SizedBox(width: 8),

                            // Vertical Divider
                            Container(
                              width: 1,
                              height: 20,
                              color: Colors.grey.shade400,
                            ),

                            const SizedBox(width: 8),

                            // Contact Number
                            Text(
                              formatContact(
                                widget.match['contact_no'] ?? '9876543210',
                                isPremiumUser,
                              ),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color:
                                    isPremiumUser
                                        ? Colors.green.shade800
                                        : Colors.black87,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
              children: [
                TableRow(
                  children: [
                    Text("Father's Name"),
                    Text(widget.match['father_name'] ?? '--'),
                  ],
                ),
                TableRow(
                  children: [
                    Text("Mother's Name"),
                    Text(widget.match['mother_name'] ?? '--'),
                  ],
                ),
                TableRow(
                  children: [
                    Text("Siblings"),
                    Text(widget.match['siblings'] ?? '--'),
                  ],
                ),
                TableRow(
                  children: [
                    Text("Native Place"),
                    Text(widget.match['native_place'] ?? '--'),
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
                    Text("Work Location"),
                    Text("${widget.match['work_location'] ?? '--'}"),
                  ],
                ),
                TableRow(
                  children: [
                    Text("Income"),
                    Text("${widget.match['income_range'] ?? '--'}"),
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
                    Text("Dosam"),
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
                          // Jathakam
                          if (widget.match['jathakam_path'] != null &&
                              widget.match['jathakam_path']
                                  .toString()
                                  .isNotEmpty)
                            InkWell(
                              onTap: () {
                                // Open PDF or file
                                launchUrl(
                                  Uri.parse(widget.match['jathakam_path']),
                                );
                              },
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.picture_as_pdf,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Jathakam',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.arrow_forward_ios, size: 16),
                                ],
                              ),
                            ),
                          const SizedBox(height: 10),

                          // Community Certificate
                          if (widget.match['community_certificate_path'] !=
                                  null &&
                              widget.match['community_certificate_path']
                                  .toString()
                                  .isNotEmpty)
                            InkWell(
                              onTap: () {
                                launchUrl(
                                  Uri.parse(
                                    widget.match['community_certificate_path'],
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.picture_as_pdf,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Community Certificate',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.arrow_forward_ios, size: 16),
                                ],
                              ),
                            ),
                        ],
                      )
                      : Column(
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.lock, color: Colors.grey),
                              SizedBox(width: 8),
                              Text(
                                'Jathakam',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Spacer(),
                              Text("**********"),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: const [
                              Icon(Icons.lock, color: Colors.grey),
                              SizedBox(width: 8),
                              Text(
                                'Community Certificate',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Spacer(),
                              Text("**********"),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink,
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
                              "Upgrade to view documents",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
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
