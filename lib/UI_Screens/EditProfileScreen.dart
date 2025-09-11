import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditProfileScreen extends StatefulWidget {
  final int userId;
  final Map<String, dynamic> profileData;

  const EditProfileScreen({
    Key? key,
    required this.userId,
    required this.profileData,
  }) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _cityController;
  late TextEditingController _ageController;

  bool isSaving = false;

  final RegExp nameRegExp = RegExp(r"^[a-zA-Z\s]+$");
  final RegExp emailRegExp = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.profileData['name'] ?? "",
    );
    _emailController = TextEditingController(
      text: widget.profileData['email_id'] ?? "",
    );
    _cityController = TextEditingController(
      text: widget.profileData['city'] ?? "",
    );
    _ageController = TextEditingController(
      text: widget.profileData['age']?.toString() ?? "",
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    // ✅ Construct query parameters
    final url = Uri.parse(
      "https://pheonixconstructions.com/Matrimony API/profile_update.php"
      "?user_id=${widget.userId}"
      "&name=${_nameController.text.trim()}"
      "&email_id=${_emailController.text.trim()}"
      "&city=${_cityController.text.trim()}"
      "&age=${_ageController.text.trim()}",
    );

    try {
      final response = await http.get(url);

      setState(() => isSaving = false);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["status"] == "success") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile updated successfully!")),
          );
          Navigator.pop(context, true); // return true to refresh profile
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data["message"] ?? "Update failed")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Server error. Please try again.")),
        );
      }
    } catch (e) {
      setState(() => isSaving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final pinkColor = const Color(0xFFA51C48);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // Set your desired color here
        ),
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: pinkColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField("Full Name", _nameController),
              const SizedBox(height: 12),
              _buildTextField(
                "Email",
                _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              _buildTextField("City", _cityController),
              const SizedBox(height: 12),
              _buildTextField(
                "Age",
                _ageController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: pinkColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          "Save Changes",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "$label cannot be empty";
        }

        // ✅ Name validation
        if (label == "Full Name" && !nameRegExp.hasMatch(value.trim())) {
          return "Name can only contain alphabets and spaces";
        }

        // ✅ Email validation
        if (label == "Email" && !emailRegExp.hasMatch(value.trim())) {
          return "Enter a valid email address";
        }

        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
