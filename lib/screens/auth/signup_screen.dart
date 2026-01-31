import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../utils/theme.dart';
import '../../widgets/apple_widgets.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';
import '../onboarding/verification_screen.dart';
import 'email_verification_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // Optional Phone
  final _phoneController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      
      String? phone = _phoneController.text.trim();
      if (phone.isEmpty) {
        phone = null;
      } else {
        // Basic cleanup if needed, but saving as raw is fine too
        phone = phone.replaceAll(RegExp(r'\s+'), '');
      }

      await Provider.of<AuthProvider>(context, listen: false).signUpWithEmail(
        email: email,
        password: password,
        fullName: name,
        phone: phone,
      );

      if (mounted) {
        // Navigate to Email Verification screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => EmailVerificationScreen(email: email),
          ),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Signup Failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signUpGoogle() async {
    setState(() => _isLoading = true);
    try {
      await Provider.of<AuthProvider>(context, listen: false).signInWithGoogle();
      
      if (mounted) {
         // Navigate to Home directly after successful signup
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Signup Failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppTheme.textDark),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF0F0), AppTheme.backgroundWhite],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    'Create Account',
                    style: AppTheme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Sign up to get started',
                    style: AppTheme.textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textGrey,
                    ),
                  ).animate().fadeIn(delay: 100.ms),
                  
                  const SizedBox(height: 40),
                  
                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Full Name
                        Text('Full Name', style: AppTheme.textTheme.titleLarge?.copyWith(fontSize: 16)),
                        const SizedBox(height: 12),
                        AppleTextField(
                          controller: _nameController,
                          hintText: 'Enter your full name',
                          prefixIcon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Please enter your name';
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 24),

                        // Email
                        Text('Email Address', style: AppTheme.textTheme.titleLarge?.copyWith(fontSize: 16)),
                        const SizedBox(height: 12),
                        AppleTextField(
                          controller: _emailController,
                          hintText: 'name@example.com',
                          prefixIcon: Icons.email_rounded,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Please enter your email';
                            if (!value.contains('@')) return 'Invalid email';
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Password
                        Text('Password', style: AppTheme.textTheme.titleLarge?.copyWith(fontSize: 16)),
                        const SizedBox(height: 12),
                        AppleTextField(
                          controller: _passwordController,
                          hintText: '••••••••',
                          prefixIcon: Icons.lock_rounded,
                          obscureText: true,
                          validator: (value) {
                             if (value == null || value.isEmpty) return 'Please enter your password';
                             if (value.length < 6) return 'Password too short (min 6)';
                             return null;
                          },
                        ),

                        const SizedBox(height: 24),
                        
                        // Optional Phone
                        Row(
                          children: [
                            Text('Phone Number ', style: AppTheme.textTheme.titleLarge?.copyWith(fontSize: 16)),
                            Text('(Optional)', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        AppleTextField(
                          controller: _phoneController,
                          hintText: '06 XX XX XX XX',
                          prefixIcon: Icons.phone_iphone_rounded,
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  
                  const SizedBox(height: 32),
                  
                  // Sign Up Button
                  SizedBox(
                    height: 56,
                    width: double.infinity,
                    child: AppleButton(
                      onPressed: _isLoading ? null : _signUp,
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                  
                  const SizedBox(height: 16),
                  
                  // Google Sign Up Button
                  SizedBox(
                    height: 56,
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _signUpGoogle,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        side: const BorderSide(color: Colors.grey),
                        backgroundColor: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.g_mobiledata, size: 32, color: Colors.blue),
                          const SizedBox(width: 8),
                          const Text(
                            'Sign up with Google',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 450.ms),

                  const SizedBox(height: 24),
                  
                  // Already have account
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: RichText(
                        text: const TextSpan(
                          text: 'Already have an account? ',
                          style: TextStyle(color: AppTheme.textGrey),
                          children: [
                            TextSpan(
                              text: 'Login',
                              style: TextStyle(
                                color: AppTheme.primaryRedDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 500.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
