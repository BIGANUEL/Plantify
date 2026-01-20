import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class PlantifyCard extends StatefulWidget {
  final Widget child;
  final Color? backgroundColor;
  final List<Color>? gradientColors;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final VoidCallback? onTap;
  final Border? border;
  final int? animationDelay;

  const PlantifyCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.gradientColors,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
    this.border,
    this.animationDelay,
  });

  @override
  State<PlantifyCard> createState() => _PlantifyCardState();
}

class _PlantifyCardState extends State<PlantifyCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    final delay = widget.animationDelay ?? 0;
    if (delay > 0) {
      Future.delayed(Duration(milliseconds: delay), () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.forward();
    }

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderRadius = widget.borderRadius ?? 20;
    final gradientColors = widget.gradientColors;
    
    final card = ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Transform.scale(
          scale: _isPressed && widget.onTap != null ? 0.97 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            margin: widget.margin ?? const EdgeInsets.all(0),
            decoration: BoxDecoration(
              gradient: gradientColors != null
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradientColors,
                    )
                  : null,
              color: gradientColors == null
                  ? (widget.backgroundColor ?? AppColors.getCardBackgroundColor(context))
                  : null,
              borderRadius: BorderRadius.circular(borderRadius),
              border: widget.border ?? Border.all(
                color: AppColors.getBorderColor(context),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.5)
                      : (gradientColors?.first ?? Colors.black)
                          .withValues(alpha: 0.08),
                  blurRadius: _isPressed ? 8 : 16,
                  offset: Offset(0, _isPressed ? 2 : 4),
                  spreadRadius: _isPressed ? 0 : 1,
                ),
              ],
            ),
            child: Padding(
              padding: widget.padding ?? const EdgeInsets.all(16),
              child: widget.child,
            ),
          ),
        ),
      ),
    );

    if (widget.onTap != null) {
      return GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onTap,
        child: Material(
          color: Colors.transparent,
          child: card,
        ),
      );
    }

    return card;
  }
}

