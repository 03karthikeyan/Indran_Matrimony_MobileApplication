import 'package:flutter/material.dart';
// import 'package:matrimony/Screens/Home_Screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  int currentStep = 0;
  final int totalSteps = 7;
  final PageController _controller = PageController();

  // Example form data controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController jobController = TextEditingController();

  void next() {
    if (currentStep < totalSteps - 1) {
      setState(() => currentStep++);
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void back() {
    if (currentStep > 0) {
      setState(() => currentStep--);
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void submitProfile() {
    // Optionally: Validate and save data here
    print("Profile submitted!");

    // Navigate to the next screen
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(
    //     builder:
    //         (_) => const HomeMatchesScreen(), // Replace with your next screen
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Your Profile"),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Column(
        children: [
          _buildStepper(),
          Expanded(
            child: PageView(
              controller: _controller,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _stepPersonalInfo(),
                _stepEducationJob(),
                _stepReligionCaste(),
                _stepFamilyInfo(),
                _stepPartnerPreferences(),
                _stepLocation(),
                _stepPhotoUpload(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                if (currentStep > 0)
                  ElevatedButton(onPressed: back, child: const Text("← Back")),
                const Spacer(),
                ElevatedButton(
                  onPressed:
                      currentStep == totalSteps - 1 ? submitProfile : next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                  ),
                  child: Text(
                    currentStep == totalSteps - 1 ? "Submit" : "Next →",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    return Row(
      children: List.generate(
        totalSteps,
        (index) => Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
            height: 6,
            decoration: BoxDecoration(
              color:
                  index <= currentStep ? Colors.pinkAccent : Colors.grey[300],
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepPersonalInfo() {
    return _formWrapper([
      const Text("Full Name"),
      TextField(
        controller: nameController,
        decoration: const InputDecoration(hintText: "Enter full name"),
      ),
      const SizedBox(height: 10),
      const Text("Gender"),
      DropdownButtonFormField(
        items: const [
          DropdownMenuItem(value: "Male", child: Text("Male")),
          DropdownMenuItem(value: "Female", child: Text("Female")),
        ],
        onChanged: (val) {},
        decoration: const InputDecoration(border: OutlineInputBorder()),
      ),
      const SizedBox(height: 10),
      const Text("Date of Birth"),
      TextField(decoration: const InputDecoration(hintText: "DD/MM/YYYY")),
    ]);
  }

  Widget _stepEducationJob() {
    return _formWrapper([
      const Text("Education"),
      TextField(
        decoration: const InputDecoration(hintText: "e.g. B.Tech, MBA"),
      ),
      const SizedBox(height: 10),
      const Text("Occupation"),
      TextField(
        controller: jobController,
        decoration: const InputDecoration(hintText: "e.g. Engineer"),
      ),
    ]);
  }

  Widget _stepReligionCaste() {
    return _formWrapper([
      const Text("Religion"),
      DropdownButtonFormField(
        items: const [
          DropdownMenuItem(value: "Hindu", child: Text("Hindu")),
          DropdownMenuItem(value: "Muslim", child: Text("Muslim")),
        ],
        onChanged: (val) {},
        decoration: const InputDecoration(border: OutlineInputBorder()),
      ),
      const SizedBox(height: 10),
      const Text("Caste"),
      TextField(decoration: const InputDecoration(hintText: "e.g. Brahmin")),
    ]);
  }

  Widget _stepFamilyInfo() {
    return _formWrapper([
      const Text("Father's Name"),
      TextField(decoration: const InputDecoration(hintText: "Father's name")),
      const SizedBox(height: 10),
      const Text("Mother's Name"),
      TextField(decoration: const InputDecoration(hintText: "Mother's name")),
    ]);
  }

  Widget _stepPartnerPreferences() {
    return _formWrapper([
      const Text("Preferred Age Range"),
      TextField(decoration: const InputDecoration(hintText: "e.g. 25-30")),
      const SizedBox(height: 10),
      const Text("Preferred Education"),
      TextField(decoration: const InputDecoration(hintText: "e.g. Any, MBA")),
    ]);
  }

  Widget _stepLocation() {
    return _formWrapper([
      const Text("Country"),
      TextField(decoration: const InputDecoration(hintText: "e.g. India")),
      const SizedBox(height: 10),
      const Text("City/State"),
      TextField(decoration: const InputDecoration(hintText: "e.g. Chennai")),
    ]);
  }

  Widget _stepPhotoUpload() {
    return _formWrapper([
      const Text("Upload Your Photos"),
      const SizedBox(height: 10),
      ElevatedButton(onPressed: () {}, child: const Text("Upload")),
      const SizedBox(height: 10),
      const Text("First photo will be your profile picture"),
    ]);
  }

  Widget _formWrapper(List<Widget> children) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
