import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../features/plants/domain/entities/plant.dart';
import '../features/plants/presentation/bloc/plants_bloc.dart';
import '../features/plants/presentation/bloc/plants_event.dart';
import '../features/plants/presentation/bloc/plants_state.dart';
import '../core/widgets/plantify_header.dart';
import '../core/widgets/plantify_card.dart';
import '../core/widgets/plantify_button.dart';
import '../core/constants/app_colors.dart';
import 'add_plant_screen.dart';
import 'plant_detail_screen.dart';
import 'profile_screen.dart';
import 'reminders_screen.dart';
import 'explore_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String email;
  final VoidCallback onLogout;

  const DashboardScreen({
    super.key,
    required this.email,
    required this.onLogout,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadDarkModePreference();
    // Listen to dark mode changes
    darkModeNotifier.addListener(_onDarkModeChanged);
    // Load plants when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlantsBloc>().add(const LoadPlants());
    });
  }

  @override
  void dispose() {
    darkModeNotifier.removeListener(_onDarkModeChanged);
    super.dispose();
  }

  void _onDarkModeChanged() {
    setState(() {
      _isDarkMode = darkModeNotifier.value;
    });
  }

  Future<void> _loadDarkModePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('plantify_dark_mode') ?? false;
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }



  void _handleWaterPlant(String plantId, String plantName) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.water_drop,
                  color: AppColors.primaryGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Water Plant',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Mark $plantName as Watered?',
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<PlantsBloc>().add(PlantWatered(plantId: plantId));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: AppColors.backgroundWhite,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Confirm',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      backgroundColor: AppColors.getBackgroundColor(context),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Home Tab
          _buildHomeTab(),
          // Explore Tab
          const ExploreScreen(),
          // Reminders Tab
          const RemindersScreen(),
          // Profile Tab
          ProfileScreen(
            email: widget.email,
            onLogout: widget.onLogout,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.backgroundDarkCard
              : Colors.white,
          border: Border(
            top: BorderSide(
              color: AppColors.getBorderColor(context),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primaryGreen,
          unselectedItemColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors.textDarkModeLight
              : const Color(0xFF94A3B8),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            letterSpacing: -0.2,
          ),
          items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'Reminders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return BlocConsumer<PlantsBloc, PlantsState>(
        listener: (context, state) {
          if (state is PlantsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PlantsLoading && state is! PlantWatering) {
            return const Center(
              child: CircularProgressIndicator(),
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
                        color: Colors.red.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      state.message,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<PlantsBloc>().add(const LoadPlants());
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          List<Plant> plants = [];
          String? wateringPlantId;

          if (state is PlantsLoaded) {
            plants = state.plants;
          } else if (state is PlantWatering) {
            plants = state.plants;
            wateringPlantId = state.plantId;
          }

          return _buildHomeLayout(plants, wateringPlantId);
        },
      );
  }

  Widget _buildHomeLayout(List<Plant> plants, String? wateringPlantId) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';
    
    // Extract name from email (before @)
    final userName = widget.email.split('@').first;
    final displayName = userName.isNotEmpty
        ? userName[0].toUpperCase() + userName.substring(1)
        : 'User';

    return RefreshIndicator(
      onRefresh: () async {
        context.read<PlantsBloc>().add(const PlantsRefreshed());
        await Future.delayed(const Duration(milliseconds: 500));
      },
      color: AppColors.primaryGreen,
      child: CustomScrollView(
        slivers: [
          // Green Header with greeting
          SliverToBoxAdapter(
            child: PlantifyHeader(
              title: '$greeting, $displayName!',
              subtitle: "Here's what your plants need today",
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.backgroundWhite.withValues(alpha: 0.2),
                  border: Border.all(
                    color: AppColors.backgroundWhite.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.backgroundWhite,
                  size: 24,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.backgroundWhite,
                    size: 24,
                  ),
                  onPressed: () {
                    setState(() {
                      _currentIndex = 1;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.add_rounded,
                    color: AppColors.backgroundWhite,
                    size: 28,
                  ),
                  onPressed: () {
                    final plantsBloc = context.read<PlantsBloc>();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => BlocProvider.value(
                          value: plantsBloc,
                          child: const AddPlantScreen(),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Weather Info Card
                  PlantifyCard(
                    backgroundColor: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.backgroundDarkCard
                        : AppColors.cardWarmBeige,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '24°C',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.getTextColor(context),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '65%',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.getTextLightColor(context),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Perfect day for outdoor plants!',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.getTextLightColor(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.cloud_outlined,
                          color: AppColors.primaryGreen,
                          size: 32,
                        ),
                      ],
                    ),
                  ),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: PlantifyButton(
                          text: 'Water Plants',
                          icon: Icons.water_drop,
                          backgroundColor: _isDarkMode 
                              ? const Color(0xFF87CEEB) // Light blue for dark mode
                              : AppColors.waterTeal,
                          onPressed: plants.isNotEmpty
                              ? () {
                                  // Water the first plant that needs water, or show dialog
                                  final plantNeedingWater = plants.firstWhere(
                                    (p) {
                                      final now = DateTime.now();
                                      final today = DateTime(now.year, now.month, now.day);
                                      final wateringDate = DateTime(
                                        p.nextWateringDate.year,
                                        p.nextWateringDate.month,
                                        p.nextWateringDate.day,
                                      );
                                      return wateringDate.isBefore(today) ||
                                          wateringDate.isAtSameMomentAs(today);
                                    },
                                    orElse: () => plants.first,
                                  );
                                  _handleWaterPlant(plantNeedingWater.id, plantNeedingWater.name);
                                }
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: PlantifyButton(
                          text: 'Diagnose',
                          icon: Icons.medical_services_outlined,
                          backgroundColor: AppColors.earthBrown,
                          onPressed: () {
                            // Diagnose logic
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // My Plants Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Plants (${plants.length})',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.getTextColor(context),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Show all plants
                        },
                        child: const Text(
                          'See all',
                          style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Plants Grid
                  if (plants.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.eco_outlined,
                                size: 80,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Text(
                              'No plants yet',
                              style: TextStyle(
                                fontSize: 24,
                                color: AppColors.getTextColor(context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Tap the button above to add your first plant',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.getTextLightColor(context),
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: plants.length > 4 ? 4 : plants.length,
                      itemBuilder: (context, index) {
                        final plant = plants[index];
                        return _buildPlantCard(plant, wateringPlantId);
                      },
                    ),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantCard(Plant plant, String? wateringPlantId) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final wateringDate = DateTime(
      plant.nextWateringDate.year,
      plant.nextWateringDate.month,
      plant.nextWateringDate.day,
    );
    final isOverdue = wateringDate.isBefore(today) || wateringDate.isAtSameMomentAs(today);
    final difference = plant.nextWateringDate.difference(now).inDays;
    
    Color statusColor;
    String statusText;
    if (isOverdue) {
      statusColor = AppColors.statusRed;
      statusText = 'Needs water';
    } else if (difference <= 1) {
      statusColor = AppColors.statusOrange;
      statusText = 'Check soil';
    } else {
      statusColor = AppColors.statusGreen;
      statusText = 'Well hydrated';
    }

    return PlantifyCard(
      onTap: () {
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
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plant Image Placeholder
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.eco_rounded,
                color: AppColors.primaryGreen,
                size: 48,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            plant.name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextColor(context),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


}
