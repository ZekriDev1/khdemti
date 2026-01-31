import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui'; // For verifying glass effect
import '../utils/theme.dart';

/// Button with iOS-style tap animation (scale down)
class AppleButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? backgroundColor;
  final double? width;
  final double height;
  final double borderRadius;
  final bool isGlass;

  const AppleButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
    this.width,
    this.height = 54,
    this.borderRadius = 16,
    this.isGlass = false,
  });

  @override
  State<AppleButton> createState() => _AppleButtonState();
}

class _AppleButtonState extends State<AppleButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onPressed?.call();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.isGlass 
                ? (widget.backgroundColor ?? Colors.white).withOpacity(0.2)
                : (widget.backgroundColor ?? AppTheme.primaryRedDark),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: widget.isGlass 
                ? [] 
                : [
                  BoxShadow(
                    color: (widget.backgroundColor ?? AppTheme.primaryRedDark).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
            border: widget.isGlass 
                ? Border.all(color: Colors.white.withOpacity(0.3)) 
                : null,
          ),
          child: widget.isGlass
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Center(child: widget.child),
                  ),
                )
              : Center(child: widget.child),
        ),
      ),
    );
  }
}

/// A container with a sleek shadow, rounded corners, and optional blur
class AppleCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final bool animate;

  const AppleCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    // Basic card implementation, simplified for now
    Widget card = Container(
      decoration: BoxDecoration(
        color: color ?? AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: Colors.black.withOpacity(0.05),
            highlightColor: Colors.black.withOpacity(0.02),
            child: Padding(
              padding: padding,
              child: child,
            ),
          ),
        ),
      ),
    );

    return card;
  }
}

class AppleGlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets padding;
  final double brightness;

  const AppleGlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(16),
    this.brightness = 0.7,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        color: Colors.white.withOpacity(0.05),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(brightness),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: Colors.white.withOpacity(0.4)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
