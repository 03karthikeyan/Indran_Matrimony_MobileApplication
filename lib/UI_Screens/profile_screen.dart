import 'dart:io';
import 'package:flutter/material.dart';
import 'package:matrimony/UI_Screens/EditProfileScreen.dart';
import 'package:matrimony/UI_Screens/Personal_Imformation.dart';
import 'package:matrimony/UI_Screens/interests_received_screen.dart';
import 'package:matrimony/UI_Screens/login_screen.dart';
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

  void _showStatusConfirmDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // localLoading is local to the sheet so we can rebuild the sheet while the API runs
        bool localLoading = false;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isActive ? Icons.visibility_off : Icons.visibility,
                    size: 40,
                    color: isActive ? Colors.red : Colors.green,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isActive ? "Deactivate Profile?" : "Activate Profile?",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Are you sure you want to ${isActive ? "deactivate" : "activate"} your profile?",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed:
                              localLoading
                                  ? null
                                  : () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isActive ? Colors.red : Colors.green,
                          ),
                          onPressed:
                              localLoading
                                  ? null
                                  : () async {
                                    setModalState(() => localLoading = true);

                                    try {
                                      // call proper API based on current status
                                      final response =
                                          isActive
                                              ? await ApiService.deactivateUser(
                                                widget.userId,
                                              )
                                              : await ApiService.activateUser(
                                                widget.userId,
                                              );

                                      // refresh profile from server (authoritative source)
                                      if (response['success'] == true) {
                                        await fetchProfile();
                                        // show server message
                                        _showAlertDialog(
                                          "Success",
                                          response['message'] ?? "Updated",
                                          Colors.green,
                                        );
                                      } else {
                                        _showAlertDialog(
                                          "Error",
                                          response['message'] ?? "Failed",
                                          Colors.red,
                                        );
                                      }
                                    } catch (e) {
                                      _showAlertDialog(
                                        "Error",
                                        "Network error: $e",
                                        Colors.red,
                                      );
                                    } finally {
                                      // close sheet after short delay to show success (optional)
                                      setModalState(() => localLoading = false);
                                      if (mounted) Navigator.pop(context);
                                    }
                                  },
                          child:
                              localLoading
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                  : Text(isActive ? "Deactivate" : "Activate"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> toggleUserStatus() async {
    try {
      final response =
          isActive
              ? await ApiService.deactivateUser(widget.userId)
              : await ApiService.activateUser(widget.userId);

      if (response["success"] == true) {
        setState(() {
          isActive = !isActive;
        });

        _showAlertDialog(
          "Success",
          response["message"] ?? "Status updated successfully",
          Colors.green,
        );
      } else {
        _showAlertDialog(
          "Error",
          response["message"] ?? "Something went wrong",
          Colors.red,
        );
      }
    } catch (e) {
      _showAlertDialog("Error", "Failed: $e", Colors.red);
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

  @override
  Widget build(BuildContext context) {
    final pinkColor = const Color(0xFFA51C48);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child:
        // isLoading
        //     ? const Center(child: CircularProgressIndicator())
        //     :
        SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.only(
                  top: 44,
                  left: 18,
                  right: 18,
                  bottom: 20,
                ),
                decoration: BoxDecoration(
                  color: pinkColor,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text(
                          'My Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (isSubscribed)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "Premium",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: () async {
                            if (userData != null) {
                              final updated = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => EditProfileScreen(
                                        userId: widget.userId,
                                        profileData: userData!,
                                      ),
                                ),
                              );
                              if (updated == true) fetchProfile();
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              (userData?['profile_img'] != null &&
                                      userData!['profile_img']
                                          .toString()
                                          .isNotEmpty)
                                  ? NetworkImage(userData!['profile_img'])
                                  : const AssetImage('assets/Ellipse222(1).png')
                                      as ImageProvider,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 4,
                          child: GestureDetector(
                            onTap:
                                _pickAndUploadImage, // 👈 method to pick and upload new image
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    Text(
                      userData?['name'] ?? "Unknown User",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSubscribed ? Icons.verified : Icons.lock_open,
                          size: 16,
                          color: isSubscribed ? Colors.green : Colors.white70,
                        ),

                        const SizedBox(width: 4),
                        Text(
                          isSubscribed ? 'Premium Member' : 'Free Member',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (!isSubscribed)
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
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "Upgrade",
                                style: TextStyle(
                                  color: pinkColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
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
                        const Text(
                          "Profile Completion",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "${userData?['completion'] ?? '80'}%",
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
                      value: ((userData?['completion'] ?? 80) / 100).toDouble(),
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
                title: 'Personal Details',
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
                title: 'Interests Received',
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const InterestsReceivedScreen(),
                      ),
                    ),
              ),
              // _MenuItem(
              //   icon: Icons.history,
              //   title: 'Profile Insights',
              //   onTap:
              //       () => Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //           builder: (_) => const ProfileInsightsScreen(),
              //         ),
              //       ),
              // ),
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
                title: 'Subscription',
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
                title: 'Privacy Settings',
                onTap: () {},
              ),
              _MenuItem(
                icon: Icons.help,
                title: 'Help & Support',
                onTap: () {},
              ),

              _MenuItem(
                icon: Icons.logout,
                title: 'Logout',
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
