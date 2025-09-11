import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:matrimony/UI_Screens/EditProfileScreen.dart';
import 'dart:convert';
import 'package:matrimony/models/user_data.dart';
import 'package:matrimony/services/api_service.dart';

class PersonalDetailsScreen extends StatefulWidget {
  final UserData user;

  const PersonalDetailsScreen({super.key, required this.user});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  late bool isActive;

  @override
  void initState() {
    super.initState();
    // user_sts: "0" → active, "1" → deactivated
    isActive = widget.user.isActive ?? true;
  }

  Future<void> _toggleUserStatus() async {
    if (widget.user.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid user ID"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Map<String, dynamic> response;

    try {
      if (isActive) {
        response = await ApiService.deactivateUser(widget.user.userId!);
      } else {
        response = await ApiService.activateUser(widget.user.userId!);
      }

      if (response['success'] == true) {
        setState(() {
          // update local and model
          isActive = !isActive;
          widget.user.isActive = isActive;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['message'] ??
                  (isActive
                      ? "Profile activated successfully"
                      : "Profile deactivated successfully"),
            ),
            backgroundColor: Colors.green,
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

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        backgroundColor: Colors.pinkAccent,
        title: const Text(
          "Personal Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
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

                    const SizedBox(height: 16),

                    // ✅ Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                       

                        // const SizedBox(width: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isActive ? Colors.redAccent : Colors.green,
                          ),
                          onPressed: _toggleUserStatus,
                          icon: Icon(
                            isActive ? Icons.block : Icons.check_circle,
                            color: Colors.white,
                          ),
                          label: Text(
                            isActive ? "Deactivate" : "Activate",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ✅ Your Info Cards (unchanged)
            _buildInfoCard("Basic Information", Icons.info, [
              _infoRow("Name", user.name),
              _infoRow("Age", user.age),
              _infoRow("Date of Birth", user.dob),
              _infoRow("Contact", user.contactNo),
              _infoRow("Email", user.emailId),
            ]),

            _buildInfoCard("Religious Background", Icons.temple_hindu, [
              _infoRow("Religion", user.religion),
              _infoRow("Caste", user.caste),
              _infoRow("Sub Caste", user.subCaste),
              _infoRow("Inter Caste", user.interCaste),
              _infoRow("Dosham", user.dosham),
            ]),

            _buildInfoCard("Education & Career", Icons.school, [
              _infoRow("Higher Education", user.higherEducation),
              _infoRow("Employed In", user.employeeIn),
              _infoRow("Occupation", user.occupation),
              _infoRow("Annual Income", user.annualIncome),
            ]),

            _buildInfoCard("Location", Icons.location_on, [
              _infoRow("Work Location", user.workLocation),
              _infoRow("State", user.state),
              _infoRow("City", user.city),
            ]),

            _buildInfoCard("About", Icons.favorite, [
              _infoRow("About Yourself", user.aboutYourself),
            ]),
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
}
