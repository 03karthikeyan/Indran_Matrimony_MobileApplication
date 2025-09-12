import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  late TextEditingController _contactController;
  late TextEditingController _ageController;
  late TextEditingController _dobController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _occupationController;
  late TextEditingController _incomeController;
  late TextEditingController _educationController;
  late TextEditingController _aboutController;
  late TextEditingController _workLocationController;

  String? _gender;
  String? _religion;
  String? _caste;
  String? _subCaste;
  String? _dosham;
  String? _interCaste;

  XFile? _profileImage;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    final data = widget.profileData;

    _nameController = TextEditingController(text: data['name'] ?? "");
    _emailController = TextEditingController(text: data['email_id'] ?? "");
    _contactController = TextEditingController(text: data['contact_no'] ?? "");
    _ageController = TextEditingController(text: data['age']?.toString() ?? "");
    _dobController = TextEditingController(text: data['dob'] ?? "");
    _cityController = TextEditingController(text: data['city'] ?? "");
    _stateController = TextEditingController(text: data['state'] ?? "");
    _occupationController = TextEditingController(
      text: data['occupation'] ?? "",
    );
    _incomeController = TextEditingController(
      text: data['annual_income'] ?? "",
    );
    _educationController = TextEditingController(
      text: data['higher_education'] ?? "",
    );
    _aboutController = TextEditingController(
      text: data['about_yourself'] ?? "",
    );
    _workLocationController = TextEditingController(
      text: data['work_location'] ?? "",
    );

    _gender = data['gender'];
    _religion = data['religion'];
    _caste = data['caste'];
    _subCaste = data['sub_caste'];
    _dosham = data['dosham'];
    _interCaste = data['inter_caste'];
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _profileImage = image);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    // Print all the values to the terminal/logs
    print("Saving Profile Data:");
    print("User ID: ${widget.userId}");
    print("Name: ${_nameController.text.trim()}");
    print("Email: ${_emailController.text.trim()}");
    print("Contact: ${_contactController.text.trim()}");
    print("Age: ${_ageController.text.trim()}");
    print("DOB: ${_dobController.text.trim()}");
    print("City: ${_cityController.text.trim()}");
    print("State: ${_stateController.text.trim()}");
    print("Occupation: ${_occupationController.text.trim()}");
    print("Annual Income: ${_incomeController.text.trim()}");
    print("Education: ${_educationController.text.trim()}");
    print("Work Location: ${_workLocationController.text.trim()}");
    print("About: ${_aboutController.text.trim()}");
    print("Gender: $_gender");
    print("Religion: $_religion");
    print("Caste: $_caste");
    print("Sub-Caste: $_subCaste");
    print("Dosham: $_dosham");
    print("Inter Caste: $_interCaste");
    print("Profile Image Path: ${_profileImage?.path}");

    final url = Uri.parse(
      "https://pheonixconstructions.com/Matrimony API/profile_update.php"
      "?user_id=${widget.userId}"
      "&name=${_nameController.text.trim()}"
      "&email_id=${_emailController.text.trim()}"
      "&contact_no=${_contactController.text.trim()}"
      "&age=${_ageController.text.trim()}"
      "&dob=${_dobController.text.trim()}"
      "&city=${_cityController.text.trim()}"
      "&state=${_stateController.text.trim()}"
      "&occupation=${_occupationController.text.trim()}"
      "&annual_income=${_incomeController.text.trim()}"
      "&higher_education=${_educationController.text.trim()}"
      "&work_location=${_workLocationController.text.trim()}"
      "&about_yourself=${_aboutController.text.trim()}"
      "&gender=$_gender"
      "&religion=$_religion"
      "&caste=$_caste"
      "&sub_caste=$_subCaste"
      "&dosham=$_dosham"
      "&inter_caste=$_interCaste",
    );

    try {
      final response = await http.get(url);
      setState(() => isSaving = false);

      print("API Response: ${response.body}"); // print API response

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["status"] == "success") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile updated successfully!")),
          );
          Navigator.pop(context, true); // refresh profile
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
      print("Error saving profile: $e"); // print error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final pinkColor = const Color(0xFFA51C48);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: pinkColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Edit Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Image
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        _profileImage != null
                            ? FileImage(File(_profileImage!.path))
                            : NetworkImage(
                                  widget.profileData['profile_img'] ?? "",
                                )
                                as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 15,
                        backgroundColor: pinkColor,
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _buildTextField("Full Name", _nameController),
              const SizedBox(height: 12),
              _buildTextField(
                "Email",
                _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                "Contact No",
                _contactController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                "Age",
                _ageController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                "DOB",
                _dobController,
                readOnly: true,
                onTap: _pickDate,
              ),
              const SizedBox(height: 12),
              _buildDropdown(
                "Gender",
                ["Male", "Female"],
                _gender,
                (v) => setState(() => _gender = v),
              ),
              const SizedBox(height: 12),
              _buildDropdown(
                "Religion",
                ["Hindu", "Muslim", "Christian"],
                _religion,
                (v) => setState(() => _religion = v),
              ),
              const SizedBox(height: 12),
              _buildTextField(
                "Caste",
                TextEditingController(text: _caste),
                readOnly: true,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                "Sub-Caste",
                TextEditingController(text: _subCaste),
                readOnly: true,
              ),
              const SizedBox(height: 12),
              _buildTextField("Education", _educationController),
              const SizedBox(height: 12),
              _buildTextField("Occupation", _occupationController),
              const SizedBox(height: 12),
              _buildTextField(
                "Annual Income",
                _incomeController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              _buildTextField("Work Location", _workLocationController),
              const SizedBox(height: 12),
              _buildTextField("About Yourself", _aboutController, maxLines: 4),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity, // makes the button full-width
                child: ElevatedButton(
                  onPressed: isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: pinkColor,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                    ), // slightly taller
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      isSaving
                          ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                          : const Text(
                            "Save Changes",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
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
    bool readOnly = false,
    int maxLines = 1,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      maxLines: maxLines,
      onTap: onTap,
      validator:
          (value) =>
              (value == null || value.trim().isEmpty)
                  ? "$label cannot be empty"
                  : null,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> options,
    String? selectedValue,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      items:
          options
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (v) => v == null || v.isEmpty ? "Please select $label" : null,
    );
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_dobController.text) ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _dobController.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }
}
