import 'dart:convert';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  final TextEditingController districtController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController address1Controller = TextEditingController();
  final TextEditingController address2Controller = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();

  String? workLocation;
  String? state;
  String? city;
  final UserData userData = UserData();
  final List<String> workLocations = ['Office', 'Remote', 'Hybrid'];
  final List<String> cities = ['Chennai', 'Coimbatore', 'Madurai'];

  List<AnnualIncome> _incomeList = [];
  bool _isLoadingIncome = true;

  List<String> stateOptions = [];
  String? selectedState;

  List<String> districtOptions = [];
  String? selectedDistrict;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStates();
    fetchAnnualIncomeList();
    fetchDistrictList();
  }

  //Income List Fetch

  Future<void> fetchAnnualIncomeList() async {
    try {
      final response = await http.get(
        Uri.parse(
          "https://pheonixconstructions.com/Matrimony API/annual_income_list.php",
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          final List<dynamic> list = data['data'];
          setState(() {
            _incomeList = list.map((e) => AnnualIncome.fromJson(e)).toList();
            _isLoadingIncome = false;
          });
        }
      }
    } catch (e) {
      print("Error fetching annual income list: $e");
      setState(() => _isLoadingIncome = false);
    }
  }

  /// Fetch district list from API
  Future<void> fetchDistrictList() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://pheonixconstructions.com/Matrimony%20API/district_list.php',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            districtOptions = List<String>.from(
              data['data'].map((item) => item['district_name'].toString()),
            );
          });
        }
      } else {
        debugPrint('Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Failed to load districts: $e');
    } finally {
      setState(() => isLoading = false);
    }
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
                  hintText: "Select Annual Income",
                  items: _incomeList.map((e) => e.income).toList(),
                  initialItem:
                      annualIncomeController.text.isNotEmpty
                          ? annualIncomeController.text
                          : null,
                  onChanged: (value) {
                    setState(() {
                      annualIncomeController.text = value ?? '';
                      userData.annualIncome = value;
                    });
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
                    Text(
                      "City",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    TextField(
                      controller: cityController,
                      decoration: InputDecoration(
                        hintText: "Enter City",
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
                  ],
                ),

                // District
                Text(
                  "District:",
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 4),

                // Loading indicator while fetching data
                CustomDropdown<String>.search(
                  hintText: "Select District",
                  items: districtOptions,
                  initialItem: selectedDistrict,
                  onChanged: (value) {
                    setState(() => selectedDistrict = value);
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

                // Street / House / Flat
                Text(
                  "Street / House / Flat:",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                TextField(
                  controller: address1Controller,
                  decoration: InputDecoration(
                    hintText: "Enter street name, house no, or apartment",
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

                // Landmark / Area / Locality
                Text(
                  "Landmark / Area / Locality:",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                TextField(
                  controller: address2Controller,
                  decoration: InputDecoration(
                    hintText: "E.g. Near Bus Stand, Opposite School",
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

                // Pincode
                Text(
                  "Pincode:",
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                SizedBox(height: 4),
                TextField(
                  controller: pincodeController,
                  keyboardType: TextInputType.number,
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

                // SizedBox(height: 30),
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
                        widget.userData.higherEducation =
                            educationController.text;
                        widget.userData.employeeIn = employedInController.text;
                        widget.userData.occupation = occupationController.text;
                        widget.userData.annualIncome =
                            annualIncomeController.text;
                        widget.userData.workLocation = workLocation;
                        widget.userData.state = selectedState;
                        widget.userData.city = cityController.text;
                        widget.userData.district = selectedDistrict;
                        widget.userData.addressLane1 = address1Controller.text;
                        widget.userData.addressLane2 = address2Controller.text;
                        widget.userData.pincode = pincodeController.text;

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
        city == null ||
        districtController.text.isEmpty ||
        address1Controller.text.isEmpty ||
        address2Controller.text.isEmpty ||
        pincodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields')),
      );
      return false;
    }
    return true;
  }
}
