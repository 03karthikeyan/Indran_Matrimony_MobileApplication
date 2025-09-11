import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pinkColor = const Color(0xFFA51C48);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Help & Support",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: pinkColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Help & Support",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "We are here to help you! Find answers to common questions, or contact our support team.",
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 20),

            // Example FAQ list
            Card(
              child: ListTile(
                title: const Text("How to edit my profile?"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () {},
              ),
            ),
            Card(
              child: ListTile(
                title: const Text("How to upgrade to Premium?"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () {},
              ),
            ),
            Card(
              child: ListTile(
                title: const Text("How to contact support?"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
