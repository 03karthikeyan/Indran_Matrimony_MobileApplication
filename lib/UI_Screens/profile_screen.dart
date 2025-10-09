import 'dart:io';
import 'package:flutter/material.dart';
import 'package:matrimony/UI_Screens/EditProfileScreen.dart';
import 'package:matrimony/UI_Screens/KYC_Uploads.dart';
import 'package:matrimony/UI_Screens/Personal_Imformation.dart';
import 'package:matrimony/UI_Screens/help_support.dart';
import 'package:matrimony/UI_Screens/interests_received_screen.dart';
import 'package:matrimony/UI_Screens/login_screen.dart';
import 'package:matrimony/UI_Screens/privacy_setting.dart';
import 'package:matrimony/models/user_data.dart';
import 'package:matrimony/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'subscription_screen.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;
  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  bool isActive = true;
  String _selectedLanguage = 'en'; // default English

  // Subscription
  bool isSubscribed = false;
  Map<String, dynamic>? subscriptionDetails;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    await fetchProfile();
    await fetchSubscriptionStatus();
  }

  bool _parseActive(dynamic status) {
    if (status == null) return false;
    if (status is int) return status == 1;
    if (status is bool) return status == true;
    if (status is String) {
      final s = status.toLowerCase().trim();
      return s == '1' || s == 'active' || s == 'true' || s == 'yes';
    }
    return false;
  }

  Future<void> fetchProfile() async {
    setState(() => isLoading = true);
    final result = await ApiService.getProfiles(widget.userId);

    if (result['success']) {
      setState(() {
        userData = result['user_data'];
        // robust parsing of status
        isActive = _parseActive(userData?['status']);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      debugPrint(result['error']);
    }
  }

  Future<void> fetchSubscriptionStatus() async {
    try {
      final result = await ApiService.getSubscriptionStatus(widget.userId);
      if (!mounted) return;

      if (result['status'] == 'success') {
        final v = result['subscribed'];
        setState(() {
          isSubscribed = v == true || v == 1 || v == 'true';
          subscriptionDetails = result['subscription_details'];
        });
      }
    } catch (e) {
      debugPrint('Subscription fetch error: $e');
    }
  }

  void _showAlertDialog(String title, String message, Color color) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Row(
              children: [
                Icon(Icons.info, color: color),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(color: color)),
              ],
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    ); // 📂 or camera

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      // TODO: Call API to upload profile image
      final result = await ApiService.uploadProfileImage(
        widget.userId,
        imageFile,
      );

      if (result['success']) {
        setState(() {
          userData?['profile_img'] = result['image_url']; // update UI
        });
        _showAlertDialog("Success", "Profile photo updated!", Colors.green);
      } else {
        _showAlertDialog("Error", "Failed to update photo", Colors.red);
      }
    }
  }

  double calculateProfileCompletion(Map<String, dynamic>? data) {
    if (data == null) return 0;

    final fields = [
      'name',
      'contact_no',
      'dob',
      'age',
      'email_id',
      'gender',
      'religion',
      'inter_caste',
      'caste',
      'sub_caste',
      'dosham',
      'higher_education',
      'employee_in',
      'occupation',
      'annual_income',
      'work_location',
      'state',
      'city',
      'about_yourself',
      'profile_img',
    ];

    int filled = 0;
    for (var field in fields) {
      if (data[field] != null &&
          data[field].toString().trim().isNotEmpty &&
          data[field].toString().trim() != '0') {
        filled++;
      }
    }

    return (filled / fields.length) * 100;
  }

  //Language selector

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        String selectedLang = _selectedLanguage; // local copy
        return StatefulBuilder(
          builder:
              (context, innerSetState) => Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Select Language",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink[800],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _languageCard(
                          label: "English",
                          isSelected: selectedLang == 'en',
                          onTap: () => innerSetState(() => selectedLang = 'en'),
                        ),
                        _languageCard(
                          label: "தமிழ்",
                          isSelected: selectedLang == 'ta',
                          onTap: () => innerSetState(() => selectedLang = 'ta'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // ✅ update main state so the UI refreshes
                          setState(() {
                            _selectedLanguage = selectedLang;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink[700],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Confirm",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pinkColor = const Color(0xFFA51C48);
    final completionPercent = calculateProfileCompletion(userData);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Enhanced Header
              Container(
                padding: const EdgeInsets.only(
                  top: 40,
                  left: 18,
                  right: 18,
                  bottom: 20,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [pinkColor.withOpacity(0.9), pinkColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Top Row: Title + Premium Badge + Language
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            profileLabels[_selectedLanguage]!['my_profile'] ??
                                "My Profile",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Premium Badge
                        if (isSubscribed)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.workspace_premium,
                                  size: 16,
                                  color: Colors.black,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  profileLabels[_selectedLanguage]!['premium'] ??
                                      "Premium",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (isSubscribed) const SizedBox(width: 8),

                        // Language Selector
                        GestureDetector(
                          onTap: _showLanguageSelector,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.language,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _selectedLanguage == 'en' ? 'EN' : 'தமிழ்',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // Profile Avatar with border and shadow
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 52,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage:
                                  (userData?['profile_img_path'] != null &&
                                          userData!['profile_img_path']
                                              .toString()
                                              .isNotEmpty)
                                      ? NetworkImage(
                                        userData!['profile_img_path'],
                                      )
                                      : const AssetImage(
                                            'assets/Ellipse222(1).png',
                                          )
                                          as ImageProvider,
                            ),
                          ),
                        ),

                        // Optional: Premium overlay icon
                        if (isSubscribed)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.workspace_premium,
                                size: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Name
                    Text(
                      userData?['name'] ?? "Unknown User",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            blurRadius: 3,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Membership Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSubscribed ? Icons.verified : Icons.lock_open,
                          size: 16,
                          color: isSubscribed ? Colors.green : Colors.white70,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isSubscribed
                              ? profileLabels[_selectedLanguage]!['premium_member'] ??
                                  "Premium Member"
                              : profileLabels[_selectedLanguage]!['free_member'] ??
                                  "Free Member",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        if (!isSubscribed) ...[
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SubscriptionScreen(),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 3,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                "Upgrade",
                                style: TextStyle(
                                  color: pinkColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Profile Completion
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 4),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          profileLabels[_selectedLanguage]!['profile_completion'] ??
                              "Profile Completion",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "${completionPercent.toStringAsFixed(0)}%",
                          style: TextStyle(
                            color: pinkColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (completionPercent / 100),
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(pinkColor),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Complete your profile to get more matches",
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Menu
              _MenuItem(
                icon: Icons.person,
                title: profileLabels[_selectedLanguage]!['personal_details']!,
                onTap: () async {
                  // Fetch user profile dynamically
                  final result = await ApiService.getProfiles(widget.userId);

                  if (result['success']) {
                    final userJson = result['user_data'];
                    final user =
                        UserData()
                          ..name = userJson['name']?.toString()
                          ..contactNo = userJson['contact_no']?.toString()
                          ..dob = userJson['dob']?.toString()
                          ..age = userJson['age']?.toString()
                          ..emailId = userJson['email_id']?.toString()
                          ..gender = userJson['gender']?.toString()
                          ..religion = userJson['religion']?.toString()
                          ..interCaste = userJson['inter_caste']?.toString()
                          ..caste = userJson['caste']?.toString()
                          ..subCaste = userJson['sub_caste']?.toString()
                          ..dosham = userJson['dosham']?.toString()
                          ..higherEducation =
                              userJson['higher_education']?.toString()
                          ..employeeIn = userJson['employee_in']?.toString()
                          ..occupation = userJson['occupation']?.toString()
                          ..annualIncome = userJson['annual_income']?.toString()
                          ..workLocation = userJson['work_location']?.toString()
                          ..state = userJson['state']?.toString()
                          ..city = userJson['city']?.toString()
                          ..aboutYourself =
                              userJson['about_yourself']?.toString()
                          ..profileImg = userJson['profile_img']?.toString();

                    // Navigate with user data
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PersonalDetailsScreen(user: user),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          result['error'] ?? 'Failed to load profile',
                        ),
                      ),
                    );
                  }
                },
              ),
              _MenuItem(
                icon: Icons.favorite,
                title: profileLabels[_selectedLanguage]!['interests_received']!,
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const InterestsReceivedScreen(),
                      ),
                    ),
              ),
              _MenuItem(
                icon: Icons.history,
                title: profileLabels[_selectedLanguage]!['kyc_uploads']!,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => KycUploadScreen()),
                  );
                },
              ),

              // _MenuItem(
              //   icon: Icons.photo_library,
              //   title: 'Photo Gallery',
              //   onTap:
              //       () => Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //           builder: (_) => MatrimonyGalleryUpload(),
              //         ),
              //       ),
              // ),
              _MenuItem(
                icon: Icons.workspace_premium,
                title: profileLabels[_selectedLanguage]!['subscription']!,
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SubscriptionScreen(),
                      ),
                    ),
              ),
              // _MenuItem(
              //   icon: isActive ? Icons.visibility : Icons.visibility_off,
              //   title: isActive ? "Deactivate Profile" : "Activate Profile",
              //   onTap: () => _showStatusConfirmDialog(context),
              // ),
              _MenuItem(
                icon: Icons.privacy_tip,
                title: profileLabels[_selectedLanguage]!['privacy_settings']!,
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PrivacySettingsScreen(),
                      ),
                    ),
              ),
              _MenuItem(
                icon: Icons.help,
                title: profileLabels[_selectedLanguage]!['help_support']!,
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HelpSupportScreen(),
                      ),
                    ),
              ),

              _MenuItem(
                icon: Icons.logout,
                title: profileLabels[_selectedLanguage]!['logout']!,
                onTap: () async {
                  showDialog(
                    context: context,
                    builder:
                        (_) => AlertDialog(
                          title: const Text("Logout"),
                          content: const Text(
                            "Are you sure you want to log out?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).pop();
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.clear();
                                if (!mounted) return;
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                  (route) => false,
                                );
                              },
                              child: const Text("Logout"),
                            ),
                          ],
                        ),
                  );
                },
                isLast: true,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _languageCard({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
        decoration: BoxDecoration(
          color: isSelected ? Colors.pink[100] : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.pink : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.pink.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.pink[800] : Colors.black87,
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isLast;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final pinkColor = const Color(0xFFA51C48);

    return Container(
      margin: EdgeInsets.only(left: 16, right: 16, bottom: isLast ? 0 : 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: pinkColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: pinkColor, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.black54,
        ),
        onTap: onTap,
      ),
    );
  }
}

