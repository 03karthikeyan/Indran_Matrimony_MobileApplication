import 'package:flutter/material.dart';
import 'religion_details_screen.dart';
import '../models/user_data.dart';

class BasicDetailsScreen extends StatefulWidget {
  final String mobile;
  const BasicDetailsScreen({super.key, required this.mobile});

  @override
  State<BasicDetailsScreen> createState() => _BasicDetailsScreenState();
}

class _BasicDetailsScreenState extends State<BasicDetailsScreen> {
  String? gender;
  String? profileFor;
  final profileOptions = ['Self', 'Son', 'Daughter', 'Brother', 'Sister', 'Friend', 'Relative'];
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

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
              padding: EdgeInsets.symmetric(vertical: 18, horizontal: 0),
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
                          value: 0.2,
                          color: pinkColor,
                          strokeWidth: 6,
                          backgroundColor: Color(0xFFE0E0E0),
                        ),
                      ),
                      Text("1 of 4",
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    ],
                  ),
                  SizedBox(width: 14),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text("Basic Details",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 19,
                        )),
                    SizedBox(height: 2),
                    Text(
                      "Next Step: Religion Details",
                      style: TextStyle(
                        fontSize: 13,
                        color: pinkColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ]),
                ],
              ),
            ),

            Text(
              "Please provide your basic details:",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            // Name
            Text("Name:", style: TextStyle(fontSize: 14, color: Colors.black87)),
            SizedBox(height: 4),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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

            // Date Of Birth and Age
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Date Of Birth:", style: TextStyle(fontSize: 14, color: Colors.black87)),
                      SizedBox(height: 4),
                      TextField(
                        controller: dobController,
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: "",
                          prefixIcon: Icon(Icons.calendar_today_outlined, size: 20),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9),
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9),
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                        ),
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime(1990, 1, 1),
                            firstDate: DateTime(1950),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            dobController.text = "${picked.day}/${picked.month}/${picked.year}";
                          }
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Age:", style: TextStyle(fontSize: 14, color: Colors.black87)),
                      SizedBox(height: 4),
                      TextField(
                        controller: ageController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          suffixIcon: Icon(Icons.arrow_drop_down, size: 20),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
                ),
              ],
            ),
            SizedBox(height: 16),

            // Email ID
            Text("Email ID:", style: TextStyle(fontSize: 14, color: Colors.black87)),
            SizedBox(height: 4),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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

            // Gender
            Text("Gender:", style: TextStyle(fontSize: 14, color: Colors.black87)),
            SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => gender = 'Male'),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: gender == 'Male' ? pinkColor : Colors.white,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      "Male",
                      style: TextStyle(
                        color: gender == 'Male' ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => gender = 'Female'),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: gender == 'Female' ? pinkColor : Colors.white,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      "Female",
                      style: TextStyle(
                        color: gender == 'Female' ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Profile for
            Text("Profile for:", style: TextStyle(fontSize: 14, color: Colors.black87)),
            SizedBox(height: 4),
            DropdownButtonFormField<String>(
              value: profileFor,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
              items: profileOptions
                  .map((e) => DropdownMenuItem(
                        child: Text(e),
                        value: e,
                      ))
                  .toList(),
              onChanged: (v) {
                setState(() => profileFor = v);
              },
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
                    UserData userData = UserData();
                    userData.name = nameController.text;
                    userData.contactNo = widget.mobile;
                    userData.dob = _formatDate(dobController.text);
                    userData.age = ageController.text;
                    userData.emailId = emailController.text;
                    userData.gender = gender;
                    
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReligionDetailsScreen(userData: userData),
                      ),
                    );
                  }
                },
                child: Text("Continue", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  bool _validateForm() {
    if (nameController.text.isEmpty || dobController.text.isEmpty || 
        ageController.text.isEmpty || emailController.text.isEmpty || gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields')),
      );
      return false;
    }
    return true;
  }

  String _formatDate(String date) {
    if (date.isEmpty) return '';
    List<String> parts = date.split('/');
    if (parts.length == 3) {
      return '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
    }
    return date;
  }
}