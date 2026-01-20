import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/plants/domain/entities/plant.dart';
import '../features/plants/presentation/bloc/plants_bloc.dart';
import '../features/plants/presentation/bloc/plants_event.dart';
import '../features/plants/presentation/bloc/plants_state.dart';
import '../core/widgets/plantify_card.dart';
import '../core/constants/app_colors.dart';
import 'edit_plant_screen.dart';

class PlantDetailScreen extends StatefulWidget {
  final Plant plant;

  const PlantDetailScreen({
    super.key,
    required this.plant,
  });

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  bool _isWateredToday = false;

  List<Map<String, dynamic>> _recentActivities = [];
  
  late Plant _currentPlant;

  @override
  void initState() {
    super.initState();
    _currentPlant = widget.plant;
    _recentActivities = [
      {
        'icon': Icons.calendar_today,
        'action': 'Plant added to collection',
        'timestamp': DateTime.now().subtract(const Duration(days: 7)),
      },
    ];
    _loadPersistentData();
  }

  Future<void> _loadPersistentData() async {
    final prefs = await SharedPreferences.getInstance();
    final plantId = widget.plant.id;

    final lastWateredDate = prefs.getString('plant_${plantId}_last_watered');
    if (lastWateredDate != null) {
      final lastWatered = DateTime.parse(lastWateredDate);
      final today = DateTime.now();
      final todayOnly = DateTime(today.year, today.month, today.day);
      final lastWateredOnly = DateTime(lastWatered.year, lastWatered.month, lastWatered.day);

      _isWateredToday = lastWateredOnly == todayOnly;
    }

    _recentActivities.sort((a, b) => (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));

    setState(() {});
  }

  Future<void> _saveWateredState() async {
    final prefs = await SharedPreferences.getInstance();
    final plantId = widget.plant.id;

    if (_isWateredToday) {
      await prefs.setString('plant_${plantId}_last_watered', DateTime.now().toIso8601String());
    }
  }

