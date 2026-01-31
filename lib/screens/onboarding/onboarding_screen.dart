import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/theme.dart';
import '../../widgets/zellij_background.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      "title": "Trusted Local Services",
      "desc": "Find skilled Moroccan professionals for all your home and business needs. Reliable, rated, and ready.",
      "emoji": "🛠️",
    },
    {
      "title": "Instant & Secure",
      "desc": "Book instantly with transparent pricing. Verified providers at your doorstep in minutes.",
      "emoji": "⚡",
    },
    {
      "title": "Khdemti for Everyone",
      "desc": "Empowering local craftsmanship. Support Moroccan workers and get premium service.",
      "emoji": "🇲🇦",
    },
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_onboarding', true);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: ZellijBackground(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 200,
                          width: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryRedDark.withOpacity(0.1),
                                blurRadius: 30,
                                spreadRadius: 10,
                              )
                            ],
                          ),
                          child: Center(
                            child: Text(
                              page["emoji"]!,
                              style: const TextStyle(fontSize: 80),
                            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                             .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 1500.ms, curve: Curves.easeInOut)
                             .shimmer(duration: 2000.ms, color: AppTheme.saffronYellow.withOpacity(0.5)),
                          ),
                        ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
                        const SizedBox(height: 48),
                        Text(
                          page["title"]!,
                          textAlign: TextAlign.center,
                          style: AppTheme.textTheme.displayMedium?.copyWith(
                            color: AppTheme.primaryRedDark,
                          ),
                        ).animate().fadeIn(delay: 200.ms).moveY(begin: 20, end: 0),
                        const SizedBox(height: 16),
                        Text(
                          page["desc"]!,
                          textAlign: TextAlign.center,
                          style: AppTheme.textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textGrey,
                            height: 1.5,
                          ),
                        ).animate().fadeIn(delay: 400.ms).moveY(begin: 20, end: 0),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppTheme.primaryRedDark
                              : AppTheme.primaryRedDark.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryRedDark.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          if (_currentPage < _pages.length - 1) {
                            _controller.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            _completeOnboarding();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: Text(
                          _currentPage == _pages.length - 1 ? "Get Started 🚀" : "Next",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  if (_currentPage < _pages.length - 1)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: TextButton(
                        onPressed: _completeOnboarding,
                        child: Text(
                          "Skip",
                          style: GoogleFonts.inter(
                            color: AppTheme.textGrey,
                            fontWeight: FontWeight.w600,
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
    );
  }
}
