import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../widgets/zellij_background.dart';

class PromoScreen extends StatelessWidget {
  const PromoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundOffWhite,
      appBar: AppBar(title: const Text('Special Offer'), backgroundColor: AppTheme.primaryRedDark, foregroundColor: Colors.white),
      body: ZellijBackground(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.cobaltBlue,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.cleaning_services, size: 100, color: Colors.white),
              ),
              const SizedBox(height: 32),
              Text('25% OFF Home Cleaning', style: AppTheme.textTheme.headlineMedium, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              const Text(
                'Get your home sparkling clean with our top-rated professionals. \n\nUse code: SAVE25 at checkout.',
                style: TextStyle(fontSize: 16, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryRedDark,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Book Now', style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
