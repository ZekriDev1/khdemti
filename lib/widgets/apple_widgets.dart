import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

/// iOS-style Text Field with soft background and no borders
class AppleTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? prefixIcon;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final Widget? suffixIcon;
  final int maxLines;

  const AppleTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.suffixIcon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        onChanged: onChanged,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 16, color: AppTheme.textDark),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppTheme.textGrey) : null,
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}

/// Simple iOS-style Header (non-sliver)
class AppleHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool showBack;

  const AppleHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.showBack = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (showBack)
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppTheme.textDark),
                    ),
                  ),
                ),
              if (trailing != null) trailing!,
            ],
          ),
          if (showBack || trailing != null) const SizedBox(height: 16),
          Text(
            title,
            style: AppTheme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.textGrey),
            ),
          ],
        ],
      ),
    );
  }
}
