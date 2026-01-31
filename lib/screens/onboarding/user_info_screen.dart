import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/theme.dart';
import '../../widgets/apple_widgets.dart';
import '../../widgets/premium_ui.dart'; // Ensure correct import for text fields if needed, or use Apple style
import 'phone_entry_screen.dart'; // We will create this next

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  bool _isValid = false;

  void _validate() {
    setState(() {
      _isValid = _nameController.text.trim().isNotEmpty && 
                 _ageController.text.trim().isNotEmpty;
    });
  }

  void _next() {
    if (_isValid) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhoneEntryScreen(
            fullName: _nameController.text.trim(),
            age: int.tryParse(_ageController.text.trim()) ?? 18,
          ),
        ),
      );
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
              Text("Tell us about you", style: AppTheme.textTheme.displaySmall)
                  .animate().fadeIn().slideX(begin: -0.1, end: 0),
              const SizedBox(height: 8),
              Text(
                "We need a few details to personalize your experience.",
                style: AppTheme.textTheme.bodyMedium,
              ).animate().fadeIn(delay: 100.ms),
              
              const SizedBox(height: 32),
              
              _buildInput("Full Name", _nameController, TextInputType.name, "Akram Zekri")
                  .animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 20),
              _buildInput("Age", _ageController, TextInputType.number, "25")
                  .animate().fadeIn(delay: 300.ms),
              
              const Spacer(),
              
              SizedBox(
                width: double.infinity,
                child: AppleButton(
                  onPressed: _isValid ? _next : null,
                  backgroundColor: _isValid ? AppTheme.primaryRedDark : Colors.grey[300],
                  child: Text(
                    "Continue",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _isValid ? Colors.white : Colors.grey[500],
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, TextInputType type, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.textTheme.titleLarge?.copyWith(fontSize: 16)),
        const SizedBox(height: 8),
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
          child: TextField(
            controller: controller,
            keyboardType: type,
            onChanged: (v) => _validate(),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400]),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
