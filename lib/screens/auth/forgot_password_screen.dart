import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/apple_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();

    try {
      await Provider.of<AuthProvider>(context, listen: false)
          .sendPasswordResetEmail(email);
      
      if (mounted) {
        setState(() => _emailSent = true);
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
              child: _emailSent ? _buildSuccessView() : _buildFormView(isLoading),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView(bool isLoading) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Icon
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
            child: const Icon(Icons.lock_reset_rounded, size: 50, color: AppTheme.primaryRedDark),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
        ),
        
        const SizedBox(height: 32),
        
        Text(
          'Forgot Password?',
          textAlign: TextAlign.center,
          style: AppTheme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
        ).animate().fadeIn().moveY(begin: 10, end: 0),
        
        const SizedBox(height: 8),
        
        Text(
          'Enter your email to receive a password reset link',
          textAlign: TextAlign.center,
          style: AppTheme.textTheme.bodyMedium,
        ).animate().fadeIn(delay: 200.ms),
        
        const SizedBox(height: 48),
        
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    'Send Reset Link',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
          ),
        ).animate().fadeIn(delay: 600.ms),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check_circle_rounded, size: 60, color: Colors.green.shade600),
        ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
        
        const SizedBox(height: 32),
        
        Text(
          'Email Sent!',
          style: AppTheme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        
        const SizedBox(height: 16),
        
        Text(
          'Check your email for a password reset link.\nThe link will expire in 1 hour.',
          textAlign: TextAlign.center,
          style: AppTheme.textTheme.bodyMedium,
        ),
        
        const SizedBox(height: 48),
        
        SizedBox(
          height: 56,
          width: double.infinity,
          child: AppleButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Back to Login',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
