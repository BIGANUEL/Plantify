import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class SimpleLineGraph extends StatelessWidget {
  final List<double> dataPoints;
  final double maxValue;
  final int days;

  const SimpleLineGraph({
    super.key,
    required this.dataPoints,
    this.maxValue = 80,
    this.days = 30,
  });

  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty) {
      // Generate sample data if empty
      return _buildGraph(context, _generateSampleData());
    }
    return _buildGraph(context, dataPoints);
  }

  List<double> _generateSampleData() {
    // Generate sample data between 60-70
    return List.generate(30, (index) => 60 + (index % 11) * 0.9);
  }

  Widget _buildGraph(BuildContext context, List<double> points) {
    return Container(
        height: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.getCardBackgroundColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.getBorderColor(context),
            width: 1,
          ),
        ),
      child: CustomPaint(
        painter: _LineGraphPainter(
          context: context,
          dataPoints: points,
          maxValue: maxValue,
          lineColor: AppColors.primaryGreen,
        ),
        child: Column(
          children: [
            // Y-axis labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '80',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.getTextLightColor(context),
                  ),
                ),
                Text(
                  '60',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.getTextLightColor(context),
                  ),
                ),
                Text(
                  '40',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.getTextLightColor(context),
                  ),
                ),
                Text(
                  '20',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.getTextLightColor(context),
                  ),
                ),
                Text(
                  '0',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.getTextLightColor(context),
                  ),
                ),
              ],
            ),
            const Spacer(),
            // X-axis labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '1',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.getTextLightColor(context),
                  ),
                ),
                Text(
                  '5',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.getTextLightColor(context),
                  ),
                ),
                Text(
                  '10',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.getTextLightColor(context),
                  ),
                ),
                Text(
                  '15',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.getTextLightColor(context),
                  ),
                ),
                Text(
                  '20',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.getTextLightColor(context),
                  ),
                ),
                Text(
                  '25',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.getTextLightColor(context),
                  ),
                ),
                Text(
                  '30',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.getTextLightColor(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LineGraphPainter extends CustomPainter {
  final BuildContext context;
  final List<double> dataPoints;
  final double maxValue;
  final Color lineColor;

  _LineGraphPainter({
    required this.context,
    required this.dataPoints,
    required this.maxValue,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final gridPaint = Paint()
      ..color = AppColors.getBorderColor(context)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Draw grid lines
    for (int i = 0; i <= 4; i++) {
      final y = (size.height - 40) * (i / 4) + 20;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Draw data line
    final path = Path();
    final width = size.width;
    final height = size.height - 40; // Account for labels
    final stepX = width / (dataPoints.length - 1);

    for (int i = 0; i < dataPoints.length; i++) {
      final x = i * stepX;
      final normalizedValue = dataPoints[i] / maxValue;
      final y = height - (normalizedValue * height) + 20;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

