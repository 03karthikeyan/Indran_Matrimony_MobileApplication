import 'package:flutter/material.dart';
import 'package:matrimony/UI_Screens/Edit_PersonalDetails.dart';
import 'package:matrimony/UI_Screens/familyDetails_Updation.dart';
import 'package:matrimony/models/user_data.dart';
import 'package:matrimony/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class PersonalDetailsScreen extends StatefulWidget {
  final UserData user;

  const PersonalDetailsScreen({super.key, required this.user});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  late bool isActive;
  UserData? _fetchedUser;
  bool _isLoading = true;
  String _selectedLanguage = 'en'; // default English

  @override
  void initState() {
    super.initState();
    // user_sts: "0" → active, "1" → deactivated
    isActive = widget.user.isActive ?? true;
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedId = prefs.getString('user_id');
      final userId = int.tryParse(storedId ?? '') ?? widget.user.userId;

      if (userId != null) {
        final response = await ApiService.getProfiles(userId);

        if (response['success'] == true) {
          // ✅ check success instead of status
          final userJson = response['user_data'];
          setState(() {
            _fetchedUser = UserData.fromJson(userJson);
            _fetchedUser?.badge = response['badge'];
            isActive = _fetchedUser?.isActive ?? true;
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      debugPrint("Profile fetch error: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleUserStatus() async {
    int? userId = widget.user.userId;

    // fallback to shared preferences if null
    if (userId == null) {
      final prefs = await SharedPreferences.getInstance();
      final storedId = prefs.getString('user_id');
      if (storedId != null && storedId.isNotEmpty) {
        userId = int.tryParse(storedId);
      }
    }

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("User ID not found"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Map<String, dynamic> response;

    try {
      if (isActive) {
        response = await ApiService.deactivateUser(userId);
      } else {
        response = await ApiService.activateUser(userId);
      }

      if (response['success'] == true) {
        setState(() {
          isActive = !isActive;
          widget.user.isActive = isActive;
          widget.user.userId = userId; // ✅ update in model too
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['message'] ??
                  (isActive
                      ? "Profile activated successfully"
                      : "Profile deactivated successfully"),
            ),
            backgroundColor: isActive ? Colors.green : Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? "Failed to update status"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        String selectedLanguage = _selectedLanguage;

        return StatefulBuilder(
          builder:
              (context, setState) => Padding(
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

                    // Language Cards Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _languageCard(
                          label: "English",
                          isSelected: selectedLanguage == 'en',
                          onTap: () => setState(() => selectedLanguage = 'en'),
                        ),
                        _languageCard(
                          label: "தமிழ்",
                          isSelected: selectedLanguage == 'ta',
                          onTap: () => setState(() => selectedLanguage = 'ta'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Confirm Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _changeLanguage(selectedLanguage);
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
                    const SizedBox(height: 10),
                  ],
                ),
              ),
        );
      },
    );
  }

  // Custom Language Card
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

  void _changeLanguage(String lang) {
    setState(() {
      _selectedLanguage = lang;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = _fetchedUser ?? widget.user;
    final pink = const Color(0xFFA51C48);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: pink,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          appBarTitles[_selectedLanguage] ?? "Personal Information",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          // Language selector button as a card/icon combination
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              // onTap: _showLanguageSelector,
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
                    const Icon(Icons.language, color: Colors.white, size: 20),
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
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ✅ Profile Header Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.pink[100],
                          backgroundImage:
                              (user.profileImg != null &&
                                      user.profileImg!.isNotEmpty &&
                                      user.profileImg!.toLowerCase() != "null")
                                  ? (user.profileImg!.startsWith("http")
                                      ? NetworkImage(user.profileImg!)
                                      : NetworkImage(
                                        "https://pheonixconstructions.com/assets/profile_image/${user.profileImg}",
                                      ))
                                  : const AssetImage("assets/user.png")
                                      as ImageProvider,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 4,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 2,
                              ),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: Colors.pinkAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (user.badge != null && user.badge!.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.green.shade700,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.verified, // choose any icon you like
                              size: 16,
                              color: Colors.green, // match the badge theme
                            ),
                            const SizedBox(width: 6),
                            Text(
                              user.badge!,
                              style: TextStyle(
                                color: Colors.green.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 10),
                    Text(
                      "${labels[_selectedLanguage]!['user_code'] ?? 'User Code'}: ${user.userCode ?? '-'}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ✅ Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(Icons.edit, color: Colors.white),
                          label: const Text(
                            "Edit",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            final updated = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) =>
                                        EditPersonalDetailsScreen(user: user),
                              ),
                            );
                            if (updated == true) {
                              _loadProfile(); // refresh immediately after edit
                            }
                          },
                        ),

                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isActive ? Colors.redAccent : Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _toggleUserStatus,
                          icon: Icon(
                            isActive ? Icons.block : Icons.check_circle,
                            color: Colors.white,
                          ),
                          label: Text(
                            isActive
                                ? (labels[_selectedLanguage]!['deactivate'] ??
                                    "Deactivate")
                                : (labels[_selectedLanguage]!['activate'] ??
                                    "Activate"),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(
                        Icons.family_restroom_rounded,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Add_FamilyDetails",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () async {
                        final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => FamilyDetailsUpdateScreen(
                                  userId:
                                      user.userId.toString(), // ✅ FIXED TYPE
                                ),
                          ),
                        );
                        if (updated == true) {
                          _loadProfile(); // ✅ refresh profile data after update
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ✅ Your Info Cards (unchanged)
            _buildInfoCard(
              labels[_selectedLanguage]!['basic_info']!,
              Icons.info,
              [
                _infoRow(labels[_selectedLanguage]!['name']!, user.name),
                _infoRow(labels[_selectedLanguage]!['age']!, user.age),
                _infoRow(labels[_selectedLanguage]!['dob']!, user.dob),
                _infoRow(
                  labels[_selectedLanguage]!['contact']!,
                  user.contactNo,
                ),
                _infoRow(labels[_selectedLanguage]!['email']!, user.emailId),
              ],
            ),

            //Family Info card
            _buildInfoCard(
              labels[_selectedLanguage]!['family_info']!,
              Icons.family_restroom,
              [
                _infoRow(
                  labels[_selectedLanguage]!['father_name']!,
                  user.fatherName,
                ),
                _infoRow(
                  labels[_selectedLanguage]!['mother_name']!,
                  user.motherName,
                ),
                _infoRow(
                  labels[_selectedLanguage]!['siblings']!,
                  user.siblings,
                ),
                _infoRow(
                  labels[_selectedLanguage]!['native_place']!,
                  user.nativePlace,
                ),
                _infoRow(
                  labels[_selectedLanguage]!['mother_tongue']!,
                  user.motherTongue,
                ),
                _infoRow(labels[_selectedLanguage]!['diet']!, user.diet),
              ],
            ),

            _buildInfoCard(
              labels[_selectedLanguage]!['physical_lifestyle']!,
              Icons.accessibility_new,
              [
                _infoRow(
                  labels[_selectedLanguage]!['marital_status']!,
                  user.maritalStatus,
                ),
                _infoRow(
                  labels[_selectedLanguage]!['physical_status']!,
                  user.physicalStatus,
                ),
                _infoRow(labels[_selectedLanguage]!['height']!, user.height),
                _infoRow(labels[_selectedLanguage]!['weight']!, user.weight),
                _infoRow(
                  labels[_selectedLanguage]!['skin_color']!,
                  user.skinColor,
                ),
                _infoRow(
                  labels[_selectedLanguage]!['financial_status']!,
                  user.financialStatus,
                ),
                _infoRow(labels[_selectedLanguage]!['hobbies']!, user.hobbies),
                _infoRow(
                  labels[_selectedLanguage]!['interest']!,
                  user.interests,
                ),
              ],
            ),

            _buildInfoCard(labels[_selectedLanguage]!['address']!, Icons.home, [
              _infoRow(labels[_selectedLanguage]!['district']!, user.district),
              _infoRow(
                labels[_selectedLanguage]!['street']!,
                user.addressLane1,
              ),
              _infoRow(
                labels[_selectedLanguage]!['landmark']!,
                user.addressLane2,
              ),
              _infoRow(labels[_selectedLanguage]!['pincode']!, user.pincode),
            ]),

            _buildInfoCard(
              labels[_selectedLanguage]!['religion_bg']!,
              Icons.temple_hindu,
              [
                _infoRow(
                  labels[_selectedLanguage]!['religion']!,
                  user.religion,
                ),
                _infoRow(labels[_selectedLanguage]!['caste']!, user.caste),
                _infoRow(
                  labels[_selectedLanguage]!['sub_caste']!,
                  user.subCaste,
                ),
                _infoRow(
                  labels[_selectedLanguage]!['inter_caste']!,
                  user.interCaste,
                ),
                _infoRow(labels[_selectedLanguage]!['dosham']!, user.dosham),
              ],
            ),

            _buildInfoCard(
              labels[_selectedLanguage]!['education_career']!,
              Icons.school,
              [
                _infoRow(
                  labels[_selectedLanguage]!['higher_education']!,
                  user.higherEducation,
                ),
                _infoRow(
                  labels[_selectedLanguage]!['employed_in']!,
                  user.employeeIn,
                ),
                _infoRow(
                  labels[_selectedLanguage]!['occupation']!,
                  user.occupation,
                ),
                _infoRow(
                  labels[_selectedLanguage]!['annual_income']!,
                  user.annualIncome,
                ),
              ],
            ),

            _buildInfoCard(
              labels[_selectedLanguage]!['location']!,
              Icons.location_on,
              [
                _infoRow(
                  labels[_selectedLanguage]!['work_location']!,
                  user.workLocation,
                ),
                _infoRow(labels[_selectedLanguage]!['state']!, user.state),
                _infoRow(labels[_selectedLanguage]!['city']!, user.city),
              ],
            ),

            _buildInfoCard(
              labels[_selectedLanguage]!['kyc_documents']!,
              Icons.picture_as_pdf,
              [
                _documentRow(
                  labels[_selectedLanguage]!['aadhar']!,
                  user.aadharImgPath,
                ),
                _documentRow(
                  labels[_selectedLanguage]!['community_certificate']!,
                  user.communityCertificatePath,
                ),
                _documentRow(
                  labels[_selectedLanguage]!['jathakam']!,
                  user.jathakamPath,
                ),
              ],
            ),

            _buildInfoCard(
              labels[_selectedLanguage]!['about']!,
              Icons.favorite,
              [
                _infoRow(
                  labels[_selectedLanguage]!['about_yourself']!,
                  user.aboutYourself,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Info Card
  Widget _buildInfoCard(String title, IconData icon, List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.pinkAccent, Colors.pink],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  // ✅ Info Row
  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              (value != null &&
                      value.isNotEmpty &&
                      value.toLowerCase() != "null")
                  ? value
                  : "-",
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  //Document Row
  Widget _documentRow(String label, String? url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child:
                url != null && url.isNotEmpty
                    ? InkWell(
                      onTap: () async {
                        // open PDF link in browser
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(
                            Uri.parse(url),
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                      child: Row(
                        children: const [
                          Icon(Icons.picture_as_pdf, color: Colors.redAccent),
                          SizedBox(width: 6),
                          Text(
                            "View Document",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    )
                    : const Text("-", style: TextStyle(color: Colors.black54)),
          ),
        ],
      ),
    );
  }
}

//Lables

Map<String, Map<String, String>> labels = {
  'en': {
    'basic_info': "Basic Information",
    'name': "Name",
    'age': "Age",
    'dob': "Date of Birth",
    'contact': "Contact",
    'email': "Email",
    'physical_lifestyle': "Physical & Lifestyle",
    'marital_status': "Marital Status",
    'physical_status': "Physical Status",
    'height': "Height",
    'weight': "Weight",
    'skin_color': "Skin Color",
    'financial_status': "Financial Status",
    'address': "Address",
    'district': "District",
    'street': "Street / House / Flat",
    'landmark': "Landmark / Locality",
    'pincode': "Pincode",
    'religion_bg': "Religious Background",
    'religion': "Religion",
    'caste': "Caste",
    'sub_caste': "Sub Caste",
    'inter_caste': "Inter Caste",
    'dosham': "Dosham",
    'education_career': "Education & Career",
    'higher_education': "Higher Education",
    'employed_in': "Employed In",
    'occupation': "Occupation",
    'annual_income': "Annual Income",
    'location': "Location",
    'work_location': "Work Location",
    'state': "State",
    'city': "City",
    'kyc_documents': "KYC Documents",
    'aadhar': "Aadhar",
    'community_certificate': "Community Certificate",
    'jathakam': "Jathakam",
    'about': "About",
    'about_yourself': "About Yourself",
    'user_code': "User Code",
    'activate': "Activate",
    'deactivate': "Deactivate",
    'family_info': "Family Information",
    'father_name': "Father's Name",
    'mother_name': "Mother's Name",
    'siblings': "Siblings",
    'native_place': "Native Place",
    'mother_tongue': "Mother Tongue",
    'diet': "Diet",
    'hobbies': "Hobbies",
    'interest': "Interests",
  },
  'ta': {
    'basic_info': "அடிப்படை தகவல்",
    'name': "பெயர்",
    'age': "வயது",
    'dob': "பிறந்த தேதி",
    'contact': "தொடர்பு",
    'email': "மின்னஞ்சல்",
    'physical_lifestyle': "உடல் மற்றும் வாழ்க்கை முறை",
    'marital_status': "திருமண நிலை",
    'physical_status': "உடல் நிலை",
    'height': "உயரம்",
    'weight': "எடை",
    'skin_color': "தோல் நிறம்",
    'financial_status': "பொருளாதார நிலை",
    'address': "முகவரி",
    'district': "மாவட்டம்",
    'street': "வீடு / தெரு / அட்டை",
    'landmark': "அடையாளம் / பகுதி",
    'pincode': "பின் குறியீடு",
    'religion_bg': "மத பின்னணி",
    'religion': "மதம்",
    'caste': "சாதி",
    'sub_caste': "துணை சாதி",
    'inter_caste': "இணை சாதி",
    'dosham': "தோஷம்",
    'education_career': "கல்வி மற்றும் தொழில்",
    'higher_education': "உயர் கல்வி",
    'employed_in': "வேலை செய்யும் இடம்",
    'occupation': "வேலை",
    'annual_income': "வருமானம்",
    'location': "இடம்",
    'work_location': "வேலை இடம்",
    'state': "மாநிலம்",
    'city': "நகரம்",
    'kyc_documents': "பரிசோதனை ஆவணங்கள்",
    'aadhar': "ஆதார்",
    'community_certificate': "சமூக சான்றிதழ்",
    'jathakam': "ஜாதகம்",
    'about': "உங்களைப் பற்றி",
    'about_yourself': "உங்களைப் பற்றி",
    'user_code': "பயனர் குறியீடு",
    'activate': "செயல்படுத்தவும்",
    'deactivate': "செயலிழக்க செய்யவும்",
    'family_info': "குடும்ப தகவல்",
    'father_name': "தந்தையின் பெயர்",
    'mother_name': "தாயின் பெயர்",
    'siblings': "சகோதரர் / சகோதரி",
    'native_place': "பூர்வீக இடம்",
    'mother_tongue': "தாய்மொழி",
    'diet': "உணவு பழக்கம்",
    'hobbies': "பொழுதுபோக்கு",
    'interest': "ஆர்வங்கள்",
  },
};

//Appbar
Map<String, String> appBarTitles = {
  'en': "Personal Information",
  'ta': "தனிப்பட்ட தகவல்கள்", // Tamil translation
};