// menu labels in both languages

Map<String, Map<String, String>> profileLabels = {
  'en': {
    'personal_details': 'Personal Details',
    'interests_received': 'Interests Received',
    'kyc_uploads': 'KYC Uploads',
    'subscription': 'Subscription',
    'privacy_settings': 'Privacy Settings',
    'help_support': 'Help & Support',
    'logout': 'Logout',
    'upgrade': 'Upgrade',
    'my_profile': 'My Profile',
    'free_member': 'Free Member',
    'premium_member': 'Premium Member',
    'profile_completion': 'Profile Completion',
    'premium': 'Premium',
    'complete your profile to get more matches':
        'Complete your profile to get more matches',
  },
  'ta': {
    'personal_details': 'தனிப்பட்ட தகவல்கள்',
    'interests_received': 'வேண்டிய ஆர்வங்கள்',
    'kyc_uploads': 'KYC பதிவேற்றங்கள்',
    'subscription': 'சந்தா',
    'privacy_settings': 'தனியுரிமை அமைப்புகள்',
    'help_support': 'உதவி மற்றும் ஆதரவு',
    'logout': 'வெளியேறு',
    'upgrade': 'மேம்படுத்தவும்',
    'my_profile': 'என் ப்ரொஃபைல்',
    'free_member': 'இலவச உறுப்பினர்',
    'premium_member': 'ப்ரீமியம் உறுப்பினர்',
    'profile_completion': 'ப்ரொஃபைல் நிறைவு',
    'premium': 'ப்ரீமியம்',
    'complete your profile to get more matches':
        'மேலும் பொருத்தங்களை பெற உங்கள் ப்ரொஃபைலை முழுமையாக்கவும்',
  },
};
