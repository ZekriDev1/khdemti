import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/theme.dart';

class ZellijBackground extends StatelessWidget {
  final Widget child;
  final bool fullScreen;

  const ZellijBackground({
    super.key, 
    required this.child, 
    this.fullScreen = false
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Animated Gradient Background
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: AppTheme.backgroundOffWhite,
          ),
        ),
        // Top right orb
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryRedDark.withOpacity(0.05),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryRedDark.withOpacity(0.1),
                  blurRadius: 100,
                  spreadRadius: 50,
                ),
              ],
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
           .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 4.seconds),
        ),
        // Bottom left orb
        Positioned(
          bottom: -50,
          left: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.cobaltBlue.withOpacity(0.05),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.cobaltBlue.withOpacity(0.1),
                  blurRadius: 100,
                  spreadRadius: 50,
                ),
              ],
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
           .scale(begin: const Offset(1, 1), end: const Offset(1.3, 1.3), duration: 5.seconds),
        ),

        // 2. Subtle Zellij Pattern Overlay
        Positioned.fill(
          child: Opacity(
            opacity: 0.03, // Very subtle
            child: CustomPaint(
              painter: _ZellijPainter(),
            ),
          ),
        ),

        // 3. Content
        SafeArea(
          bottom: !fullScreen,
          top: !fullScreen, 
          child: child,
        ),
      ],
    );
  }
}

class _ZellijPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const double unit = 60.0;
    
    // Draw a simple geometric pattern
    for (double y = 0; y < size.height; y += unit) {
      for (double x = 0; x < size.width; x += unit) {
        if ((x + y) % (unit * 2) == 0) {
           canvas.drawCircle(Offset(x, y), unit / 4, paint);
        } else {
           canvas.drawRect(Rect.fromCenter(center: Offset(x, y), width: unit / 3, height: unit / 3), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
