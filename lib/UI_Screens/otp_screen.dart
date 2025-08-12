import 'package:flutter/material.dart';
import 'package:matrimony/UI_Screens/main_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:matrimony/UI_Screens/basic_details_screen.dart';
import '../services/api_service.dart';

class OtpScreen extends StatefulWidget {
  final String mobile;
  const OtpScreen({super.key, required this.mobile});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
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
                      "Enter your Verification Code",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "We have sent a verification code to:\n+91 ${widget.mobile.substring(0, 5)}***${widget.mobile.substring(8)}",
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Please enter the code you received below:",
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Text(
                          "V -",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(width: 16),
                        ...List.generate(
                          4,
                          (i) => Container(
                            width: 44,
                            height: 48,
                            margin: EdgeInsets.only(right: 8),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                            child: TextField(
                              controller: _otpControllers[i],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLength: 1,
                              decoration: InputDecoration(
                                counterText: "",
                                border: InputBorder.none,
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                if (value.isNotEmpty && i < 3) {
                                  FocusScope.of(context).nextFocus();
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32),
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
                        onPressed: _isLoading ? null : _verifyOtp,
                        child:
                            _isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                                  "Verify",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                      ),
                    ),
                    SizedBox(height: 18),
                    Center(
                      child: TextButton(
                        onPressed: _resendOtp,
                        child: Text(
                          "Resend OTP",
                          style: TextStyle(
                            color: pinkColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
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
      ),
    );
  }

  void _verifyOtp() async {
    String otp = _otpControllers.map((controller) => controller.text).join();

    if (otp.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter complete OTP')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    print(
      'Sending OTP verification request for mobile: ${widget.mobile}, otp: $otp',
    );
    final result = await ApiService.verifyOtp(widget.mobile, otp);
    print('OTP verification API result: $result');

    setState(() {
      _isLoading = false;
    });

    if (result['success'] == true) {
      String? userId = result['data']?['user_id']?.toString();
      print('User ID from result: $userId');

      if (userId != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', userId);
        print('Saved user_id: $userId');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainNavigation()),
        );
      } else {
        print('user_id is null in API response');
      }
    } else {
      print('OTP verification failed with error: ${result['error']}');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result['error'] ?? 'Invalid OTP')));
    }
  }

  void _resendOtp() async {
    final result = await ApiService.login(widget.mobile);

    if (result['success']) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('OTP sent successfully')));
      // Clear OTP fields
      for (var controller in _otpControllers) {
        controller.clear();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'] ?? 'Failed to resend OTP')),
      );
    }
  }
}
