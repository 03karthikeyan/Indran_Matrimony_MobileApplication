import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FamilyDetailsUpdateScreen extends StatefulWidget {
  final String userId;
  const FamilyDetailsUpdateScreen({super.key, required this.userId});

  @override
  State<FamilyDetailsUpdateScreen> createState() =>
      _FamilyDetailsUpdateScreenState();
}

class _FamilyDetailsUpdateScreenState extends State<FamilyDetailsUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController fatherController = TextEditingController();
  final TextEditingController motherController = TextEditingController();
  final TextEditingController siblingsController = TextEditingController();
  final TextEditingController nativePlaceController = TextEditingController();
  final TextEditingController hobbiesController = TextEditingController();
  final TextEditingController interestsController = TextEditingController();

  String? selectedMotherTongue;
  String? selectedDiet;
  bool isLoading = false;

  final List<String> motherTongueList = [
    'Tamil',
    'Telugu',
    'Malayalam',
    'Kannada',
    'Hindi',
    'English',
  ];

  final List<String> dietList = [
    'Vegetarian',
    'Non-Vegetarian',
    'Eggetarian',
    'Vegan',
  ];

  Future<void> updateFamilyDetails() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      // ✅ Build full GET URL with parameters
      final url = Uri.parse(
        "https://pheonixconstructions.com/Matrimony API/profile_update.php"
        "?user_id=${widget.userId}"
        "&father_name=${Uri.encodeComponent(fatherController.text)}"
        "&mother_name=${Uri.encodeComponent(motherController.text)}"
        "&siblings=${Uri.encodeComponent(siblingsController.text)}"
        "&native_place=${Uri.encodeComponent(nativePlaceController.text)}"
        "&mother_tongue=${Uri.encodeComponent(selectedMotherTongue ?? '')}"
        "&hobbies=${Uri.encodeComponent(hobbiesController.text)}"
        "&interests=${Uri.encodeComponent(interestsController.text)}"
        "&diet=${Uri.encodeComponent(selectedDiet ?? '')}",
      );

      final response = await http.get(url);

      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Family details updated successfully!'),
            ),
          );
          Navigator.pop(context, true); // return success to previous screen
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Update failed')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Server error. Please try again later.'),
          ),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('⚠️ Something went wrong: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final pink = const Color(0xFFA51C48);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: pink,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Add Family Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildTextField('Father Name', fatherController),
              buildTextField('Mother Name', motherController),
              buildTextField('Siblings', siblingsController),
              buildTextField('Native Place', nativePlaceController),
              buildDropdownField('Mother Tongue', motherTongueList, (val) {
                setState(() => selectedMotherTongue = val);
              }, selectedMotherTongue),
              buildDropdownField('Diet', dietList, (val) {
                setState(() => selectedDiet = val);
              }, selectedDiet),
              buildTextField('Hobbies', hobbiesController),
              buildTextField('Interests', interestsController),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isLoading ? null : updateFamilyDetails,
                child:
                    isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          'Update Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator:
            (value) => value == null || value.isEmpty ? 'Enter $label' : null,
      ),
    );
  }

  Widget buildDropdownField(
    String label,
    List<String> items,
    Function(String?) onChanged,
    String? selectedValue,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        value: selectedValue,
        items:
            items.map((lang) {
              return DropdownMenuItem(value: lang, child: Text(lang));
            }).toList(),
        onChanged: onChanged,
        validator:
            (value) => value == null || value.isEmpty ? 'Select $label' : null,
      ),
    );
  }
}
