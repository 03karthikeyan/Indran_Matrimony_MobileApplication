import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:matrimony/services/api_service.dart';
import 'about_yourself_screen.dart';
import '../models/user_data.dart';

class ProfessionalDetailsScreen extends StatefulWidget {
  final UserData userData;
  const ProfessionalDetailsScreen({super.key, required this.userData});

  @override
  State<ProfessionalDetailsScreen> createState() =>
      _ProfessionalDetailsScreenState();
}

class _ProfessionalDetailsScreenState extends State<ProfessionalDetailsScreen> {
  final TextEditingController educationController = TextEditingController();
  final TextEditingController employedInController = TextEditingController();
  final TextEditingController occupationController = TextEditingController();
  final TextEditingController annualIncomeController = TextEditingController();

  String? workLocation;
  String? state;
  String? city;

  final List<String> workLocations = ['Office', 'Remote', 'Hybrid'];
  final List<String> cities = ['Chennai', 'Coimbatore', 'Madurai'];

  final List<String> incomeRanges = [
    "Below 2 Lakh",
    "2 - 5 Lakh",
    "5 - 10 Lakh",
    "10 - 15 Lakh",
    "15 - 25 Lakh",
    "25 - 50 Lakh",
    "50 Lakh - 1 Crore",
    "Above 1 Crore",
  ];
  List<String> stateOptions = [];
  String? selectedState;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStates();
  }

  void fetchStates() async {
    try {
      final states = await ApiService.getStates();
      setState(() {
        stateOptions = states;
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
                          value: 0.75,
                          color: pinkColor,
                          strokeWidth: 6,
                          backgroundColor: Color(0xFFE0E0E0),
                        ),
                      ),
                      Text(
                        "3 of 4",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Prev. Step: Religion Details",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "Professional Details",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 19,
                          ),
                        ),
                        Text(
                          "Next Step: About Yourself",
                          style: TextStyle(
                            fontSize: 13,
                            color: pinkColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              "Please provide your professional details:",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),

            // Highest Education
            Text(
              "Highest Education:",
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            SizedBox(height: 4),
            TextField(
              controller: educationController,
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
            ),
            SizedBox(height: 16),

            // Employed In
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Employed In:",
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                SizedBox(height: 4),

                CustomDropdown<String>.search(
                  hintText: "Select Employment Type",
                  items: [
                    "Government",
                    "Private",
                    "Business",
                    "Self Employed",
                    "Defence",
                    "Not Working",
                  ],
                  initialItem:
                      employedInController.text.isNotEmpty
                          ? employedInController.text
                          : null, // ✅ auto select if already chosen
                  onChanged: (value) {
                    employedInController.text = value!;
                  },
                  decoration: CustomDropdownDecoration(
                    closedBorder: Border.all(color: Colors.grey.shade400),
                    closedBorderRadius: BorderRadius.circular(9),
                    expandedBorder: Border.all(
                      color: Colors.blueAccent,
                    ), // when opened
                    expandedBorderRadius: BorderRadius.circular(9),
                    hintStyle: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            // Occupation
            Text(
              "Occupation:",
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            SizedBox(height: 4),
            TextField(
              controller: occupationController,
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
            ),
            SizedBox(height: 16),

            // Annual Income
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Annual Income (Rs):",
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                SizedBox(height: 4),

                CustomDropdown<String>.search(
                  hintText: "Select Income Range",
                  items: incomeRanges,
                  initialItem:
                      annualIncomeController.text.isNotEmpty
                          ? annualIncomeController.text
                          : null, // if already selected
                  onChanged: (value) {
                    annualIncomeController.text = value!;
                  },
                  decoration: CustomDropdownDecoration(
                    closedBorder: Border.all(color: Colors.grey.shade400),
                    closedBorderRadius: BorderRadius.circular(9),
                    expandedBorder: Border.all(color: Colors.blueAccent),
                    expandedBorderRadius: BorderRadius.circular(9),
                    hintStyle: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            // Inside your widget build:
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Work Location
                Text(
                  "Work Location:",
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                SizedBox(height: 4),
                CustomDropdown<String>.search(
                  hintText: "Select Work Location",
                  items: workLocations,
                  initialItem: workLocation,
                  onChanged: (value) {
                    setState(() => workLocation = value);
                  },
                  decoration: CustomDropdownDecoration(
                    closedBorder: Border.all(color: Colors.grey.shade400),
                    closedBorderRadius: BorderRadius.circular(9),
                    expandedBorder: Border.all(
                      color: Colors.blueAccent,
                    ), // when opened
                    expandedBorderRadius: BorderRadius.circular(9),
                    hintStyle: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // State
                Text(
                  "State:",
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                SizedBox(height: 4),
                CustomDropdown<String>.search(
                  hintText: "Select State",
                  items: stateOptions,
                  initialItem: selectedState,
                  onChanged: (value) {
                    setState(() => selectedState = value);
                  },
                  decoration: CustomDropdownDecoration(
                    closedBorder: Border.all(color: Colors.grey.shade400),
                    closedBorderRadius: BorderRadius.circular(9),
                    expandedBorder: Border.all(
                      color: Colors.blueAccent,
                    ), // when opened
                    expandedBorderRadius: BorderRadius.circular(9),
                    hintStyle: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // City
                Text(
                  "City:",
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                SizedBox(height: 4),
                CustomDropdown<String>.search(
                  hintText: "Select City",
                  items: cities,
                  initialItem: city,
                  onChanged: (value) {
                    setState(() => city = value);
                  },
                  decoration: CustomDropdownDecoration(
                    closedBorder: Border.all(color: Colors.grey.shade400),
                    closedBorderRadius: BorderRadius.circular(9),
                    expandedBorder: Border.all(
                      color: Colors.blueAccent,
                    ), // when opened
                    expandedBorderRadius: BorderRadius.circular(9),
                    hintStyle: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
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
                  if (_validateForm()) {
                    widget.userData.higherEducation = educationController.text;
                    widget.userData.employeeIn = employedInController.text;
                    widget.userData.occupation = occupationController.text;
                    widget.userData.annualIncome = annualIncomeController.text;
                    widget.userData.workLocation = workLocation;
                    widget.userData.state = selectedState;
                    widget.userData.city = city;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => AboutYourselfScreen(
                              userData: widget.userData,
                              mobile: '',
                            ),
                      ),
                    );
                  }
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

  bool _validateForm() {
    if (educationController.text.isEmpty ||
        employedInController.text.isEmpty ||
        occupationController.text.isEmpty ||
        annualIncomeController.text.isEmpty ||
        workLocation == null ||
        selectedState == null ||
        city == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields')),
      );
      return false;
    }
    return true;
  }
}
