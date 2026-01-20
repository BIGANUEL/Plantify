import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class PlantifyButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final bool isLoading;
  final double? height;
  final double? borderRadius;

  const PlantifyButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.isLoading = false,
    this.height,
    this.borderRadius,
  });

  @override
  State<PlantifyButton> createState() => _PlantifyButtonState();
}

class _PlantifyButtonState extends State<PlantifyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? AppColors.primaryGreen;
    final textColor = widget.textColor ?? AppColors.backgroundWhite;
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    
    // Determine gradient colors based on button color
    List<Color> gradientColors;
    if (bgColor == AppColors.primaryGreen) {
      gradientColors = AppColors.primaryGradient;
    } else if (bgColor == AppColors.waterTeal) {
      gradientColors = AppColors.oceanGradient;
    } else if (bgColor == AppColors.sunAmber) {
      gradientColors = AppColors.sunsetGradient;
    } else if (bgColor == AppColors.earthBrown) {
      gradientColors = AppColors.earthGradient;
    } else {
      gradientColors = [
        bgColor,
        bgColor.withValues(alpha: 0.8),
      ];
    }

    return GestureDetector(
      onTapDown: isEnabled ? _handleTapDown : null,
      onTapUp: isEnabled ? _handleTapUp : null,
      onTapCancel: isEnabled ? _handleTapCancel : null,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: widget.height ?? 56,
          decoration: BoxDecoration(
            gradient: isEnabled
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors,
                  )
                : null,
            color: isEnabled ? null : AppColors.borderLight,
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 16),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: gradientColors.first.withValues(alpha: 0.4),
                      blurRadius: _controller.isAnimating ? 8 : 20,
                      spreadRadius: 0,
                      offset: Offset(0, _controller.isAnimating ? 4 : 8),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          color: textColor,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                      ],
                      Text(
                        widget.text,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

