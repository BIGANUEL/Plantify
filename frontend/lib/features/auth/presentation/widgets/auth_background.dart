import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundLightGray,
      ),
      child: Stack(
        children: [
          CustomPaint(
            painter: _SubtlePatternPainter(),
            size: Size.infinite,
          ),
          // Subtle leaf pattern in corners
          Positioned(
            top: -50,
            right: -50,
            child: Opacity(
              opacity: 0.03,
              child: Icon(
                Icons.eco_rounded,
                size: 200,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Opacity(
              opacity: 0.03,
              child: Icon(
                Icons.eco_rounded,
                size: 200,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubtlePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = AppColors.primaryGreen.withValues(alpha: 0.04);

    // Subtle diagonal lines pattern
    final spacing = 40.0;
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }

    // Subtle dots pattern
    paint.style = PaintingStyle.fill;
    paint.color = AppColors.primaryGreen.withValues(alpha: 0.02);
    final dotSpacing = 60.0;
    for (double x = 0; x < size.width; x += dotSpacing) {
      for (double y = 0; y < size.height; y += dotSpacing) {
        canvas.drawCircle(Offset(x, y), 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

