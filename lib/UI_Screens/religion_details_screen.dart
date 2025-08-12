import 'package:flutter/material.dart';
import 'package:matrimony/UI_Screens/professional_details_screen.dart';
import 'package:matrimony/services/api_service.dart';
import '../models/user_data.dart';

class ReligionDetailsScreen extends StatefulWidget {
  final UserData userData;
  const ReligionDetailsScreen({super.key, required this.userData});

  @override
  State<ReligionDetailsScreen> createState() => _ReligionDetailsScreenState();
}

class _ReligionDetailsScreenState extends State<ReligionDetailsScreen> {
  String? religion = 'Hindu';
  bool willingToMarryOtherCaste = false;
  String? caste;
  String? subCaste;
  String? dosham;
  final casteOptions = ['Brahmin', 'Chettiar', 'Nadar', 'Vanniyar', 'Other'];
  final subCasteOptions = ['Subcaste1', 'Subcaste2', 'Subcaste3'];
  // final religionOptions = ['Hindu', 'Muslim', 'Christian', 'Other'];
  List<String> religionOptions = [];
  String? selectedReligion;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReligions();
  }

  void fetchReligions() async {
    try {
      final religions = await ApiService.getReligions();
      setState(() {
        religionOptions = religions;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final pinkColor = Color(0xFFA51C48);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step Header
            Container(
              margin: EdgeInsets.only(bottom: 24),
              padding: EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
              ),
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          value: 0.4,
                          color: pinkColor,
                          strokeWidth: 6,
                          backgroundColor: Color(0xFFE0E0E0),
                        ),
                      ),
                      Text(
                        "2 of 4",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Religion Details",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 19,
                        ),
                      ),
                      SizedBox(height: 2),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Prev. Step: Basic Details",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "Next Step: Personal Details",
                            style: TextStyle(
                              fontSize: 13,
                              color: pinkColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Text(
              "Please provide your religion details:",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),

            // Religion
            Text(
              "Religion",
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            SizedBox(height: 4),
            DropdownButtonFormField<String>(
              value: selectedReligion,
              hint: const Text("Select Religion"),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
              ),
              items:
                  religionOptions.map((religion) {
                    return DropdownMenuItem(
                      value: religion,
                      child: Text(religion),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedReligion = value;
                });
              },
            ),
            SizedBox(height: 8),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                "Willing to marry from other caste also",
                style: TextStyle(fontSize: 14),
              ),
              value: willingToMarryOtherCaste,
              onChanged:
                  (v) => setState(() => willingToMarryOtherCaste = v ?? false),
            ),
            SizedBox(height: 8),

            // Caste
            Text(
              "Caste",
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            SizedBox(height: 4),
            DropdownButtonFormField<String>(
              value: caste,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
              ),
              hint: Text("Select"),
              items:
                  casteOptions
                      .map((e) => DropdownMenuItem(child: Text(e), value: e))
                      .toList(),
              onChanged: (v) {
                setState(() => caste = v);
              },
            ),
            SizedBox(height: 8),

            // Sub Caste
            Text(
              "Sub Caste",
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            SizedBox(height: 4),
            DropdownButtonFormField<String>(
              value: subCaste,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
              ),
              hint: Text("Select"),
              items:
                  subCasteOptions
                      .map((e) => DropdownMenuItem(child: Text(e), value: e))
                      .toList(),
              onChanged: (v) {
                setState(() => subCaste = v);
              },
            ),
            SizedBox(height: 8),

            // Dosham
            Text(
              "Dosham",
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => dosham = 'Yes'),
                    style: OutlinedButton.styleFrom(
                      backgroundColor:
                          dosham == 'Yes' ? pinkColor : Colors.white,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "Yes",
                      style: TextStyle(
                        color: dosham == 'Yes' ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => dosham = 'No'),
                    style: OutlinedButton.styleFrom(
                      backgroundColor:
                          dosham == 'No' ? pinkColor : Colors.white,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "No",
                      style: TextStyle(
                        color: dosham == 'No' ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => dosham = "Don't Know"),
                    style: OutlinedButton.styleFrom(
                      backgroundColor:
                          dosham == "Don't Know" ? pinkColor : Colors.white,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "Don't Know",
                      style: TextStyle(
                        color:
                            dosham == "Don't Know"
                                ? Colors.white
                                : Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: pinkColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                  shadowColor: Colors.black26,
                ),
                onPressed: () {
                  widget.userData.religion = religion;
                  widget.userData.interCaste =
                      willingToMarryOtherCaste ? 'Yes' : 'No';
                  widget.userData.caste = caste;
                  widget.userData.subCaste = subCaste;
                  widget.userData.dosham = dosham ?? 'None';

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ProfessionalDetailsScreen(
                            userData: widget.userData,
                          ),
                    ),
                  );
                },
                child: Text(
                  "Continue",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
