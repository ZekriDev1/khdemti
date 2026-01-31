import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class TrackingScreen extends StatelessWidget {
  final Map<String, dynamic> booking;

  const TrackingScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundOffWhite,
      appBar: AppBar(title: const Text('Track Booking'), backgroundColor: AppTheme.primaryRedDark, foregroundColor: Colors.white),
      body: const Center(
        child: Text('Live Tracking Map Coming Soon!'),
      ),
    );
  }
}
