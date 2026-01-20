import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../features/plants/domain/entities/plant.dart';
import '../features/plants/presentation/bloc/plants_bloc.dart';
import '../features/plants/presentation/bloc/plants_event.dart';
import '../features/plants/presentation/bloc/plants_state.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_state.dart';
import '../core/widgets/plantify_header.dart';
import '../core/widgets/plantify_card.dart';
import '../core/widgets/plantify_button.dart';
import '../core/constants/app_colors.dart';
import '../core/services/weather_service.dart';
import 'add_plant_screen.dart';
import 'plant_detail_screen.dart';
import 'profile_screen.dart';
import 'reminders_screen.dart';
import 'explore_screen.dart';
import '../core/di/injection_container.dart' as di;
import '../features/explore/presentation/bloc/explore_bloc.dart';

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
  bool _showAllPlants = false;
  final ScrollController _scrollController = ScrollController();
  final Map<String, bool> _wateredTodayStatus = {};
  WeatherData? _weatherData;
  bool _isLoadingWeather = false;
  int? _previousPlantCount;

  @override
  void initState() {
    super.initState();
    _loadDarkModePreference();
    darkModeNotifier.addListener(_onDarkModeChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlantsBloc>().add(const LoadPlants());
      _fetchWeather();
    });
  }

  @override
  void dispose() {
    darkModeNotifier.removeListener(_onDarkModeChanged);
    _scrollController.dispose();
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




  Future<void> _fetchWeather() async {
    setState(() {
      _isLoadingWeather = true;
    });
    
    try {
      final weatherService = WeatherService();
      final weather = await weatherService.getCurrentWeather();
      if (mounted) {
        setState(() {
          _weatherData = weather;
          _isLoadingWeather = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingWeather = false;
        });
      }
    }
  }

  Future<void> _loadWateredStatus(List<Plant> plants) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    for (final plant in plants) {
      final lastWateredDate = prefs.getString('plant_${plant.id}_last_watered');
      if (lastWateredDate != null) {
        try {
          final lastWatered = DateTime.parse(lastWateredDate);
          final lastWateredOnly = DateTime(lastWatered.year, lastWatered.month, lastWatered.day);
          _wateredTodayStatus[plant.id] = lastWateredOnly == todayOnly;
        } catch (e) {
          _wateredTodayStatus[plant.id] = false;
        }
      } else {
        _wateredTodayStatus[plant.id] = false;
      }
    }
    setState(() {});
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
          _buildHomeTab(),
          BlocProvider(
            create: (_) => di.sl<ExploreBloc>(),
            child: const ExploreScreen(),
          ),
          const RemindersScreen(),
          ProfileScreen(
            email: widget.email,
            onLogout: widget.onLogout,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: Theme.of(context).brightness == Brightness.dark
                ? [
                    AppColors.backgroundDarkCard,
                    AppColors.backgroundDark,
                  ]
                : [
                    Colors.white,
                    AppColors.backgroundLightGray,
                  ],
          ),
          border: Border(
            top: BorderSide(
              color: AppColors.getBorderColor(context),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: Theme.of(context).brightness == Brightness.dark
                    ? 0.4
                    : 0.06,
              ),
              blurRadius: 20,
              offset: const Offset(0, -4),
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
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
            selectedFontSize: 13,
            unselectedFontSize: 12,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              letterSpacing: -0.2,
            ),
            items: [
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: _currentIndex == 0
                        ? AppColors.primaryGreen.withValues(alpha: 0.15)
                        : Colors.transparent,
                  ),
                  child: Icon(
                    _currentIndex == 0 ? Icons.home_rounded : Icons.home_outlined,
                    size: 24,
                  ),
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: _currentIndex == 1
                        ? AppColors.primaryGreen.withValues(alpha: 0.15)
                        : Colors.transparent,
                  ),
                  child: Icon(
                    _currentIndex == 1
                        ? Icons.explore_rounded
                        : Icons.explore_outlined,
                    size: 24,
                  ),
                ),
                label: 'Explore',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: _currentIndex == 2
                        ? AppColors.primaryGreen.withValues(alpha: 0.15)
                        : Colors.transparent,
                  ),
                  child: Icon(
                    _currentIndex == 2
                        ? Icons.notifications_rounded
                        : Icons.notifications_outlined,
                    size: 24,
                  ),
                ),
                label: 'Reminders',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: _currentIndex == 3
                        ? AppColors.primaryGreen.withValues(alpha: 0.15)
                        : Colors.transparent,
                  ),
                  child: Icon(
                    _currentIndex == 3
                        ? Icons.person_rounded
                        : Icons.person_outline_rounded,
                    size: 24,
                  ),
                ),
                label: 'Profile',
              ),
            ],
          ),
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
          if (state is PlantsLoaded) {
            print('([DASHBOARD] Listener received PlantsLoaded, loading watered status)');
            final currentCount = state.plants.length;
            if (_previousPlantCount != null && _previousPlantCount! > currentCount) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 12),
                      Text('Plant deleted successfully'),
                    ],
                  ),
                  backgroundColor: AppColors.primaryGreen,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }
            _previousPlantCount = currentCount;
            _loadWateredStatus(state.plants);
          }
        },
        builder: (context, state) {
          List<Plant> plants = [];
          String? wateringPlantId;

          if (state is PlantsLoaded) {
            print('([DASHBOARD] Builder received PlantsLoaded with ${state.plants.length} plants)');
            plants = state.plants;
          } else if (state is PlantWatering) {
            plants = state.plants;
            wateringPlantId = state.plantId;
          } else if (state is PlantsLoading) {
            if (plants.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
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
    
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        String? userName;
        
        if (authState is AuthAuthenticated) {
          userName = authState.user.name;
        }
        
        final displayName = userName?.isNotEmpty == true
            ? userName![0].toUpperCase() + userName.substring(1)
            : widget.email.split('@').first.isNotEmpty
                ? widget.email.split('@').first[0].toUpperCase() + widget.email.split('@').first.substring(1)
                : 'User';

        return RefreshIndicator(
          onRefresh: () async {
            context.read<PlantsBloc>().add(const PlantsRefreshed());
            await Future.delayed(const Duration(milliseconds: 500));
          },
          color: AppColors.primaryGreen,
          child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: PlantifyHeader(
              title: '$greeting, $displayName!',
              subtitle: "Here's what your plants need today",
              gradientColors: AppColors.primaryGradient,
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.backgroundWhite.withValues(alpha: 0.25),
                  border: Border.all(
                    color: AppColors.backgroundWhite.withValues(alpha: 0.4),
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppColors.backgroundWhite,
                  size: 26,
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.backgroundWhite.withValues(alpha: 0.2),
                    border: Border.all(
                      color: AppColors.backgroundWhite.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: IconButton(
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
                ),
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.backgroundWhite.withValues(alpha: 0.2),
                    border: Border.all(
                      color: AppColors.backgroundWhite.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.add_rounded,
                      color: AppColors.backgroundWhite,
                      size: 28,
                    ),
                    onPressed: () async {
                      final plantsBloc = context.read<PlantsBloc>();
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => BlocProvider.value(
                            value: plantsBloc,
                            child: const AddPlantScreen(),
                          ),
                        ),
                      );
                    },
                  ),
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
                  PlantifyCard(
                    gradientColors: AppColors.primaryGradient,
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 16),
                    animationDelay: 50,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    _isLoadingWeather
                                        ? '--°C'
                                        : '${_weatherData?.temperature.toStringAsFixed(0) ?? '24'}°C',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black26,
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isLoadingWeather
                                        ? '--%'
                                        : '${_weatherData?.humidity.toStringAsFixed(0) ?? '65'}%',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white.withValues(alpha: 0.9),
                                      shadows: const [
                                        Shadow(
                                          color: Colors.black26,
                                          blurRadius: 2,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _isLoadingWeather
                                    ? 'Loading weather...'
                                    : _weatherData != null
                                        ? WeatherService.getPlantCareMessage(
                                            _weatherData!.weatherCode,
                                            _weatherData!.temperature,
                                          )
                                        : 'Perfect day for outdoor plants!',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white.withValues(alpha: 0.95),
                                  fontWeight: FontWeight.w500,
                                  shadows: const [
                                    Shadow(
                                      color: Colors.black26,
                                      blurRadius: 2,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _weatherData != null
                                ? WeatherService.getWeatherIcon(_weatherData!.weatherCode)
                                : Icons.wb_sunny_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      ],
                    ),
                  ),

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
                            setState(() {
                              _currentIndex = 1; // Navigate to Explore tab
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24                  ),

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
                      if (plants.length > 4)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _showAllPlants = !_showAllPlants;
                            });
                          },
                          child: Text(
                            _showAllPlants ? 'See less' : 'See all',
                            style: const TextStyle(
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 12                  ),

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
                  else if (!_showAllPlants)
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
                        return _buildPlantCard(plant, wateringPlantId, index);
                      },
                    )
                  else
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6, // Fixed height that works
                      child: Scrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
                        child: GridView.builder(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 120), // Lots of bottom padding
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: plants.length,
                          itemBuilder: (context, index) {
                            final plant = plants[index];
                            return _buildPlantCard(plant, wateringPlantId, index);
                          },
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
      },
    );
  }

  Widget _buildPlantCard(Plant plant, String? wateringPlantId, int index) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final wateringDate = DateTime(
      plant.nextWateringDate.year,
      plant.nextWateringDate.month,
      plant.nextWateringDate.day,
    );
    final isOverdue = wateringDate.isBefore(today) || wateringDate.isAtSameMomentAs(today);
    final difference = plant.nextWateringDate.difference(now).inDays;

    final isWateredToday = _wateredTodayStatus[plant.id] ?? false;
    
    Color statusColor;
    String statusText;
    List<Color> gradientColors;
    
    if (isWateredToday) {
      statusColor = const Color(0xFF2196F3);
      statusText = 'Watered today';
      gradientColors = AppColors.oceanGradient;
    } else if (isOverdue) {
      statusColor = AppColors.statusRed;
      statusText = 'Needs water';
      gradientColors = [
        AppColors.statusRed,
        const Color(0xFFFF6B6B),
      ];
    } else if (difference <= 1) {
      statusColor = AppColors.statusOrange;
      statusText = 'Check soil';
      gradientColors = AppColors.sunsetGradient;
    } else {
      statusColor = AppColors.statusGreen;
      statusText = 'Well hydrated';
      gradientColors = AppColors.primaryGradient;
    }

    final cardGradient = [
      gradientColors.first.withValues(alpha: 0.08),
      gradientColors.last.withValues(alpha: 0.03),
    ];

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
        ).then((_) {
          context.read<PlantsBloc>().add(const LoadPlants());
        });
      },
      padding: const EdgeInsets.all(16),
      animationDelay: index * 100, // Staggered animation
      gradientColors: cardGradient,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        statusColor.withValues(alpha: 0.15),
                        statusColor.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.eco_rounded,
                    color: statusColor,
                    size: 56,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                plant.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextColor(context),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withValues(alpha: 0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 13,
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showDeleteConfirmation(context, plant),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.statusRed.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: AppColors.statusRed,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Plant plant) {
    final plantsBloc = context.read<PlantsBloc>();
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.statusRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.delete_outline,
                color: AppColors.statusRed,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Delete Plant',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${plant.name}"? This action cannot be undone.',
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.getTextColor(dialogContext)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              plantsBloc.add(PlantDeleted(plantId: plant.id));
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.statusRed),
            ),
          ),
        ],
      ),
    );
  }

}