  void _addActivity(String action, IconData icon) {
    setState(() {
      _recentActivities.insert(0, {
        'icon': icon,
        'action': action,
        'timestamp': DateTime.now(),
      });
      if (_recentActivities.length > 5) {
        _recentActivities = _recentActivities.sublist(0, 5);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      body: BlocBuilder<PlantsBloc, PlantsState>(
        builder: (context, state) {
          if (state is PlantsLoaded) {
            try {
              final updatedPlant = state.plants.firstWhere(
                (p) => p.id == widget.plant.id,
              );
              if (mounted && (_currentPlant.light != updatedPlant.light || 
                              _currentPlant.humidity != updatedPlant.humidity ||
                              _currentPlant.careTips != updatedPlant.careTips ||
                              _currentPlant.name != updatedPlant.name ||
                              _currentPlant.type != updatedPlant.type ||
                              _currentPlant.wateringInterval != updatedPlant.wateringInterval)) {
                setState(() {
                  _currentPlant = updatedPlant;
                });
                debugPrint('[PLANT_DETAIL] Updated plant data - Light: ${updatedPlant.light}, Humidity: ${updatedPlant.humidity}');
              }
            } catch (e) {
              debugPrint('[PLANT_DETAIL] Plant not found in state, using current: ${_currentPlant.name}');
            }
          }

          return _buildPlantHeaderSection(context, _currentPlant);
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
    final isOverdue = difference < 0;
    final progress = difference <= 0 
        ? 1.0 
        : ((plant.wateringInterval - difference) / plant.wateringInterval).clamp(0.0, 1.0);

    return Container(
      height: MediaQuery.of(context).size.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/people_planting.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.3),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.black87,
                            size: 24,
                          ),
                        ),
                      ),

                      Row(
                        children: [
                          _buildHeaderActionButton(
                            icon: Icons.favorite_border,
                            activeIcon: Icons.favorite,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF4081), Color(0xFFFF6B9D)],
                            ),
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Row(
                                    children: [
                                      Icon(Icons.favorite, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text('Added to favorites! 💚'),
                                    ],
                                  ),
                                  backgroundColor: const Color(0xFFFF4081),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          _buildHeaderActionButton(
                            icon: Icons.edit_rounded,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                            ),
                          onTap: () {
                            HapticFeedback.mediumImpact();
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
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    child: Text(
                      plant.name,
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black38,
                            blurRadius: 16,
                            offset: Offset(0, 4),
                          ),
                        ],
                        height: 1.1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isOverdue
                            ? [Colors.red.withValues(alpha: 0.9), Colors.orange.withValues(alpha: 0.9)]
                            : isThriving
                                ? [Colors.green.withValues(alpha: 0.9), Colors.teal.withValues(alpha: 0.9)]
                                : [Colors.blue.withValues(alpha: 0.9), Colors.cyan.withValues(alpha: 0.9)],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.6),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isOverdue ? Colors.red : isThriving ? Colors.green : Colors.blue).withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isOverdue
                              ? Icons.warning_amber_rounded
                              : isThriving
                                  ? Icons.local_florist
                                  : Icons.grass,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isOverdue
                              ? '🚨 Needs Attention'
                              : isThriving
                                  ? '🌱 Thriving'
                                  : '🌿 Growing',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  ...(difference < 0 ? [
                    _buildPriorityAlert(context, plant, difference),
                    const SizedBox(height: 24),
                  ] : []),

                  _buildHealthStatusCard(context, plant, difference),
                  const SizedBox(height: 24),

                  _buildNextWateringCard(context, plant, difference, progress),
                  const SizedBox(height: 24),

                  _buildCareInformation(context, plant),
                  const SizedBox(height: 24),

                  _buildQuickActions(context, plant),
                  const SizedBox(height: 24),

                  _buildGrowthProgress(context),
                  const SizedBox(height: 24),

                  _buildRecentActivities(context, plant),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildHeaderActionButton({
    required IconData icon,
    IconData? activeIcon,
    LinearGradient? gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: gradient ?? LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.25),
              Colors.white.withValues(alpha: 0.15),
            ],
          ),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} Today';
    } else if (dateOnly == tomorrow) {
      return 'Tomorrow ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      final weekday = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1];
      final month = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][date.month - 1];
      return '$weekday ${date.day} $month ${date.year}';
    }
  }

  String _formatActivityTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }



  Widget _buildPriorityAlert(BuildContext context, Plant plant, int days) {
    // This alert only shows when overdue (days < 0)
    final message = "${plant.name} is ${days.abs()} days overdue for watering! 🚨";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Overdue!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Calculate new next watering date immediately (current time + interval)
              final now = DateTime.now();
              final newNextWateringDate = now.add(Duration(days: plant.wateringInterval));
              
              // Update local plant state immediately with new watering date
              setState(() {
                _isWateredToday = true;
                // Create updated plant with new nextWateringDate
                _currentPlant = Plant(
                  id: plant.id,
                  name: plant.name,
                  type: plant.type,
                  nextWateringDate: newNextWateringDate,
                  wateringInterval: plant.wateringInterval,
                  lastWateredDate: now,
                  light: plant.light,
                  humidity: plant.humidity,
                  careTips: plant.careTips,
                );
              });
              
              _saveWateredState();
              context.read<PlantsBloc>().add(PlantWatered(plantId: plant.id));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${plant.name} marked as watered! 💧'),
                  backgroundColor: AppColors.primaryGreen,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              elevation: 4,
              shadowColor: Colors.red.withValues(alpha: 0.3),
            ),
            child: const Text(
              'Water Now',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthStatusCard(BuildContext context, Plant plant, int days) {
    final isOverdue = days < 0;
    final isThriving = days > 1 && days <= 7;
    final isWateredToday = _isWateredToday;

    Color statusColor;
    String statusText;
    String statusIcon;
    String description;
    LinearGradient cardGradient;

    if (isWateredToday) {
      statusColor = const Color(0xFF2196F3);
      statusText = 'Watered';
      statusIcon = '💧';
      description = 'Your plant has been watered today';
      cardGradient = const LinearGradient(
        colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
      );
    } else if (isOverdue) {
      statusColor = const Color(0xFFFF6B6B);
      statusText = 'Needs Attention';
      statusIcon = '🚨';
      description = 'Your plant is overdue for watering';
      cardGradient = const LinearGradient(
        colors: [Color(0xFFFFE5E5), Color(0xFFFFF5F5)],
      );
    } else if (isThriving) {
      statusColor = const Color(0xFF51CF66);
      statusText = 'Thriving';
      statusIcon = '🌱';
      description = 'Your plant is healthy and growing well';
      cardGradient = const LinearGradient(
        colors: [Color(0xFFE8F5E8), Color(0xFFF1F8E9)],
      );
    } else {
      statusColor = const Color(0xFFFFA726);
      statusText = 'Growing';
      statusIcon = '🌿';
      description = 'Your plant is on schedule';
      cardGradient = const LinearGradient(
        colors: [Color(0xFFFFF8E1), Color(0xFFFFF3E0)],
      );
    }

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: PlantifyCard(
            padding: const EdgeInsets.all(20),
            backgroundColor: Colors.transparent,
            child: Container(
          decoration: BoxDecoration(
            gradient: cardGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [statusColor, statusColor.withValues(alpha: 0.8)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    statusIcon,
                    key: ValueKey<String>(statusIcon),
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        if (isThriving) ...[
                          const SizedBox(width: 8),
                          const Text('✨', style: TextStyle(fontSize: 18)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.getTextLightColor(context),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextWateringCard(BuildContext context, Plant plant, int days, double progress) {
    return PlantifyCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.waterTeal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.water_drop,
                  color: AppColors.waterTeal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Next Watering',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextColor(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      days >= 0 ? '$days days remaining' : '${days.abs()} days overdue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: days < 0 ? Colors.red : AppColors.getTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Next watering: ${_formatDate(plant.nextWateringDate)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.getTextLightColor(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        backgroundColor: AppColors.getBorderColor(context),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          days < 0 ? Colors.red : AppColors.waterTeal,
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.waterTeal.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${(progress * 100).round()}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.waterTeal,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCareInformation(BuildContext context, Plant plant) {
    return PlantifyCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Care Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextColor(context),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildCareItem(
                  context: context,
                  icon: Icons.wb_sunny_outlined,
                  title: 'Light',
                  value: plant.light ?? 'Bright Indirect',
                  color: AppColors.sunAmber,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCareItem(
                  context: context,
                  icon: Icons.thermostat,
                  title: 'Humidity',
                  value: plant.humidity ?? '60%',
                  color: AppColors.waterTeal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCareItem(
            context: context,
            icon: Icons.schedule,
            title: 'Watering Interval',
            value: '${plant.wateringInterval} days',
            color: AppColors.primaryGreen,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCareItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    bool isFullWidth = false,
  }) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.getTextColor(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                '75%',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, Plant plant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.flash_on_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextColor(context),
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
            _buildActionCard(
              context: context,
              icon: Icons.water_drop_rounded,
              label: _isWateredToday ? 'Watered Today' : 'Water Plant',
              subtitle: _isWateredToday ? '✅ Done' : 'Mark as watered',
              gradient: _isWateredToday
                  ? const LinearGradient(
                      colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : const LinearGradient(
                      colors: [Color(0xFF81C784), Color(0xFF66BB6A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              shadowColor: _isWateredToday ? const Color(0xFF2196F3) : const Color(0xFF81C784),
              onTap: () {
                HapticFeedback.mediumImpact();
                
                // Calculate new next watering date immediately (current time + interval)
                final now = DateTime.now();
                final newNextWateringDate = now.add(Duration(days: plant.wateringInterval));
                
                // Update local plant state immediately with new watering date
                setState(() {
                  _isWateredToday = true;
                  // Create updated plant with new nextWateringDate
                  _currentPlant = Plant(
                    id: plant.id,
                    name: plant.name,
                    type: plant.type,
                    nextWateringDate: newNextWateringDate,
                    wateringInterval: plant.wateringInterval,
                    lastWateredDate: now,
                    light: plant.light,
                    humidity: plant.humidity,
                    careTips: plant.careTips,
                  );
                });
                
                _saveWateredState();
                context.read<PlantsBloc>().add(PlantWatered(plantId: plant.id));
                _addActivity('Watered plant', Icons.water_drop);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.water_drop, color: Colors.white),
                        const SizedBox(width: 8),
                        Text('${plant.name} marked as watered! 💧'),
                      ],
                    ),
                    backgroundColor: const Color(0xFF4CAF50),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
            _buildActionCard(
              context: context,
              icon: Icons.edit_calendar_rounded,
              label: 'Edit Schedule',
              subtitle: 'Adjust watering',
              gradient: const LinearGradient(
                colors: [Color(0xFFBA68C8), Color(0xFF9C27B0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shadowColor: const Color(0xFFBA68C8),
              onTap: () {
                HapticFeedback.mediumImpact();
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
          },
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String subtitle,
    required LinearGradient gradient,
    Color? shadowColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (shadowColor ?? gradient.colors.first).withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: (shadowColor ?? gradient.colors.first).withValues(alpha: 0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -0.2,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.9),
                letterSpacing: -0.1,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivities(BuildContext context, Plant plant) {
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
        ..._recentActivities.map((activity) {
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
                        _formatActivityTime(activity['timestamp'] as DateTime),
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

