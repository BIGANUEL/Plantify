import 'package:flutter/material.dart';
import '../../domain/entities/plant.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/plantify_card.dart';
import '../../../../core/constants/app_colors.dart';

class PlantListItem extends StatelessWidget {
  final Plant plant;
  final VoidCallback onWater;
  final bool isWatering;
  final VoidCallback onTap;

  const PlantListItem({
    super.key,
    required this.plant,
    required this.onWater,
    this.isWatering = false,
    required this.onTap,
  });

  bool get _isOverdue {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final wateringDate = DateTime(
      plant.nextWateringDate.year,
      plant.nextWateringDate.month,
      plant.nextWateringDate.day,
    );
    return wateringDate.isBefore(today) || wateringDate.isAtSameMomentAs(today);
  }

  Color get _statusColor {
    if (_isOverdue) {
      return AppColors.statusRed;
    }
    final now = DateTime.now();
    final difference = plant.nextWateringDate.difference(now).inDays;
    if (difference <= 1) {
      return AppColors.statusOrange;
    }
    return AppColors.statusGreen;
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - value)),
            child: child,
          ),
        );
      },
      child: PlantifyCard(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        border: Border.all(
          color: _isOverdue
              ? AppColors.statusRed.withValues(alpha: 0.2)
              : AppColors.borderLight,
          width: 1,
        ),
        onTap: onTap,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Plant Icon Container
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.statusGreen.withValues(alpha: 0.1),
                    AppColors.statusGreen.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.statusGreen.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.eco_rounded,
                color: AppColors.statusGreen,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            // Plant Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plant.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    plant.type,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _statusColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _statusColor.withValues(alpha: 0.4),
                              blurRadius: 4,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isOverdue
                            ? 'OVERDUE'
                            : 'Next: ${DateFormatter.formatDate(plant.nextWateringDate)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: _statusColor,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Water Drop Icon Button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isWatering ? null : onWater,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isWatering
                        ? AppColors.backgroundLightGray
                        : AppColors.statusGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isWatering
                          ? AppColors.borderLight
                          : AppColors.statusGreen.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.water_drop_rounded,
                    color: isWatering
                        ? AppColors.textGray
                        : AppColors.statusGreen,
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Arrow Icon
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.borderMedium,
            ),
          ],
        ),
      ),
    );
  }
}
