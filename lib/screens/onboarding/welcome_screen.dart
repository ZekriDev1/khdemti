import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/theme.dart';
import '../../widgets/apple_widgets.dart';
import 'user_info_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF0F0), AppTheme.backgroundWhite],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // Logo Section
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryRedDark.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.asset('Assets/logo.jpeg', fit: BoxFit.cover),
                  ),
                ).animate().fadeIn(duration: 600.ms).scale(),
                
                const SizedBox(height: 40),
                
                Text(
                  "Welcome to Khdemti",
                  style: AppTheme.textTheme.displayMedium,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
                
                const SizedBox(height: 12),
                
                Text(
                  "The premium marketplace for all your home service needs.",
                  style: AppTheme.textTheme.bodyLarge?.copyWith(color: AppTheme.textGrey),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
                
                const Spacer(),
                
                // Get Started Button
                SizedBox(
                  width: double.infinity,
                  child: AppleButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const UserInfoScreen()),
                      );
                    },
                    child: const Text(
                      "Get Started",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
