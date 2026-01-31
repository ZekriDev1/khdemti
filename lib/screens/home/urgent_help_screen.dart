import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/theme.dart';
import '../../widgets/zellij_background.dart';

class UrgentHelpScreen extends StatefulWidget {
  const UrgentHelpScreen({super.key});

  @override
  State<UrgentHelpScreen> createState() => _UrgentHelpScreenState();
}

class _UrgentHelpScreenState extends State<UrgentHelpScreen> {
  String? _selectedService;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  final List<Map<String, String>> _urgentServices = [
    {"id": "plumber", "name": "Plumber", "icon": "🛠"},
    {"id": "electrician", "name": "Electrician", "icon": "⚡"},
    {"id": "locksmith", "name": "Locksmith", "icon": "🔐"},
    {"id": "glass", "name": "Glass Repair", "icon": "🪟"},
    {"id": "ac", "name": "AC Repair", "icon": "❄️"},
    {"id": "other", "name": "Other", "icon": "🔧"},
  ];

  void _submitRequest() async {
    if (_selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a service"), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isSubmitting = false);

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: AppTheme.emeraldGreen, size: 32),
              const SizedBox(width: 12),
              const Text("Request Sent!"),
            ],
          ),
          content: const Text("We are finding the nearest available provider. You will receive a call shortly."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: const Text("Urgent Help"),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: ZellijBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 32)
                        .animate(onPlay: (c) => c.repeat()).shake(delay: 1000.ms),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Emergency? We will find the nearest available provider for you immediately!",
                        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: -0.2, end: 0),
              const SizedBox(height: 24),
              Text("What do you need?", style: AppTheme.textTheme.headlineMedium),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: _urgentServices.length,
                itemBuilder: (context, index) {
                  final service = _urgentServices[index];
                  final isSelected = _selectedService == service["id"];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedService = service["id"]),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryRedDark : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryRedDark : Colors.grey.shade200,
                          width: 2,
                        ),
                        boxShadow: isSelected
                            ? [BoxShadow(color: AppTheme.primaryRedDark.withOpacity(0.3), blurRadius: 10)]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(service["icon"]!, style: const TextStyle(fontSize: 32)),
                          const SizedBox(height: 8),
                          Text(
                            service["name"]!,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: (50 * index).ms).scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
                },
              ),
              const SizedBox(height: 24),
              Text("Describe the problem (optional)", style: AppTheme.textTheme.titleLarge),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "E.g., Water leaking from the ceiling...",
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Voice recording coming soon!")),
                  );
                },
                icon: const Icon(Icons.mic),
                label: const Text("Record Voice Message"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.cobaltBlue,
                  side: const BorderSide(color: AppTheme.cobaltBlue),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("FIND HELP NOW", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ).animate().fadeIn(delay: 300.ms).shimmer(duration: 2000.ms, color: Colors.white24),
            ],
          ),
        ),
      ),
    );
  }
}
