import 'package:flutter/material.dart';
import 'login_screen.dart';

// import 'otp_verification_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      'image': 'assets/2.png',
      'title': 'Find Your Perfect Tamil Life Partner',
      'subtitle':
          'Connect with verified Tamil profiles from around the world. Your soulmate is just a swipe away!',
    },
    {
      'image': 'assets/3.png',
      'title': 'Chat & Connect Instanly',
      'subtitle': 'Send Interest, Start Conversations & Take the Next Step.',
    },
    {
      'image': 'assets/4.png',
      'title': '100% Verified & Genuine Profiles',
      'subtitle': 'ID Verified    •    Phone Verified',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView.builder(
        controller: _pageController,
        itemCount: onboardingData.length,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemBuilder: (context, index) {
          return Column(
            children: [
              Image.asset(
                onboardingData[index]['image']!,
                width: double.infinity,
                height: 421,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Text(
                      onboardingData[index]['title']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (index != 2)
                      Text(
                        onboardingData[index]['subtitle']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.verified,
                            color: Color(0xFF16A34A),
                            size: 20,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'ID Verified',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF16A34A),
                            ),
                          ),
                          SizedBox(width: 16),
                          Icon(
                            Icons.phone_android,
                            color: Color(0xFF2563EB),
                            size: 20,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Phone Verified',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  onboardingData.length,
                  (dotIndex) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == dotIndex ? 12 : 8,
                    height: _currentPage == dotIndex ? 12 : 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          _currentPage == dotIndex
                              ? const Color(0xFF9B134E)
                              : Colors.grey[400],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_currentPage == onboardingData.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9B134E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 30),
            ],
          );
        },
      ),
    );
  }
}
