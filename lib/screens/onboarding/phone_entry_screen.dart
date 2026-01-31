import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/theme.dart';
import '../../widgets/apple_widgets.dart';
import '../../services/supabase_service.dart';
import 'verification_screen.dart';

class PhoneEntryScreen extends StatefulWidget {
  final String fullName;
  final int age;

  const PhoneEntryScreen({
    super.key,
    required this.fullName,
    required this.age,
  });

  @override
  State<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends State<PhoneEntryScreen> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendCode() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final formattedPhone = '+212$phone'; // Assuming Morocco for now based on previous context
      await SupabaseService().signInWithOtp(formattedPhone);
      
      if (!mounted) return;
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerificationScreen(
            phone: formattedPhone,
            fullName: widget.fullName,
            age: widget.age,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sending code: ${e.toString()}")),
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
              Text("Enter your phone", style: AppTheme.textTheme.displaySmall)
                  .animate().fadeIn().slideX(begin: -0.1, end: 0),
              const SizedBox(height: 8),
              Text(
                "We’ll send you a verification code.",
                style: AppTheme.textTheme.bodyMedium,
              ).animate().fadeIn(delay: 100.ms),
              
              const SizedBox(height: 32),
              
              // Country Code + Phone
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
                child: Row(
                  children: [
                    const Text("🇲🇦 +212", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    Container(width: 1, height: 24, color: Colors.grey[300]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(fontSize: 18),
                        decoration: const InputDecoration(
                          hintText: "612-456-789",
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms),
              
              const Spacer(),
              
              SizedBox(
                width: double.infinity,
                child: AppleButton(
                  onPressed: _isLoading ? null : _sendCode,
                  child: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text(
                          "Send Code",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
            ],
          ),
        ),
      ),
    );
  }
}
