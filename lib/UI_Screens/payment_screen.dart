import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic>? plan;
  const PaymentScreen({Key? key, this.plan}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int selectedPayment = 0; // 0: UPI, 1: NetBanking, 2: Card
  final pink = const Color(0xFFA51C48);
  bool isLoading = false;

  Future<void> _subscribePlan() async {
  try {
    setState(() => isLoading = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("user_id");
    String? planId = widget.plan?['id']?.toString(); // ✅ FIXED

    print("✅ User ID: $userId");
    print("✅ Plan ID: $planId");
    print("✅ Plan Data: ${widget.plan}");

    if (userId == null || planId == null) {
      _showErrorDialog("User ID or Plan ID missing!");
      return;
    }

    final url =
        "https://pheonixconstructions.com/Matrimony%20API/subscription.php?user_id=$userId&plan_id=$planId";
    print("📡 API: $url");

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data["success"] == 1) {
        _showSuccessDialog(data["message"] ?? "Subscription successful!");
      } else {
        _showErrorDialog(data["message"] ?? "Something went wrong!");
      }
    } else {
      _showErrorDialog("Server error! Code: ${response.statusCode}");
    }
  } catch (e) {
    _showErrorDialog("Error: $e");
  } finally {
    setState(() => isLoading = false);
  }
}

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.verified_rounded,
                    color: Colors.green,
                    size: 70,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Payment Successful",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pink,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // close dialog
                      Navigator.pop(
                        context,
                        true,
                      ); // go back to previous screen
                    },
                    child: const Text(
                      "Continue",
                      style: TextStyle(
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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: const Text(
              "Payment Failed",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
            content: Text(
              message,
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),
            actions: [
              TextButton(
                child: const Text(
                  "Close",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(62),
        child: Container(
          decoration: BoxDecoration(
            color: pink,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(22),
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Text(
                    "Payment Options",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.help_outline, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: 30),
          Center(
            child: Text(
              "${widget.plan?['plan_name'] ?? 'Premium'} Plan",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          const SizedBox(height: 9),
          Center(
            child: Text(
              "₹${widget.plan?['plan_amount'] ?? '999'} /${widget.plan?['duration'] ?? 'month'}",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 24,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Center(
            child: Text(
              "Save 20% compared to monthly",
              style: TextStyle(
                color: Color(0xFF39B36B),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "What's Included",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 13),
                  _includedRow("Unlimited profile views"),
                  _includedRow("Send unlimited messages"),
                  _includedRow("Advanced search filters"),
                  _includedRow("Priority customer support"),
                  _includedRow("Profile highlight feature"),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: const Text(
              "Payment Method",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _paymentOption(
                  selected: selectedPayment == 0,
                  icon: Icons.phone_android,
                  color: Colors.deepPurple,
                  label: "UPI Payment",
                  desc: "Pay with any UPI app",
                  onTap: () => setState(() => selectedPayment = 0),
                ),
                _paymentOption(
                  selected: selectedPayment == 1,
                  icon: Icons.account_balance,
                  color: Colors.green,
                  label: "Net Banking",
                  desc: "All major banks supported",
                  onTap: () => setState(() => selectedPayment = 1),
                ),
                _paymentOption(
                  selected: selectedPayment == 2,
                  icon: Icons.credit_card,
                  color: Colors.orange,
                  label: "Credit/ Debit Card",
                  desc: "Visa, Mastercard, Rupay & More",
                  onTap: () => setState(() => selectedPayment = 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 18),
              child: Builder(
                builder: (context) {
                  double price =
                      double.tryParse(
                        widget.plan?['plan_amount'].toString() ?? '0',
                      ) ??
                      0;
                  double discount = price * 0.10; // 10%
                  double gst = (price - discount) * 0.18; // 18%
                  double total = price - discount + gst;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Billing Summary",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 13),
                      _billRow(
                        "${widget.plan?['name'] ?? 'Premium Plan'} (${widget.plan?['duration'] ?? '1 month'})",
                        "₹${price.toStringAsFixed(2)}",
                      ),
                      _billRow(
                        "Discount (10% off)",
                        "-₹${discount.toStringAsFixed(2)}",
                        color: const Color(0xFF39B36B),
                      ),
                      _billRow("GST (18%)", "₹${gst.toStringAsFixed(2)}"),
                      const SizedBox(height: 6),
                      const Divider(),
                      _billRow(
                        "Total Amount",
                        "₹${total.toStringAsFixed(2)}",
                        bold: true,
                        color: const Color(0xFFA51C48),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: const Color(0xFFE3E3E3)),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter promo code",
                        hintStyle: TextStyle(
                          fontSize: 15,
                          color: Colors.black26,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFA51C48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {},
                    child: const Text(
                      "Apply",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: pink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                  elevation: 0,
                ),
                onPressed: _subscribePlan,
                child: const Text(
                  "Pay Now ",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: RichText(
                text: TextSpan(
                  text: "By continuing, you agree to our ",
                  style: const TextStyle(fontSize: 13.5, color: Colors.black54),
                  children: [
                    TextSpan(
                      text: "Terms & Conditions",
                      style: TextStyle(
                        color: pink,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _includedRow(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF39B36B), size: 19),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentOption({
    required bool selected,
    required IconData icon,
    required Color color,
    required String label,
    required String desc,
    required VoidCallback onTap,
  }) {
    final pink = const Color(0xFFA51C48);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 13),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: selected ? pink : const Color(0xFFE3E3E3),
            width: selected ? 1.8 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.13),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: const TextStyle(
                      fontSize: 13.3,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? pink : const Color(0xFFE3E3E3),
                  width: 1.5,
                ),
                color: selected ? pink.withOpacity(0.13) : Colors.transparent,
              ),
              child:
                  selected
                      ? Center(
                        child: Icon(
                          Icons.radio_button_checked,
                          color: pink,
                          size: 19,
                        ),
                      )
                      : Center(
                        child: Icon(
                          Icons.radio_button_unchecked,
                          color: const Color(0xFFD3D3D3),
                          size: 19,
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _billRow(String key, String value, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              key,
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                fontSize: 15,
                color: color ?? Colors.black87,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: 15,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
