import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/apple_widgets.dart'; // Using Apple Widgets
import '../home/home_screen.dart';
import 'verify_otp_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LoginScreenContent();
  }
}

class _LoginScreenContent extends StatefulWidget {
  const _LoginScreenContent();

  @override
  State<_LoginScreenContent> createState() => _LoginScreenContentState();
}

class _LoginScreenContentState extends State<_LoginScreenContent> {
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final rawPhone = _phoneController.text.trim().replaceAll(RegExp(r'^0+'), '');
    final phone = '+212$rawPhone';
    
    // BYPASS & PERSIST: Skip OTP for super admin number
    if (rawPhone == '613415008') {
      await Provider.of<AuthProvider>(context, listen: false).loginAdminLocally();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
      return;
    }

    try {
      await Provider.of<AuthProvider>(context, listen: false).signInWithOtp(phone);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VerifyOtpScreen(phone: phone)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<AuthProvider>(context).isLoading;

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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryRedDark.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.handyman_rounded, size: 50, color: AppTheme.primaryRedDark),
                    ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  Text(
                    'Welcome Back',
                    textAlign: TextAlign.center,
                    style: AppTheme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
                  ).animate().fadeIn().moveY(begin: 10, end: 0),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Login to ask for a service',
                    textAlign: TextAlign.center,
                    style: AppTheme.textTheme.bodyMedium,
                  ).animate().fadeIn(delay: 200.ms),
                  
                  const SizedBox(height: 48),
                  
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Phone Number', style: AppTheme.textTheme.titleLarge?.copyWith(fontSize: 16)),
                        const SizedBox(height: 12),
                        AppleTextField(
                          controller: _phoneController,
                          hintText: '6 XX XX XX XX',
                          prefixIcon: Icons.phone_iphone_rounded,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                             if (value == null || value.isEmpty) return 'Please enter your number';
                             if (value.length < 9) return 'Invalid number';
                             return null;
                          },
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms),
                  
                  const SizedBox(height: 32),
                  
                  SizedBox(
                    height: 56,
                    child: AppleButton(
                      onPressed: isLoading ? null : _submit,
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Send Code',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                    ),
                  ).animate().fadeIn(delay: 600.ms),
                  
                  const SizedBox(height: 24),
                  
                  const Text(
                    'By continuing, you agree to our Terms & Conditions.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
