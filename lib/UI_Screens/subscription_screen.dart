import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:matrimony/UI_Screens/payment_screen.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool isLoading = true;
  String? error;
  List<dynamic> subscriptionPlans = [];

  final PageController _pageController = PageController(viewportFraction: 0.82);

  @override
  void initState() {
    super.initState();
    _loadSubscriptionPlans();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadSubscriptionPlans() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      const url =
          'https://pheonixconstructions.com/Matrimony API/subscription_plan_list.php';
      final uri = Uri.parse(Uri.encodeFull(url)); // encode spaces properly
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        // Defensive: ensure 'data' is a List
        final rawData = decoded['data'];
        if (rawData is List) {
          setState(() {
            subscriptionPlans = rawData;
            isLoading = false;
          });
        } else {
          setState(() {
            error = 'Unexpected response format (data is not a list)';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          error = 'Server error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Network / parse error: $e';
        isLoading = false;
      });
    }
  }

  // Default features if API doesn't provide them
  List<String> _defaultFeatures() => [
    "Unlimited profile views",
    "Send 50 interests daily",
    "Advanced search filters",
    "Priority customer support",
    "Profile highlighting",
    "Video call feature",
  ];

  @override
  Widget build(BuildContext context) {
    final pink = const Color(0xFFA51C48);
    final pinkGradient = const LinearGradient(
      colors: [Color(0xFFA51C48), Color(0xFFFF3D8E)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    // compute a reasonable card height based on screen
    final screenHeight = MediaQuery.of(context).size.height;
    final double cardHeight =
        screenHeight * 0.52; // adjust to taste (keeps PageView bounded)
    final double cardHeightClamped = cardHeight.clamp(360.0, 560.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(62),
        child: Container(
          decoration: BoxDecoration(
            color: pink,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(22),
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Text(
                    "Subscription Plans",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.help_outline, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadSubscriptionPlans,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          children: [
            const SizedBox(height: 26),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 9,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: const FaIcon(
                  FontAwesomeIcons.crown,
                  color: Color(0xFFFFC954),
                  size: 36,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                "Choose Your Perfect Plan",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
            ),
            const SizedBox(height: 7),
            const Center(
              child: Text(
                "Find your life partner with our premium features",
                style: TextStyle(fontSize: 15, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 14),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 17,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F7EA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.local_offer, color: Color(0xFF39B36B), size: 18),
                    SizedBox(width: 7),
                    Text(
                      "Save up to 40% on annual plans",
                      style: TextStyle(
                        color: Color(0xFF39B36B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --- error / loading / content area ---
            if (isLoading)
              SizedBox(
                height: cardHeightClamped,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.pink),
                ),
              )
            else if (error != null)
              SizedBox(
                height: 160,
                child: Center(
                  child: Text(
                    error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              )
            else if (subscriptionPlans.isEmpty)
              SizedBox(
                height: 160,
                child: const Center(child: Text("No plans available")),
              )
            else
              // BOUND the PageView's height so it can render inside a ListView
              SizedBox(
                height: cardHeightClamped,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: subscriptionPlans.length,
                  itemBuilder: (context, index) {
                    final plan =
                        subscriptionPlans[index] as Map<String, dynamic>? ?? {};

                    // scaling / carousel effect
                    double page = 0;
                    if (_pageController.hasClients) {
                      page =
                          _pageController.page ??
                          _pageController.initialPage.toDouble();
                    }
                    final double delta = (index - page).abs();
                    final double scale = 1 - min(delta * 0.12, 0.12);

                    // features: prefer API-provided list if exists, else default
                    final List<String> features =
                        (plan['features'] is String &&
                                (plan['features'] as String).trim().isNotEmpty)
                            ? (plan['features'] as String)
                                .split(',')
                                .map((s) => s.trim())
                                .toList()
                            : _defaultFeatures();

                    return Transform.scale(
                      scale: scale,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 8.0,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: pinkGradient,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.pink.shade100,
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // header row: plan name + price
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        plan['plan_name'] ?? 'Plan',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 19,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (plan['status']?.toString() == '1')
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.10),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Text(
                                          "Most chosen plan",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12.5,
                                          ),
                                        ),
                                      ),
                                    const Spacer(),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "₹${plan['plan_amount'] ?? ''}",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 22,
                                          ),
                                        ),
                                        Text(
                                          "/${plan['duration'] ?? ''}",
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // features list inside constrained scroll area to avoid overflow
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children:
                                          features
                                              .map((f) => _featureRow(f))
                                              .toList(),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // choose button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(9),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      elevation: 0,
                                    ),
                                    onPressed: () {
                                      // Navigate to your real PaymentScreen and pass the plan map
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) {
                                            return PaymentScreen(plan: plan);
                                          },
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "Choose ${plan['plan_name'] ?? 'Plan'}",
                                      style: TextStyle(
                                        color: pink,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 32),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Why Choose Premium?",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  _PremiumReason(
                    icon: Icons.favorite,
                    label: "More Matches",
                    desc: "Get 3x more profile views",
                  ),
                  _PremiumReason(
                    icon: Icons.verified,
                    label: "Verified Profiles",
                    desc: "Connect with genuine people",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  _PremiumReason(
                    icon: Icons.star,
                    label: "Priority Support",
                    desc: "24/7 dedicated assistance",
                  ),
                  _PremiumReason(
                    icon: Icons.flash_on,
                    label: "Instant Chat",
                    desc: "Real-time messaging",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 26),
                child: RichText(
                  text: TextSpan(
                    text: "By continuing, you agree to our ",
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: Colors.black54,
                    ),
                    children: [
                      TextSpan(
                        text: "Terms & Conditions",
                        style: TextStyle(
                          color: pink,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureRow(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFFE9FFB0), size: 19),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Demo payment screen used for testing. Replace with your real PaymentScreen.
class _PaymentScreenDemo extends StatelessWidget {
  final Map<String, dynamic> plan;
  const _PaymentScreenDemo({required this.plan, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final name = plan['plan_name'] ?? 'Plan';
    final amount = plan['plan_amount'] ?? '0';
    final duration = plan['duration'] ?? '';
    return Scaffold(
      appBar: AppBar(title: Text('Pay — $name')),
      body: Center(
        child: Text('Proceed to pay ₹$amount for $name ($duration)'),
      ),
    );
  }
}

class _PremiumReason extends StatelessWidget {
  final IconData icon;
  final String label;
  final String desc;
  const _PremiumReason({
    required this.icon,
    required this.label,
    required this.desc,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pink = const Color(0xFFA51C48);
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: pink.withOpacity(0.1),
          child: Icon(icon, color: pink, size: 26),
          radius: 26,
        ),
        const SizedBox(height: 9),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 2),
        SizedBox(
          width: 90,
          child: Text(
            desc,
            style: const TextStyle(fontSize: 12.5, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
