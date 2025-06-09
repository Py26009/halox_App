import 'dart:async';

import 'package:flutter/material.dart';
import 'package:halox_app/App_Utilities/app_utilities.dart';
import 'package:halox_app/OnBoarding/LoginPage.dart';
import 'package:halox_app/OnBoarding/Sign_up%20Page.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreen createState() => _SplashScreen();
}

class _SplashScreen extends State<SplashScreen> {
  PageController _pageController = PageController();
  int currentIndex = 0;
  Timer? _timer;

  final List<OnboardingPageData> pages = [
    OnboardingPageData(
      image:
      'https://th.bing.com/th/id/OIP.0-xviYfUU9ZnnNjB9bogrwHaHa?w=121&h=180&c=7&r=0&o=5&dpr=1.3&pid=1.7',
      title: 'Convenience',
      subtitle:
      'Control your home devices using a single app from anywhere in the world',
    ),
    OnboardingPageData(
      image:
      'https://th.bing.com/th/id/OIP.ubXGobmjqx9eTGCkfyIAmQHaE8?w=258&h=180&c=7&r=0&o=5&dpr=1.3&pid=1.7',
      title: 'Stay informed',
      subtitle:
      'Instant notification of you about any activity or alerts.',
    ),
    OnboardingPageData(
      image:
      'https://th.bing.com/th/id/OIP.JJKddy4AA7JnQhhTg2JfdAHaLH?w=115&h=180&c=7&r=0&o=5&dpr=1.3&pid=1.7',
      title: 'Automate',
      subtitle:
      'Switch through different scenes and quick action for fast management of your home.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        int nextPage = (currentIndex + 1) % pages.length;
        _pageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: pages.length,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return OnboardingPage(
                data: pages[index],
              );
            },
          ),
          // Skip button
          Positioned(
            top: 50,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text(
                'SKIP',
                style: mTextStyle18(
                  mColor: Colors.white,
                  mFontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Bottom content
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Row(
              children: [
                Row(
                  children: List.generate(
                    pages.length,
                        (index) => IndicatorDot(isActive: index == currentIndex),
                  ),
                ),
                Spacer(),
                CircleAvatar(
                  backgroundColor: AppColors.primaryBlueColor,
                  child: IconButton(
                    icon: Icon(Icons.arrow_forward, color: Colors.white),
                    onPressed: () {
                      if (currentIndex < pages.length - 1) {
                        _pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginPage()),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final OnboardingPageData data;

  const OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          data.image,
          fit: BoxFit.fill,
        ),
        // Optional: gradient overlay for better text visibility
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withOpacity(0.5),
                Colors.transparent,
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 120,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.title,
                style: mTextStyle26(
                  mColor: Colors.white,
                  mFontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 10),
              Text(
                data.subtitle,
                style: mTextStyle18(
                  mColor: Colors.white70,
                  mFontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class OnboardingPageData {
  final String image;
  final String title;
  final String subtitle;

  OnboardingPageData({
    required this.image,
    required this.title,
    required this.subtitle,
  });
}

class IndicatorDot extends StatelessWidget {
  final bool isActive;

  const IndicatorDot({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 14 : 8,
      height: isActive ? 14 : 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? AppColors.primaryBlueColor : Colors.white38,
      ),
    );
  }
}