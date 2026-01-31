import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../utils/theme.dart';
import '../../widgets/apple_widgets.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final rawPhone = _phoneController.text.trim();
      final phone = '+212$rawPhone';
      final name = _nameController.text.trim();

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Send OTP
      await authProvider.sendOtp(phone);

      if (mounted) {
        // Navigate to OTP verification screen
        // For now, we'll show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OTP sent to $phone'),
            backgroundColor: Colors.green,
          ),
        );
        
        // TODO: Navigate to OTP screen with name parameter
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
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
                        Text(
                          'Full Name',
                          style: AppTheme.textTheme.titleLarge?.copyWith(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        AppleTextField(
                          controller: _nameController,
                          hintText: 'Enter your full name',
                          prefixIcon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Phone Number
                        Text(
                          'Phone Number',
                          style: AppTheme.textTheme.titleLarge?.copyWith(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        AppleTextField(
                          controller: _phoneController,
                          hintText: '6 XX XX XX XX',
                          prefixIcon: Icons.phone_iphone_rounded,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            if (!RegExp(r'^[67]\d{8}$').hasMatch(value)) {
                              return 'Invalid Moroccan phone number';
                            }
                            return null;
                          },
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
