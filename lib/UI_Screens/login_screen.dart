import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:matrimony/UI_Screens/basic_details_screen.dart';
import 'otp_screen.dart';
// import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _mobileController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final pinkColor = Color(0xFFA51C48);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 48),
              Image.asset("assets/logo1.png", width: 90, height: 90),
              SizedBox(height: 18),
              Text(
                "Indran Matrimony",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 6),
              Text(
                "Find your perfect life partner",
                style: TextStyle(fontSize: 15, color: Colors.black54),
              ),
              SizedBox(height: 35),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 22, vertical: 28),
                margin: EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: Color(0xFFFDF3F6),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome, Login",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Enter your phone number to continue",
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    SizedBox(height: 22),
                    Text(
                      "Phone number",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(7),
                            ),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: Text(
                            "+91",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                        ),

                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.horizontal(
                                right: Radius.circular(7),
                              ),
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                            child: TextField(
                              controller: _mobileController,
                              decoration: const InputDecoration(
                                hintText: "Enter mobile number",
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                              keyboardType:
                                  TextInputType.number, // Only number keypad
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
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
                        onPressed: _isLoading ? null : _loginWithMobile,
                        child:
                            _isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                                  "Send OTP",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                      ),
                    ),
                    SizedBox(height: 28),

                    // Not a Member Section
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 18),
                      padding: EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Not a Member?",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: Color(0xFFA51C48),
                                  width: 1.4,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => BasicDetailsScreen(
                                          mobile: _mobileController.text.trim(),
                                        ),
                                  ),
                                );
                              },
                              child: Text(
                                "Register Free",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFA51C48),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _BottomFeature(
                      icon: "icon1.png",
                      label: "Secure & Private",
                    ),
                    _BottomFeature(
                      icon: "icon2.png",
                      label: "Verified Profiles",
                    ),
                    _BottomFeature(icon: "icon3.png", label: "Perfect Matches"),
                  ],
                ),
              ),
              SizedBox(height: 22),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Text.rich(
                  TextSpan(
                    text: "By continuing, you agree to our ",
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                    children: [
                      TextSpan(
                        text: "Terms of Service",
                        style: TextStyle(
                          color: pinkColor,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      TextSpan(text: " and "),
                      TextSpan(
                        text: "Privacy Policy",
                        style: TextStyle(
                          color: pinkColor,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loginWithMobile() async {
    final mobile = _mobileController.text.trim();

    if (mobile.isEmpty || mobile.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid 10-digit mobile number')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final url = Uri.parse(
      'https://pheonixconstructions.com/Matrimony API/login.php?mobile=$mobile',
    );

    try {
      final response = await http.get(url);
      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Login API Response: $data');

        if (data['success'] == 1 &&
            data['message'].toString().toLowerCase() == 'success') {
          // User already registered, proceed to OTP screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OtpScreen(mobile: mobile)),
          );
        } else {
          //  User not found, show register prompt
          _showNotRegisteredDialog(_mobileController.text);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to login. Please try again.')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  /// Show custom dialog if mobile number is not registered
  void _showNotRegisteredDialog(String mobile) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must choose an option
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Color(0xFFA51C48),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      "Number Not Registered",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Message
                Text(
                  "The mobile number you entered is not registered.\nWould you like to create a new account?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.black87),
                ),
                SizedBox(height: 20),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                      },
                      child: Text("Cancel"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFA51C48),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => BasicDetailsScreen(mobile: mobile),
                          ),
                        );
                      },
                      child: Text("Register"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BottomFeature extends StatelessWidget {
  final String icon;
  final String label;
  const _BottomFeature({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: Color(0xFFFCE4EC),
            shape: BoxShape.circle,
          ),
          child: Image.asset("assets/$icon", width: 22, height: 22),
        ),
        SizedBox(height: 7),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }
}
