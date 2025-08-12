import 'package:flutter/material.dart';
import 'package:matrimony/Screens/Role_selection_Screen.dart';

class LoginOTPScreen extends StatefulWidget {
  const LoginOTPScreen({super.key});

  @override
  State<LoginOTPScreen> createState() => _LoginOTPScreenState();
}

class _LoginOTPScreenState extends State<LoginOTPScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _otpSent = false;

  void _sendOTP() {
    if (_phoneController.text.length == 10) {
      setState(() => _otpSent = true);
      // TODO: Send OTP logic
      print("OTP sent to ${_phoneController.text}");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid 10-digit mobile number")),
      );
    }
  }

  void _verifyOTP() {
    if (_otpController.text.length >= 4 && _otpController.text.length <= 6) {
      // TODO: Verify OTP logic
      print("OTP Verified: ${_otpController.text}");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid OTP")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login / OTP Verification"),
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: _otpSent ? _buildOTPInput() : _buildPhoneInput(),
      ),
    );
  }

  Widget _buildPhoneInput() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Enter your Mobile Number", style: TextStyle(fontSize: 18)),
        const SizedBox(height: 16),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: "Mobile Number",
            prefixText: "+91 ",
            border: OutlineInputBorder(),
          ),
          maxLength: 10,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _sendOTP,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pinkAccent,
            minimumSize: const Size(double.infinity, 48),
          ),
          child: const Text("Send OTP →", style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildOTPInput() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Enter OTP sent to your number",
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "OTP",
            border: OutlineInputBorder(),
          ),
          maxLength: 6,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _verifyOTP,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pinkAccent,
            minimumSize: const Size(double.infinity, 48),
          ),
          child: const Text("Verify OTP", style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}
