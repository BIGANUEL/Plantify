import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AuthBackground extends StatefulWidget {
  const AuthBackground({super.key});

  @override
  State<AuthBackground> createState() => _AuthBackgroundState();
}

class _AuthBackgroundState extends State<AuthBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Create animated gradient that shifts colors
        final gradientColors = [
          Color.lerp(
            AppColors.primaryGreen,
            AppColors.waterTeal,
            _animation.value * 0.3,
          )!,
          Color.lerp(
            AppColors.waterTeal,
            AppColors.primaryGreen,
            _animation.value * 0.3,
          )!,
          Color.lerp(
            AppColors.primaryGreenLight,
            AppColors.waterTealLight,
            _animation.value * 0.2,
          )!,
        ];

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      AppColors.backgroundDark,
                      AppColors.backgroundDarkGray,
                      AppColors.backgroundDark,
                    ]
                  : [
                      AppColors.backgroundLightGray,
                      ...gradientColors.map((c) => c.withValues(alpha: 0.05)),
                      AppColors.backgroundLightGray,
                    ],
            ),
          ),
          child: Stack(
            children: [
              CustomPaint(
                painter: _SubtlePatternPainter(
                  animationValue: _animation.value,
                ),
                size: Size.infinite,
              ),
              // Animated leaf patterns in corners
              Positioned(
                top: -50 + (_animation.value * 20),
                right: -50 + (_animation.value * 10),
                child: Transform.rotate(
                  angle: _animation.value * 0.5,
                  child: Opacity(
                    opacity: 0.06,
                    child: Icon(
                      Icons.eco_rounded,
                      size: 250,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -50 - (_animation.value * 20),
                left: -50 - (_animation.value * 10),
                child: Transform.rotate(
                  angle: -_animation.value * 0.5,
                  child: Opacity(
                    opacity: 0.06,
                    child: Icon(
                      Icons.eco_rounded,
                      size: 250,
                      color: AppColors.waterTeal,
                    ),
                  ),
                ),
              ),
              // Additional decorative elements
              Positioned(
                top: 100,
                left: 50 + (_animation.value * 30),
                child: Opacity(
                  opacity: 0.04,
                  child: Icon(
                    Icons.water_drop_rounded,
                    size: 120,
                    color: AppColors.waterTeal,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SubtlePatternPainter extends CustomPainter {
  final double animationValue;

  _SubtlePatternPainter({this.animationValue = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = AppColors.primaryGreen.withValues(
        alpha: 0.04 + (animationValue * 0.02),
      );

    // Subtle diagonal lines pattern with animation
    final spacing = 40.0;
    final offset = animationValue * spacing;
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i + offset, 0),
        Offset(i + size.height + offset, size.height),
        paint,
      );
    }

    // Subtle dots pattern
    paint.style = PaintingStyle.fill;
    paint.color = AppColors.primaryGreen.withValues(
      alpha: 0.02 + (animationValue * 0.01),
    );
    final dotSpacing = 60.0;
    final dotOffset = animationValue * dotSpacing * 0.3;
    for (double x = 0; x < size.width + dotSpacing; x += dotSpacing) {
      for (double y = 0; y < size.height + dotSpacing; y += dotSpacing) {
        canvas.drawCircle(
          Offset(x + dotOffset, y + dotOffset * 0.5),
          2,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_SubtlePatternPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

