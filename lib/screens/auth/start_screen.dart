import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../utils/theme.dart';
import '../../widgets/apple_widgets.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                
                // Logo
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryRedDark.withOpacity(0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.handyman_rounded,
                      size: 60,
                      color: AppTheme.primaryRedDark,
                    ),
                  ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                ),
                
                const SizedBox(height: 32),
                
                // App Name
                Text(
                  'Khdemti',
                  textAlign: TextAlign.center,
                  style: AppTheme.textTheme.displayLarge?.copyWith(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                  ),
                ).animate().fadeIn().slideY(begin: 0.2, end: 0),
                
                const SizedBox(height: 8),
                
                // Tagline
                Text(
                  'Your trusted home services platform',
                  textAlign: TextAlign.center,
                  style: AppTheme.textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textGrey,
                  ),
                ).animate().fadeIn(delay: 200.ms),
                
                const Spacer(),
                
                // Login Button
                SizedBox(
                  height: 56,
                  child: AppleButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                
                const SizedBox(height: 16),
                
                // Sign Up Button
                SizedBox(
                  height: 56,
                  child: AppleButton(
                    backgroundColor: Colors.white,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignUpScreen()),
                      );
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryRedDark,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
                
                const SizedBox(height: 24),
                
                // Skip Button (Demo Mode)
                Center(
                  child: TextButton(
                    onPressed: () async {
                      final authProvider = Provider.of<AuthProvider>(context, listen: false);
                      await authProvider.enableDemoMode();
                      
                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                        );
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.visibility_off_outlined,
                          size: 18,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Skip for Now (Demo Mode)',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 600.ms),
                
                const SizedBox(height: 16),
                
                // Terms
                Text(
                  'By continuing, you agree to our Terms & Conditions.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
