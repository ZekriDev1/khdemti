import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/theme.dart';
import '../../widgets/zellij_background.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundOffWhite,
      appBar: AppBar(title: const Text('Notifications'), backgroundColor: AppTheme.primaryRedDark, foregroundColor: Colors.white),
      body: ZellijBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.notifications_active_outlined, size: 100, color: Colors.grey[300]).animate().shake(delay: 500.ms),
              const SizedBox(height: 24),
              Text('No notifications yet', style: AppTheme.textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text('Updates on your bookings and offers will appear here.', style: AppTheme.textTheme.bodyMedium, textAlign: TextAlign.center),
            ],
          ).animate().fadeIn(),
        ),
      ),
    );
  }
}
