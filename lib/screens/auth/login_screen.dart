import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/apple_widgets.dart'; // Using Apple Widgets
import '../home/home_screen.dart';
import 'verify_otp_screen.dart';
import 'forgot_password_screen.dart';

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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Quick Admin Bypass using a specific hardcoded email for ease of access during testing if needed
    // Assuming 'admin@khdemti.com' is the convention, but let's stick to standard auth for now unless requested.
    
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      await Provider.of<AuthProvider>(context, listen: false).signInWithEmail(email, password);
      // If successful, the AuthWrapper in main.dart will handle the navigation to HomeScreen
      // But we can also force it here to be safe or show a success message
      if (mounted) {
         // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
         // Using AuthWrapper logic is better, but let's pop if we were pushed here. 
         // Actually, this is usually a root screen.
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Failed: ${e.toString()}')),
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
                    'Login with your email to continue',
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
                        
                        const SizedBox(height: 24),
                        
                        Text('Password', style: AppTheme.textTheme.titleLarge?.copyWith(fontSize: 16)),
                        const SizedBox(height: 12),
                        AppleTextField(
                          controller: _passwordController,
                          hintText: '••••••••',
                          prefixIcon: Icons.lock_rounded,
                          obscureText: true,
                          validator: (value) {
                             if (value == null || value.isEmpty) return 'Please enter your password';
                             if (value.length < 6) return 'Password too short';
                             return null;
                          },
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Forgot Password Link
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ForgotPasswordScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: AppTheme.primaryRedDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
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
                              'Sign In',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                    ),
                  ).animate().fadeIn(delay: 600.ms),
                  
                  const SizedBox(height: 16),
                  
                  // Google Sign In Button
                  SizedBox(
                    height: 56,
                    child: OutlinedButton(
                      onPressed: isLoading ? null : _submitGoogle,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        side: const BorderSide(color: Colors.grey),
                        backgroundColor: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                       // Using a generic G icon if asset not available, but usually we'd use an asset
                          const Icon(Icons.g_mobiledata, size: 32, color: Colors.blue), // Placeholder icon
                          const SizedBox(width: 8),
                          const Text(
                            'Continue with Google',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 700.ms),

                  const SizedBox(height: 16),

                  // Magic Link Button
                  SizedBox(
                    height: 56,
                    child: OutlinedButton(
                      onPressed: isLoading ? null : _submitMagicLink,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        side: const BorderSide(color: Colors.grey),
                        backgroundColor: Colors.white,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.email_outlined, size: 28, color: Colors.purple),
                          SizedBox(width: 8),
                          Text(
                            'Sign in with Magic Link',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 800.ms),

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
  
  Future<void> _submitGoogle() async {
    try {
      await Provider.of<AuthProvider>(context, listen: false).signInWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google Sign In Failed: $e')),
        );
      }
    }
  }

  Future<void> _submitMagicLink() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address first')),
       );
       return;
    }
    
    try {
      await Provider.of<AuthProvider>(context, listen: false).sendMagicLink(email);
      if (mounted) {
         showDialog(
           context: context, 
           builder: (c) => AlertDialog(
             title: const Text('Check your email'),
             content: Text('We sent a sign-in link to $email'),
             actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('OK'))],
           ),
         );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send link: $e')),
        );
      }
    }
  }
}
