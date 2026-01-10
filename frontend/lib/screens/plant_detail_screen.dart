import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/plants/domain/entities/plant.dart';
import '../features/plants/presentation/bloc/plants_bloc.dart';
import '../features/plants/presentation/bloc/plants_event.dart';
import '../features/plants/presentation/bloc/plants_state.dart';
import '../core/widgets/plantify_card.dart';
import '../core/widgets/circular_progress_indicator.dart';
import '../core/widgets/simple_line_graph.dart';
import '../core/constants/app_colors.dart';
import 'edit_plant_screen.dart';

class PlantDetailScreen extends StatelessWidget {
  final Plant plant;

  const PlantDetailScreen({
    super.key,
    required this.plant,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      body: BlocBuilder<PlantsBloc, PlantsState>(
        builder: (context, state) {
          // Get updated plant from state if available
          Plant currentPlant = plant;
          if (state is PlantsLoaded) {
            try {
              final updatedPlant = state.plants.firstWhere(
                (p) => p.id == plant.id,
              );
              currentPlant = updatedPlant;
            } catch (e) {
              // Plant not found in list, use original
              currentPlant = plant;
            }
          }

          return Stack(
            children: [
              // Top section with plant image
              _buildPlantHeaderSection(context, currentPlant),
              // Bottom white card
              _buildContentCard(context, currentPlant),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlantHeaderSection(BuildContext context, Plant plant) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final wateringDate = DateTime(
      plant.nextWateringDate.year,
      plant.nextWateringDate.month,
      plant.nextWateringDate.day,
    );
    final difference = wateringDate.difference(today).inDays;
    final isThriving = difference > 1 && difference <= 7;

    return Container(
      height: MediaQuery.of(context).size.height * 0.35,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: Theme.of(context).brightness == Brightness.dark
              ? [
                  AppColors.backgroundDark,
                  AppColors.backgroundDarkGray,
                ]
              : [
                  AppColors.backgroundLightGray,
                  AppColors.backgroundWhite,
                ],
        ),
      ),
      child: Stack(
        children: [
          // Plant Image
          Positioned(
            left: -50,
            top: 0,
            bottom: 0,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              child: plant.photo != null && plant.photo!.isNotEmpty
                  ? Image.network(
                      plant.photo!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.primaryGreen.withValues(alpha: 0.1),
                          child: const Icon(
                            Icons.eco_rounded,
                            size: 150,
                            color: AppColors.primaryGreen,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: AppColors.primaryGreen.withValues(alpha: 0.1),
                      child: const Icon(
                        Icons.eco_rounded,
                        size: 150,
                        color: AppColors.primaryGreen,
                      ),
                    ),
            ),
          ),
          // Back button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.backgroundDarkCard.withValues(alpha: 0.9)
                        : AppColors.backgroundWhite.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    color: AppColors.getTextColor(context),
                    size: 20,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          // Plant name and status at bottom
          Positioned(
            left: 16,
            bottom: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plant.name,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.backgroundWhite,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.5 : 0.26),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.statusGreen.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isThriving ? 'Thriving' : 'Growing',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.backgroundWhite,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard(BuildContext context, Plant plant) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final wateringDate = DateTime(
      plant.nextWateringDate.year,
      plant.nextWateringDate.month,
      plant.nextWateringDate.day,
    );
    final difference = wateringDate.difference(today).inDays;
    final progress = (plant.wateringInterval - difference.clamp(0, plant.wateringInterval)) /
        plant.wateringInterval;

    return DraggableScrollableSheet(
      initialChildSize: 0.68,
      minChildSize: 0.68,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.getCardBackgroundColor(context),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.5 : 0.12),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.getBorderColor(context),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Next Watering
                _buildNextWatering(context, plant, difference, progress),
                const SizedBox(height: 24),
                // Environmental Info
                _buildEnvironmentalInfo(context, plant),
                const SizedBox(height: 24),
                // Growth Progress
                _buildGrowthProgress(context),
                const SizedBox(height: 24),
                // Action Buttons
                _buildActionButtons(context, plant),
                const SizedBox(height: 24),
                // Monthly Overview
                _buildMonthlyOverview(context),
                const SizedBox(height: 24),
                // Recent Activities
                _buildRecentActivities(context, plant),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNextWatering(BuildContext context, Plant plant, int days, double progress) {
    return Row(
      children: [
        Icon(
          Icons.water_drop,
          color: AppColors.waterTeal,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Next watering',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.getTextLightColor(context),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: AppColors.getBorderColor(context),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.waterTeal),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          days > 0 ? '$days days' : 'Today',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextColor(context),
          ),
        ),
      ],
    );
  }

  Widget _buildEnvironmentalInfo(BuildContext context, Plant plant) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(
                Icons.wb_sunny_outlined,
                color: AppColors.sunAmber,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                plant.light ?? 'Bright Indirect',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.getTextLightColor(context),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Icon(
                Icons.water_drop,
                color: AppColors.waterTeal,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                plant.humidity ?? '60%',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.getTextLightColor(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGrowthProgress(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Growth Progress',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextColor(context),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: PlantifyCircularProgress(
            progress: 0.75,
            size: 120,
            strokeWidth: 8,
            label: '75%',
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, Plant plant) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildActionButton(
          context: context,
          icon: Icons.water_drop,
          label: 'Water Plant',
          color: AppColors.waterTeal,
          onTap: () {
            context.read<PlantsBloc>().add(PlantWatered(plantId: plant.id));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${plant.name} marked as watered'),
                backgroundColor: AppColors.waterTeal,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          },
        ),
        _buildActionButton(
          context: context,
          icon: Icons.add,
          label: 'Add Note',
          color: AppColors.earthBrown,
          onTap: () {
            // TODO: Implement add note functionality
          },
        ),
        _buildActionButton(
          context: context,
          icon: Icons.camera_alt,
          label: 'Take Photo',
          color: AppColors.primaryGreen,
          onTap: () {
            // TODO: Implement photo functionality
          },
        ),
        _buildActionButton(
          context: context,
          icon: Icons.calendar_today,
          label: 'Edit Schedule',
          color: AppColors.sunAmber,
          onTap: () {
            final plantsBloc = context.read<PlantsBloc>();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => BlocProvider.value(
                  value: plantsBloc,
                  child: EditPlantScreen(plant: plant),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return PlantifyCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color ?? AppColors.primaryGreen,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.getTextColor(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyOverview(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monthly Overview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextColor(context),
          ),
        ),
        const SizedBox(height: 16),
        SimpleLineGraph(
          dataPoints: [],
          maxValue: 80,
          days: 30,
        ),
      ],
    );
  }

  Widget _buildRecentActivities(BuildContext context, Plant plant) {
    final activities = [
      {
        'icon': Icons.water_drop,
        'action': 'Watered plant',
        'time': '2 hours ago',
      },
      {
        'icon': Icons.add,
        'action': 'Added growth note',
        'time': '1 day ago',
      },
      {
        'icon': Icons.camera_alt,
        'action': 'Updated photo',
        'time': '2 days ago',
      },
      {
        'icon': Icons.calendar_today,
        'action': 'Adjusted schedule',
        'time': '3 days ago',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activities',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextColor(context),
          ),
        ),
        const SizedBox(height: 16),
        ...activities.map((activity) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    activity['icon'] as IconData,
                    color: AppColors.primaryGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity['action'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.getTextColor(context),
                        ),
                      ),
                      Text(
                        activity['time'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.getTextLightColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

}
