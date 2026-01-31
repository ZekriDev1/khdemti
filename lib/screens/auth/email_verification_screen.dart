import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/apple_widgets.dart';
import '../home/home_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  
  const EmailVerificationScreen({super.key, required this.email});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  Timer? _timer;
  bool _canResend = false;
  int _countdown = 60;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    _checkVerificationPeriodically();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdown = 60;
    _canResend = false;
    _timer?.cancel();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  void _checkVerificationPeriodically() {
    Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isVerified = await authProvider.checkEmailVerified();
      
      if (isVerified && mounted) {
        timer.cancel();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    });
  }

  Future<void> _resendEmail() async {
    try {
      await Provider.of<AuthProvider>(context, listen: false).sendEmailVerification();
      _startCountdown();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification email sent!')),
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

  Future<void> _checkNow() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isVerified = await authProvider.checkEmailVerified();
    
    if (isVerified && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email not verified yet. Please check your inbox.')),
      );
    }
  }

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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Email Icon
                  Container(
                    width: 120,
                    height: 120,
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
                    child: const Icon(Icons.mark_email_unread_rounded, size: 60, color: AppTheme.primaryRedDark),
                  ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                  
                  const SizedBox(height: 32),
                  
                  Text(
                    'Verify Your Email',
                    textAlign: TextAlign.center,
                    style: AppTheme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
                  ).animate().fadeIn().moveY(begin: 10, end: 0),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    'We sent a verification link to:',
                    textAlign: TextAlign.center,
                    style: AppTheme.textTheme.bodyMedium,
                  ).animate().fadeIn(delay: 200.ms),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    widget.email,
                    textAlign: TextAlign.center,
                    style: AppTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryRedDark,
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                  
                  const SizedBox(height: 32),
                  
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700, size: 32),
                        const SizedBox(height: 12),
                        Text(
                          'Click the link in your email to verify your account.\n\nThe page will automatically refresh when verified.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.blue.shade900, fontSize: 14),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms),
                  
                  const SizedBox(height: 48),
                  
                  SizedBox(
                    height: 56,
                    width: double.infinity,
                    child: AppleButton(
                      onPressed: _checkNow,
                      child: const Text(
                        'I\'ve Verified - Continue',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ).animate().fadeIn(delay: 600.ms),
                  
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    height: 56,
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _canResend ? _resendEmail : null,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        side: BorderSide(color: _canResend ? AppTheme.primaryRedDark : Colors.grey),
                      ),
                      child: Text(
                        _canResend ? 'Resend Email' : 'Resend in ${_countdown}s',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _canResend ? AppTheme.primaryRedDark : Colors.grey,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 700.ms),
                  
                  const SizedBox(height: 24),
                  
                  TextButton(
                    onPressed: () {
                      Provider.of<AuthProvider>(context, listen: false).signOut();
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: const Text(
                      'Sign out',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
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
