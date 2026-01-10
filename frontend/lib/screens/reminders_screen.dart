import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/plants/domain/entities/plant.dart';
import '../features/plants/presentation/bloc/plants_bloc.dart';
import '../features/plants/presentation/bloc/plants_state.dart';
import '../core/widgets/plantify_card.dart';
import '../core/widgets/plantify_header.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/date_formatter.dart';
import 'plant_detail_screen.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      body: BlocBuilder<PlantsBloc, PlantsState>(
        builder: (context, state) {
          if (state is PlantsLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryGreen,
              ),
            );
          }

          if (state is PlantsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.statusRed.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.statusRed,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      state.message,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.statusRed,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          List<Plant> plants = [];
          if (state is PlantsLoaded) {
            plants = state.plants;
          } else if (state is PlantWatering) {
            plants = state.plants;
          }

          // Get future reminders (only future dates)
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final reminders = <Map<String, dynamic>>[];

          for (var plant in plants) {
            final wateringDate = DateTime(
              plant.nextWateringDate.year,
              plant.nextWateringDate.month,
              plant.nextWateringDate.day,
            );
            
            // Only include future dates
            if (wateringDate.isAfter(today)) {
              final difference = wateringDate.difference(today).inDays;
              reminders.add({
                'plant': plant,
                'date': wateringDate,
                'days': difference,
                'type': 'watering',
              });
            }
          }

          // Sort by date (earliest first)
          reminders.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

          return CustomScrollView(
            slivers: [
              // Green Header (no subtitle)
              SliverToBoxAdapter(
                child: const PlantifyHeader(
                  title: 'Reminders',
                ),
              ),
              if (reminders.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.notifications_outlined,
                              size: 80,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'No Upcoming Reminders',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.getTextColor(context),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Your upcoming watering reminders will appear here',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.getTextLightColor(context),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final reminder = reminders[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildReminderCard(context, reminder),
                        );
                      },
                      childCount: reminders.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReminderCard(BuildContext context, Map<String, dynamic> reminder) {
    final plant = reminder['plant'] as Plant;
    final days = reminder['days'] as int;
    final date = reminder['date'] as DateTime;
    
    String dueText;
    Color dueColor;
    if (days == 0) {
      dueText = 'Today';
      dueColor = AppColors.statusRed;
    } else if (days == 1) {
      dueText = 'Tomorrow';
      dueColor = AppColors.statusOrange;
    } else {
      dueText = 'In $days days';
      dueColor = AppColors.primaryGreen;
    }

    return PlantifyCard(
      padding: const EdgeInsets.all(20),
      onTap: () {
        // Navigate to plant detail
        final plantsBloc = context.read<PlantsBloc>();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BlocProvider.value(
              value: plantsBloc,
              child: PlantDetailScreen(plant: plant),
            ),
          ),
        );
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.waterTeal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.water_drop,
              color: AppColors.waterTeal,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Water ${plant.name}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextColor(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  plant.type,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.getTextLightColor(context),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: AppColors.getTextLightColor(context),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DateFormatter.formatDate(date),
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.getTextLightColor(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: dueColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              dueText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: dueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

