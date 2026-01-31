import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart'; // For accessing AuthProvider
import '../../utils/theme.dart';
import '../../widgets/apple_widgets.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';
import '../../models/user_model.dart';
import '../../services/supabase_service.dart';

class VerificationScreen extends StatefulWidget {
  final String phone;
  final String fullName;
  final int age;

  const VerificationScreen({
    super.key,
    required this.phone,
    required this.fullName,
    required this.age,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;

  Future<void> _verify() async {
    final otp = _otpController.text.trim();
    if (otp.length < 6) return;

    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      // 1. Verify OTP
      await authProvider.verifyOtp(widget.phone, otp);
      
      // 2. Create/Update Profile with Info
      // We need to ensure we have the user ID now
      final user = SupabaseService().currentUser;
      if (user != null) {
        await authProvider.updateProfile(UserModel(
          id: user.id,
          phone: widget.phone,
          fullName: widget.fullName,
          age: widget.age,
          role: UserRole.customer,
          isVerified: true, // AUTO-VERIFY on successful OTP
          createdAt: DateTime.now(),
        ));
      }

      if (!mounted) return;
      
      // 3. Navigate to Home
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        leading: const BackButton(color: AppTheme.textDark),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Verification", style: AppTheme.textTheme.displaySmall)
                  .animate().fadeIn().slideX(begin: -0.1, end: 0),
              const SizedBox(height: 8),
              Text(
                "Enter the 6-digit code sent to ${widget.phone}",
                style: AppTheme.textTheme.bodyMedium,
              ).animate().fadeIn(delay: 100.ms),
              
              const SizedBox(height: 32),
              
              // OTP Input
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                   style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  decoration: const InputDecoration(
                    hintText: "000000",
                    counterText: "",
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms),
              
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                child: AppleButton(
                  onPressed: _isLoading ? null : _verify,
                  child: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text(
                          "Verify Code",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
            ],
          ),
        ),
      ),
    );
  }
}
