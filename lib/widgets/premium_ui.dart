import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';

/// A container with that premium Apple-like frosted glass effect
class PremiumGlassCard extends StatelessWidget {
  final Widget child;
  final double opacity;
  final double blur;
  final BorderRadius? borderRadius;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  const PremiumGlassCard({
    super.key,
    required this.child,
    this.opacity = 0.7,
    this.blur = 15.0,
    this.borderRadius,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(24);
    
    Widget content = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity),
            borderRadius: radius,
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return BouncyButton(onPressed: onTap!, child: content);
    }
    return content;
  }
}

/// A button that scales down slightly when pressed (Apple style)
class BouncyButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Duration duration;

  const BouncyButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.duration = const Duration(milliseconds: 150),
  });

  @override
  State<BouncyButton> createState() => _BouncyButtonState();
}

class _BouncyButtonState extends State<BouncyButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    HapticFeedback.lightImpact();
    _controller.forward();
  }

  void _onTapUp(_) {
    _controller.reverse();
    widget.onPressed();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}

/// A list where items slide in sequentially (waterfall effect)
class PremiumAnimatedList extends StatelessWidget {
  final List<Widget> children;
  final double interval;
  final bool isHorizontal;
  final EdgeInsets? padding;

  const PremiumAnimatedList({
    super.key,
    required this.children,
    this.interval = 0.05,
    this.isHorizontal = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return isHorizontal
        ? ListView.separated(
            padding: padding ?? const EdgeInsets.all(16),
            scrollDirection: Axis.horizontal,
            itemCount: children.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final delayMs = (index * interval * 1000).toInt().clamp(0, 600);
              return children[index].animate().fadeIn(duration: 400.ms, delay: Duration(milliseconds: delayMs))
                  .slideX(begin: 0.2, end: 0, curve: Curves.easeOutQuad);
            },
          )
        : ListView.separated(
            padding: padding ?? const EdgeInsets.all(16),
            itemCount: children.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final delayMs = (index * interval * 1000).toInt().clamp(0, 600);
              return children[index].animate().fadeIn(duration: 400.ms, delay: Duration(milliseconds: delayMs))
                  .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad);
            },
          );
  }
}

/// iOS-style input field
class PremiumTextField extends StatelessWidget {
  final String label;
  final IconData? icon;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType keyboardType;

  const PremiumTextField({
    super.key,
    required this.label,
    this.icon,
    required this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade500),
          prefixIcon: icon != null ? Icon(icon, color: Colors.grey.shade400) : null,
          prefixIconConstraints: const BoxConstraints(minWidth: 40),
        ),
      ),
    );
  }
}
