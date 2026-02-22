import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _introKey = GlobalKey<IntroductionScreenState>();

  Future<void> _onDone() async {
    // Mark onboarding as completed
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _onSkip() {
    _onDone();
  }

  @override
  Widget build(BuildContext context) {
    const pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(
        fontSize: 28.0,
        fontWeight: FontWeight.w700,
      ),
      bodyTextStyle: TextStyle(fontSize: 16.0),
      bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: _introKey,
      globalBackgroundColor: Colors.white,
      
      pages: [
        // Page 1: Welcome
        PageViewModel(
          title: "Welcome to QuickBite",
          body:
              "Compare food prices across Swiggy, Zomato, and ONDC. Order from wherever it's cheapest and save money on every meal!",
          image: _buildImage('assets/onboarding_welcome.png', Icons.restaurant_menu),
          decoration: pageDecoration.copyWith(
            titleTextStyle: const TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.w700,
              color: Color(0xFFEA580C),
            ),
          ),
        ),

        // Page 2: Price Comparison
        PageViewModel(
          title: "Smart Price Comparison",
          body:
              "Our AI compares prices in real-time across all major food delivery platforms. See the best deals instantly and save up to 30% on your orders.",
          image: _buildImage('assets/onboarding_compare.png', Icons.compare_arrows),
          decoration: pageDecoration,
        ),

        // Page 3: Best Deals
        PageViewModel(
          title: "Never Miss a Deal",
          body:
              "Get personalized recommendations and exclusive deals. Track your savings and see how much you've saved over time.",
          image: _buildImage('assets/onboarding_deals.png', Icons.local_offer),
          decoration: pageDecoration,
        ),

        // Page 4: Easy Ordering
        PageViewModel(
          title: "Order in Seconds",
          body:
              "Browse menus, add to cart, and checkout seamlessly. Track your orders and manage favorites all in one place.",
          image: _buildImage('assets/onboarding_order.png', Icons.shopping_cart),
          decoration: pageDecoration,
          footer: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: ElevatedButton(
              onPressed: _onDone,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEA580C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Get Started",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],

      onDone: _onDone,
      onSkip: _onSkip,
      showSkipButton: true,
      skipOrBackFlex: 0,
      nextFlex: 0,
      showBackButton: false,
      back: const Icon(Icons.arrow_back),
      skip: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeColor: Color(0xFFEA580C),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }

  Widget _buildImage(String assetName, IconData fallbackIcon) {
    // Use icon as fallback since we don't have assets yet
    return Center(
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          color: const Color(0xFFEA580C).withOpacity(0.1),
          borderRadius: BorderRadius.circular(140),
        ),
        child: Icon(
          fallbackIcon,
          size: 120,
          color: const Color(0xFFEA580C),
        ),
      ),
    );
  }
}
