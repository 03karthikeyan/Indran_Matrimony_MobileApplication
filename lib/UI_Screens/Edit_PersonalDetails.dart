import 'package:flutter/material.dart';
import 'package:matrimony/models/user_data.dart';
import 'package:matrimony/services/api_service.dart';

class EditPersonalDetailsScreen extends StatefulWidget {
  final UserData user;

  const EditPersonalDetailsScreen({super.key, required this.user});

  @override
  State<EditPersonalDetailsScreen> createState() =>
      _EditPersonalDetailsScreenState();
}

class _EditPersonalDetailsScreenState extends State<EditPersonalDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late UserData _editedUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _editedUser = widget.user; // Create a copy for editing
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.updateProfile(_editedUser);

      print("API Response: $response");

      if (response['status'] == 'success') {
        // Fetch the updated user profile
        final updatedUser = await ApiService.getProfiles(_editedUser.userId!);

        // Show success snackbar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Profile updated successfully!"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }

        // Navigate back to PersonalDetailsScreen with updated user data
        if (mounted) {
          Navigator.pop(context, updatedUser);
        }
      } else {
        final message = response['message'] ?? "Failed to update profile";
        print("Profile update failed ❌: $message");

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e, stack) {
      print("Error saving profile: $e");
      print(stack);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pink = const Color(0xFFA51C48);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            backgroundColor: pink,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
              "Edit Profile",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // ------------------ Basic Info ------------------
                  _buildSectionCard("Basic Information", [
                    _buildTextField(
                      label: "Name",
                      initialValue: _editedUser.name,
                      onSaved: (val) => _editedUser.name = val ?? "",
                      validator:
                          (val) =>
                              (val == null || val.isEmpty) ? "Required" : null,
                    ),
                    _buildTextField(
                      label: "Age",
                      initialValue: _editedUser.age,
                      keyboardType: TextInputType.number,
                      onSaved: (val) => _editedUser.age = val ?? "",
                    ),
                    _buildTextField(
                      label: "Email",
                      initialValue: _editedUser.emailId,
                      keyboardType: TextInputType.emailAddress,
                      onSaved: (val) => _editedUser.emailId = val ?? "",
                    ),
                    _buildTextField(
                      label: "Contact",
                      initialValue: _editedUser.contactNo,
                      keyboardType: TextInputType.phone,
                      onSaved: (val) => _editedUser.contactNo = val ?? "",
                    ),
                  ]),

                  // ------------------ Family Info ------------------
                  _buildSectionCard("Family Information", [
                    _buildTextField(
                      label: "Father_Name",
                      initialValue: _editedUser.fatherName,
                      onSaved: (val) => _editedUser.fatherName = val ?? "",
                      validator:
                          (val) =>
                              (val == null || val.isEmpty) ? "Required" : null,
                    ),
                    _buildTextField(
                      label: "Mother_Name",
                      initialValue: _editedUser.motherName,
                      onSaved: (val) => _editedUser.motherName = val ?? "",
                      validator:
                          (val) =>
                              (val == null || val.isEmpty) ? "Required" : null,
                    ),
                    _buildTextField(
                      label: "Siblings",
                      initialValue: _editedUser.siblings,
                      onSaved: (val) => _editedUser.siblings = val ?? "",
                      validator:
                          (val) =>
                              (val == null || val.isEmpty) ? "Required" : null,
                    ),
                    _buildTextField(
                      label: "Native_Place",
                      initialValue: _editedUser.nativePlace,
                      onSaved: (val) => _editedUser.nativePlace = val ?? "",
                      validator:
                          (val) =>
                              (val == null || val.isEmpty) ? "Required" : null,
                    ),
                    _buildTextField(
                      label: "Mother_Tongue",
                      initialValue: _editedUser.motherTongue,
                      onSaved: (val) => _editedUser.motherTongue = val ?? "",
                      validator:
                          (val) =>
                              (val == null || val.isEmpty) ? "Required" : null,
                    ),
                    _buildTextField(
                      label: "Diet",
                      initialValue: _editedUser.diet,
                      onSaved: (val) => _editedUser.diet = val ?? "",
                      validator:
                          (val) =>
                              (val == null || val.isEmpty) ? "Required" : null,
                    ),
                  ]),

                  // ------------------ Physical & Lifestyle ------------------
                  _buildSectionCard("Physical & Lifestyle", [
                    _buildTextField(
                      label: "Height",
                      initialValue: _editedUser.height,
                      onSaved: (val) => _editedUser.height = val ?? "",
                    ),
                    _buildTextField(
                      label: "Weight",
                      initialValue: _editedUser.weight,
                      onSaved: (val) => _editedUser.weight = val ?? "",
                    ),
                    _buildTextField(
                      label: "Marital Status",
                      initialValue: _editedUser.maritalStatus,
                      onSaved: (val) => _editedUser.maritalStatus = val ?? "",
                    ),
                    _buildTextField(
                      label: "Physical Status",
                      initialValue: _editedUser.physicalStatus,
                      onSaved: (val) => _editedUser.physicalStatus = val ?? "",
                    ),
                     _buildTextField(
                      label: "Hobbies",
                      initialValue: _editedUser.hobbies,
                      onSaved: (val) => _editedUser.hobbies = val ?? "",
                    ),
                     _buildTextField(
                      label: "Interests",
                      initialValue: _editedUser.interests,
                      onSaved: (val) => _editedUser.interests = val ?? "",
                    ),
                  ]),

                  // ------------------ Address ------------------
                  _buildSectionCard("Address", [
                    _buildTextField(
                      label: "Street / House / Flat",
                      initialValue: _editedUser.addressLane1,
                      onSaved: (val) => _editedUser.addressLane1 = val ?? "",
                    ),
                    _buildTextField(
                      label: "Landmark / Locality",
                      initialValue: _editedUser.addressLane2,
                      onSaved: (val) => _editedUser.addressLane2 = val ?? "",
                    ),
                    _buildTextField(
                      label: "City",
                      initialValue: _editedUser.city,
                      onSaved: (val) => _editedUser.city = val ?? "",
                    ),
                    _buildTextField(
                      label: "State",
                      initialValue: _editedUser.state,
                      onSaved: (val) => _editedUser.state = val ?? "",
                    ),
                    _buildTextField(
                      label: "Pincode",
                      initialValue: _editedUser.pincode,
                      onSaved: (val) => _editedUser.pincode = val ?? "",
                    ),
                  ]),

                  // ------------------ Religious Background ------------------
                  _buildSectionCard("Religious Background", [
                    _buildTextField(
                      label: "Religion",
                      initialValue: _editedUser.religion,
                      onSaved: (val) => _editedUser.religion = val ?? "",
                    ),
                    _buildTextField(
                      label: "Caste",
                      initialValue: _editedUser.caste,
                      onSaved: (val) => _editedUser.caste = val ?? "",
                    ),
                    _buildTextField(
                      label: "Sub Caste",
                      initialValue: _editedUser.subCaste,
                      onSaved: (val) => _editedUser.subCaste = val ?? "",
                    ),
                    _buildTextField(
                      label: "Inter Caste",
                      initialValue: _editedUser.interCaste,
                      onSaved: (val) => _editedUser.interCaste = val ?? "",
                    ),
                    _buildTextField(
                      label: "Dosham",
                      initialValue: _editedUser.dosham,
                      onSaved: (val) => _editedUser.dosham = val ?? "",
                    ),
                  ]),

                  // ------------------ Education & Career ------------------
                  _buildSectionCard("Education & Career", [
                    _buildTextField(
                      label: "Higher Education",
                      initialValue: _editedUser.higherEducation,
                      onSaved: (val) => _editedUser.higherEducation = val ?? "",
                    ),
                    _buildTextField(
                      label: "Employee In",
                      initialValue: _editedUser.employeeIn,
                      onSaved: (val) => _editedUser.employeeIn = val ?? "",
                    ),
                    _buildTextField(
                      label: "Occupation",
                      initialValue: _editedUser.occupation,
                      onSaved: (val) => _editedUser.occupation = val ?? "",
                    ),
                    _buildTextField(
                      label: "Annual Income",
                      initialValue: _editedUser.annualIncome,
                      onSaved: (val) => _editedUser.annualIncome = val ?? "",
                    ),
                    _buildTextField(
                      label: "Work Location",
                      initialValue: _editedUser.workLocation,
                      onSaved: (val) => _editedUser.workLocation = val ?? "",
                    ),
                  ]),

                  _buildSectionCard("Location", [
                    _buildTextField(
                      label: "District",
                      initialValue: _editedUser.district,
                      onSaved: (val) => _editedUser.district = val ?? "",
                    ),
                    _buildTextField(
                      label: "State",
                      initialValue: _editedUser.state,
                      onSaved: (val) => _editedUser.state = val ?? "",
                    ),
                    _buildTextField(
                      label: "City",
                      initialValue: _editedUser.city,
                      onSaved: (val) => _editedUser.city = val ?? "",
                    ),
                    _buildTextField(
                      label: "Pincode",
                      initialValue: _editedUser.pincode,
                      onSaved: (val) => _editedUser.pincode = val ?? "",
                    ),
                  ]),

                  // ------------------ About Yourself ------------------
                  _buildSectionCard("About Yourself", [
                    _buildTextField(
                      label: "About Yourself",
                      initialValue: _editedUser.aboutYourself,
                      onSaved: (val) => _editedUser.aboutYourself = val ?? "",
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                    ),
                  ]),

                  const SizedBox(height: 20),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: pink,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Save Changes",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black45,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    String? initialValue,
    TextInputType keyboardType = TextInputType.text,
    required FormFieldSetter<String> onSaved,
    FormFieldValidator<String>? validator,
    int? maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        initialValue: initialValue,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onSaved: onSaved,
        validator: validator,
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.pinkAccent,
              ),
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }
}
