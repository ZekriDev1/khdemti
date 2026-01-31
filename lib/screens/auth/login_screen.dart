import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/zellij_background.dart';
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
    final phone = '+212' + rawPhone;
    
    // BYPASS & PERSIST: Skip OTP for super admin number
    if (rawPhone == '691157363') {
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
          SnackBar(content: Text('Error: ' + e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<AuthProvider>(context).isLoading;

    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: ZellijBackground(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.handyman_rounded, size: 80, color: AppTheme.primaryRedDark)
                  .animate().scale(duration: 600.ms, curve: Curves.elasticOut),
              const SizedBox(height: 24),
              Text(
                'Welcome to Khdemti',
                textAlign: TextAlign.center,
                style: AppTheme.textTheme.displaySmall,
              ).animate().fadeIn().moveY(begin: 20, end: 0),
              const SizedBox(height: 8),
              Text(
                'Enter your phone number to continue',
                textAlign: TextAlign.center,
                style: AppTheme.textTheme.bodyMedium,
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 48),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Phone Number', style: AppTheme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(fontSize: 18, letterSpacing: 1.2),
                      decoration: const InputDecoration(
                        prefixText: '+212 ',
                        prefixStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        hintText: '6 XX XX XX XX',
                        prefixIcon: Icon(Icons.phone_iphone_rounded),
                      ),
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
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Send Code',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
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
    );
  }
}
