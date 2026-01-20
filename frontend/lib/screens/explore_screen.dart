import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/widgets/plantify_header.dart';
import '../core/constants/app_colors.dart';
import '../features/explore/presentation/bloc/explore_bloc.dart';
import '../features/explore/presentation/bloc/explore_event.dart';
import '../features/explore/presentation/bloc/explore_state.dart';
import '../features/explore/domain/entities/explore_plant.dart';
import '../features/explore/domain/entities/problem.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Plants tab state
  final TextEditingController _plantsSearchController = TextEditingController();
  String _plantsSearchQuery = '';
  String _selectedPlantCategory = 'All';
  
  // Problems tab state
  final TextEditingController _problemsSearchController = TextEditingController();
  String _problemsSearchQuery = '';
  String _selectedProblemCategory = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _plantsSearchController.addListener(_onPlantsSearchChanged);
    _problemsSearchController.addListener(_onProblemsSearchChanged);
    _tabController.addListener(() {
      setState(() {});
    });
    
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExploreBloc>().add(const LoadExplorePlants());
      context.read<ExploreBloc>().add(const LoadProblems());
    });
  }

  void _onPlantsSearchChanged() {
    final query = _plantsSearchController.text;
    setState(() {
      _plantsSearchQuery = query.toLowerCase();
    });
    // Debounce search - reload after user stops typing
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && _plantsSearchController.text == query) {
        context.read<ExploreBloc>().add(
          LoadExplorePlants(
            category: _selectedPlantCategory == 'All' ? null : _selectedPlantCategory,
            search: query.isEmpty ? null : query,
          ),
        );
      }
    });
  }

  void _onProblemsSearchChanged() {
    final query = _problemsSearchController.text;
    setState(() {
      _problemsSearchQuery = query.toLowerCase();
    });
    // Debounce search - reload after user stops typing
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && _problemsSearchController.text == query) {
        context.read<ExploreBloc>().add(
          LoadProblems(
            category: _selectedProblemCategory == 'All' ? null : _selectedProblemCategory,
            search: query.isEmpty ? null : query,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _plantsSearchController.dispose();
    _problemsSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      body: Column(
        children: [
          // Beautiful Gradient Header
          PlantifyHeader(
            title: 'Explore',
            gradientColors: AppColors.oceanGradient,
          ),
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              color: AppColors.getCardBackgroundColor(context),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.getBorderColor(context),
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primaryGreen,
              labelColor: AppColors.primaryGreen,
              unselectedLabelColor: AppColors.getTextLightColor(context),
              labelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.3,
              ),
              indicatorWeight: 2.5,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(text: 'Plants'),
                Tab(text: 'Problems'),
              ],
            ),
          ),
          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPlantsTab(),
                _buildProblemsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper to convert icon string to IconData
  IconData _getIconData(String? iconName) {
    if (iconName == null) return Icons.grass_rounded;
    
    final iconMap = {
      'grass_rounded': Icons.grass_rounded,
      'park_rounded': Icons.park_rounded,
      'eco_rounded': Icons.eco_rounded,
      'local_florist_rounded': Icons.local_florist_rounded,
      'water_drop_rounded': Icons.water_drop_rounded,
      'forest_rounded': Icons.forest_rounded,
      'nature_rounded': Icons.nature_rounded,
      'healing_rounded': Icons.healing_rounded,
      'diamond_rounded': Icons.diamond_rounded,
      'spa_rounded': Icons.spa_rounded,
      'lunch_dining_rounded': Icons.lunch_dining_rounded,
      'bug_report_rounded': Icons.bug_report_rounded,
      'warning_rounded': Icons.warning_rounded,
      'circle_rounded': Icons.circle_rounded,
      'water_damage_rounded': Icons.water_damage_rounded,
      'arrow_downward_rounded': Icons.arrow_downward_rounded,
      'science_rounded': Icons.science_rounded,
      'brightness_1_rounded': Icons.brightness_1_rounded,
      'bloodtype_rounded': Icons.bloodtype_rounded,
      'pest_control_rounded': Icons.pest_control_rounded,
      'shield_rounded': Icons.shield_rounded,
    };
    
    return iconMap[iconName] ?? Icons.grass_rounded;
  }

  // Helper to parse color string to Color
  Color _parseColor(String? colorString) {
    if (colorString == null) return AppColors.statusRed;
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppColors.statusRed;
    }
  }

  Widget _buildPlantsTab() {
    final plantCategories = ['All', 'Indoor', 'Outdoor', 'Low Maintenance', 'Pet Safe', 'Flowering'];
    
    return BlocBuilder<ExploreBloc, ExploreState>(
      builder: (context, state) {
        List<ExplorePlant> plants = [];
        bool isLoading = false;
        String? errorMessage;

        if (state is ExploreLoading) {
          isLoading = true;
        } else if (state is ExplorePlantsLoaded) {
          plants = state.plants;
        } else if (state is ExploreError) {
          errorMessage = state.message;
        }

        // Keep showing previous plants while loading new ones (unless it's initial load)
        final hasPlants = plants.isNotEmpty;

        return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.getCardBackgroundColor(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.getBorderColor(context),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _plantsSearchController,
              decoration: InputDecoration(
                hintText: 'Search plants...',
                hintStyle: TextStyle(
                  color: AppColors.getTextLightColor(context),
                  fontSize: 15,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: AppColors.getTextLightColor(context),
                  size: 22,
                ),
                suffixIcon: _plantsSearchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear_rounded,
                          color: AppColors.getTextLightColor(context),
                          size: 20,
                        ),
                        onPressed: () {
                          _plantsSearchController.clear();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              style: TextStyle(
                color: AppColors.getTextColor(context),
                fontSize: 15,
              ),
            ),
          ),
        ),
        
        // Category Chips
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: plantCategories.length,
            itemBuilder: (context, index) {
              final category = plantCategories[index];
              final isSelected = _selectedPlantCategory == category;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  selected: isSelected,
                  label: Text(category),
                  onSelected: (selected) {
                    setState(() {
                      _selectedPlantCategory = category;
                    });
                    // Reload plants with new category
                    context.read<ExploreBloc>().add(
                      LoadExplorePlants(
                        category: category == 'All' ? null : category,
                        search: _plantsSearchQuery.isEmpty ? null : _plantsSearchQuery,
                      ),
                    );
                  },
                  backgroundColor: AppColors.getCardBackgroundColor(context),
                  selectedColor: AppColors.primaryGreen.withValues(alpha: 0.15),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? AppColors.primaryGreen
                        : AppColors.getTextColor(context),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 13,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primaryGreen
                        : AppColors.getBorderColor(context),
                    width: isSelected ? 1.5 : 1,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Plants List
        Expanded(
          child: isLoading && !hasPlants
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryGreen,
                  ),
                )
              : errorMessage != null && !hasPlants
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 64,
                            color: AppColors.statusRed,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading plants',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.getTextColor(context),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            errorMessage,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.getTextLightColor(context),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<ExploreBloc>().add(
                                LoadExplorePlants(
                                  category: _selectedPlantCategory == 'All' ? null : _selectedPlantCategory,
                                  search: _plantsSearchQuery.isEmpty ? null : _plantsSearchQuery,
                                ),
                              );
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : plants.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 64,
                                color: AppColors.getTextLightColor(context),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No plants found',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.getTextColor(context),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try adjusting your search or filters',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.getTextLightColor(context),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: plants.length,
                          itemBuilder: (context, index) {
                            final plant = plants[index];
                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: Duration(milliseconds: 300 + (index * 50)),
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
                              child: _buildPlantCard(plant, index),
                            );
                          },
                        ),
        ),
      ],
    );
      },
    );
  }

  Widget _buildPlantCard(ExplorePlant plant, int index) {
    final tags = plant.tags;
    final difficulty = plant.difficulty;
    final difficultyColor = difficulty == 'Easy'
        ? AppColors.statusGreen
        : difficulty == 'Moderate'
            ? AppColors.statusOrange
            : AppColors.statusRed;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.getCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.getBorderColor(context),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _showPlantDetails(plant);
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Plant Icon
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryGreen.withValues(alpha: 0.2),
                            AppColors.primaryGreen.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primaryGreen.withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        _getIconData(plant.icon),
                        color: AppColors.primaryGreen,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Plant Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child:                             Text(
                              plant.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                                color: AppColors.getTextColor(context),
                              ),
                            ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: difficultyColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: difficultyColor.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  difficulty,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: difficultyColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                            Text(
                              plant.scientificName,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.getTextLightColor(context),
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          const SizedBox(height: 8),
                            Text(
                              plant.description,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.getTextLightColor(context),
                                fontWeight: FontWeight.w400,
                                height: 1.4,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Care Requirements
                Row(
                  children: [
                    _buildCareInfo(Icons.wb_sunny_rounded, plant.light, AppColors.sunAmber),
                    const SizedBox(width: 12),
                    _buildCareInfo(Icons.water_drop_rounded, plant.water, AppColors.waterTeal),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Tags
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.primaryGreen.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.label_rounded,
                            size: 14,
                            color: AppColors.primaryGreen,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            tag,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCareInfo(IconData icon, String text, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPlantDetails(ExplorePlant plant) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: AppColors.getCardBackgroundColor(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.getBorderColor(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryGreen.withValues(alpha: 0.2),
                                AppColors.primaryGreen.withValues(alpha: 0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            _getIconData(plant.icon),
                            color: AppColors.primaryGreen,
                            size: 40,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                plant.name,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.getTextColor(context),
                                ),
                              ),
                              Text(
                                plant.scientificName,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.getTextLightColor(context),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      plant.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.getTextColor(context),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Care Requirements',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.getTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildDetailInfo('Light', plant.light, Icons.wb_sunny_rounded, AppColors.sunAmber)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildDetailInfo('Water', plant.water, Icons.water_drop_rounded, AppColors.waterTeal)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildDetailInfo('Difficulty', plant.difficulty, Icons.trending_up_rounded, AppColors.primaryGreen),
                    const SizedBox(height: 24),
                    Text(
                      'Features',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.getTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: plant.tags.map((tag) {
                        return Chip(
                          label: Text(tag),
                          backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.1),
                          labelStyle: TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailInfo(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.getTextLightColor(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProblemsTab() {
    final problemCategories = ['All', 'Pests', 'Diseases', 'Environmental', 'Nutrition', 'Watering'];
    
    final problems = [
      {
        'name': 'Aphids',
        'category': 'Pests',
        'description': 'Small green or black insects clustering on new growth',
        'icon': Icons.bug_report_rounded,
        'color': const Color(0xFFEF4444),
        'severity': 'Moderate',
        'treatmentDifficulty': 'Easy',
        'commonCauses': ['Weak plants', 'Over-fertilization', 'Dry conditions'],
        'solutions': [
          'Spray with water to dislodge',
          'Use insecticidal soap',
          'Introduce beneficial insects like ladybugs',
          'Apply neem oil treatment'
        ],
        'prevention': 'Keep plants healthy and well-watered. Regularly inspect new growth.',
        'affectedPlants': ['Most plants', 'Especially roses', 'Vegetables'],
      },
      {
        'name': 'Spider Mites',
        'category': 'Pests',
        'description': 'Tiny red or brown mites causing webbing and yellowing',
        'icon': Icons.bug_report_rounded,
        'color': const Color(0xFFDC2626),
        'severity': 'Severe',
        'treatmentDifficulty': 'Moderate',
        'commonCauses': ['Dry air', 'Overcrowding', 'Poor ventilation'],
        'solutions': [
          'Increase humidity around plants',
          'Wipe leaves with damp cloth',
          'Use miticide or insecticidal soap',
          'Isolate affected plants immediately'
        ],
        'prevention': 'Maintain 40-50% humidity. Space plants properly for air circulation.',
        'affectedPlants': ['Houseplants', 'Indoor plants', 'Dry environment lovers'],
      },
      {
        'name': 'Yellowing Leaves',
        'category': 'Environmental',
        'description': 'Leaves turning yellow, often starting from bottom',
        'icon': Icons.warning_rounded,
        'color': const Color(0xFFF59E0B),
        'severity': 'Mild',
        'treatmentDifficulty': 'Easy',
        'commonCauses': ['Overwatering', 'Underwatering', 'Nutrient deficiency', 'Natural aging'],
        'solutions': [
          'Check soil moisture - adjust watering schedule',
          'Test for nutrient deficiencies',
          'Ensure proper drainage',
          'Trim yellow leaves if necessary'
        ],
        'prevention': 'Water only when top inch of soil is dry. Fertilize regularly during growing season.',
        'affectedPlants': ['All plants', 'Most common in overwatered plants'],
      },
      {
        'name': 'Brown Leaf Tips',
        'category': 'Environmental',
        'description': 'Leaf tips turning brown and crispy',
        'icon': Icons.circle_rounded,
        'color': const Color(0xFF92400E),
        'severity': 'Mild',
        'treatmentDifficulty': 'Easy',
        'commonCauses': ['Low humidity', 'Over-fertilization', 'Salt buildup', 'Underwatering'],
        'solutions': [
          'Increase humidity with humidifier or pebble tray',
          'Flush soil with water to remove salts',
          'Reduce fertilizer frequency',
          'Trim brown tips with clean scissors'
        ],
        'prevention': 'Use filtered water. Maintain 40-60% humidity. Don\'t over-fertilize.',
        'affectedPlants': ['Spider plants', 'Dracaena', 'Palms', 'Ferns'],
      },
      {
        'name': 'Root Rot',
        'category': 'Watering',
        'description': 'Overwatering causing roots to decay and turn mushy',
        'icon': Icons.water_damage_rounded,
        'color': const Color(0xFFDC2626),
        'severity': 'Severe',
        'treatmentDifficulty': 'Moderate',
        'commonCauses': ['Overwatering', 'Poor drainage', 'Heavy soil', 'Oversized pots'],
        'solutions': [
          'Remove plant and trim affected roots',
          'Repot in fresh, well-draining soil',
          'Reduce watering frequency significantly',
          'Ensure pot has drainage holes'
        ],
        'prevention': 'Water only when soil is dry. Use pots with drainage. Choose appropriate soil mix.',
        'affectedPlants': ['Succulents', 'Overwatered plants', 'Plants in heavy soil'],
      },
      {
        'name': 'Wilting',
        'category': 'Watering',
        'description': 'Plants drooping or losing turgor pressure',
        'icon': Icons.arrow_downward_rounded,
        'color': const Color(0xFF3B82F6),
        'severity': 'Moderate',
        'treatmentDifficulty': 'Easy',
        'commonCauses': ['Underwatering', 'Overwatering', 'Root issues', 'Heat stress'],
        'solutions': [
          'Check soil moisture immediately',
          'Water if dry, let dry if overwatered',
          'Move to cooler location if heat stressed',
          'Check roots for damage'
        ],
        'prevention': 'Establish consistent watering routine. Protect from extreme temperatures.',
        'affectedPlants': ['All plants', 'Especially those with high water needs'],
      },
      {
        'name': 'Powdery Mildew',
        'category': 'Diseases',
        'description': 'White powdery fungus on leaves and stems',
        'icon': Icons.science_rounded,
        'color': const Color(0xFF9333EA),
        'severity': 'Moderate',
        'treatmentDifficulty': 'Moderate',
        'commonCauses': ['High humidity', 'Poor air circulation', 'Cool temperatures', 'Crowded plants'],
        'solutions': [
          'Improve air circulation around plants',
          'Remove affected leaves',
          'Apply fungicide or baking soda solution',
          'Reduce humidity if possible'
        ],
        'prevention': 'Space plants properly. Avoid overhead watering. Ensure good ventilation.',
        'affectedPlants': ['Squash', 'Cucumbers', 'Houseplants', 'Outdoor ornamentals'],
      },
      {
        'name': 'Leaf Spot',
        'category': 'Diseases',
        'description': 'Brown or black spots with yellow halos on leaves',
        'icon': Icons.brightness_1_rounded,
        'color': const Color(0xFF8B4513),
        'severity': 'Moderate',
        'treatmentDifficulty': 'Easy',
        'commonCauses': ['Fungal infection', 'Bacterial infection', 'Water on leaves', 'Poor hygiene'],
        'solutions': [
          'Remove affected leaves',
          'Avoid overhead watering',
          'Improve air circulation',
          'Apply fungicide if severe'
        ],
        'prevention': 'Water at base of plant. Keep leaves dry. Clean pruning tools between uses.',
        'affectedPlants': ['Roses', 'Vegetables', 'Ornamental plants'],
      },
      {
        'name': 'Nutrient Deficiency',
        'category': 'Nutrition',
        'description': 'Lack of essential nutrients causing various symptoms',
        'icon': Icons.bloodtype_rounded,
        'color': const Color(0xFF14B8A6),
        'severity': 'Moderate',
        'treatmentDifficulty': 'Easy',
        'commonCauses': ['Poor soil', 'Lack of fertilization', 'pH imbalance', 'Root damage'],
        'solutions': [
          'Test soil pH and nutrients',
          'Apply balanced fertilizer',
          'Use specific nutrient supplements',
          'Repot with fresh nutrient-rich soil'
        ],
        'prevention': 'Fertilize regularly during growing season. Use quality potting mix. Monitor pH.',
        'affectedPlants': ['All plants', 'Especially container plants'],
      },
      {
        'name': 'Mealybugs',
        'category': 'Pests',
        'description': 'White cotton-like clusters on stems and leaf joints',
        'icon': Icons.pest_control_rounded,
        'color': const Color(0xFFEC4899),
        'severity': 'Moderate',
        'treatmentDifficulty': 'Moderate',
        'commonCauses': ['Weak plants', 'Overcrowding', 'Over-fertilization', 'Contaminated soil'],
        'solutions': [
          'Wipe with alcohol-soaked cotton swabs',
          'Spray with insecticidal soap',
          'Apply neem oil treatment',
          'Isolate infected plants'
        ],
        'prevention': 'Inspect new plants carefully. Keep plants healthy. Maintain proper spacing.',
        'affectedPlants': ['Houseplants', 'Succulents', 'Orchids', 'Citrus trees'],
      },
      {
        'name': 'Scale Insects',
        'category': 'Pests',
        'description': 'Brown or white shell-like bumps on stems and leaves',
        'icon': Icons.shield_rounded,
        'color': const Color(0xFF7C3AED),
        'severity': 'Moderate',
        'treatmentDifficulty': 'Moderate',
        'commonCauses': ['Weak plants', 'Poor air circulation', 'Contaminated plants'],
        'solutions': [
          'Scrape off with fingernail or brush',
          'Apply horticultural oil',
          'Use insecticidal soap',
          'Introduce beneficial predators'
        ],
        'prevention': 'Regular inspection. Quarantine new plants. Keep plants vigorous.',
        'affectedPlants': ['Citrus', 'Ficus', 'Palm trees', 'Houseplants'],
      },
      {
        'name': 'Drooping Leaves',
        'category': 'Environmental',
        'description': 'Leaves hanging down but not necessarily wilted',
        'icon': Icons.arrow_downward_rounded,
        'color': const Color(0xFF06B6D4),
        'severity': 'Mild',
        'treatmentDifficulty': 'Easy',
        'commonCauses': ['Natural rhythm', 'Temperature changes', 'Light changes', 'Transplant shock'],
        'solutions': [
          'Check if it\'s normal behavior (some plants droop at night)',
          'Adjust watering if needed',
          'Provide consistent environment',
          'Wait for plant to recover from shock'
        ],
        'prevention': 'Maintain consistent conditions. Acclimate plants gradually to new environments.',
        'affectedPlants': ['Ferns', 'Calathea', 'Prayer plants', 'Plants with natural rhythms'],
      },
    ];

    // Filter problems
    var filteredProblems = problems.where((problem) {
      final matchesSearch = _problemsSearchQuery.isEmpty ||
          problem['name']!.toString().toLowerCase().contains(_problemsSearchQuery) ||
          problem['description']!.toString().toLowerCase().contains(_problemsSearchQuery) ||
          problem['category']!.toString().toLowerCase().contains(_problemsSearchQuery) ||
          (problem['commonCauses'] as List).any((cause) => cause.toString().toLowerCase().contains(_problemsSearchQuery)) ||
          (problem['solutions'] as List).any((solution) => solution.toString().toLowerCase().contains(_problemsSearchQuery));
      
      final matchesCategory = _selectedProblemCategory == 'All' ||
          problem['category']!.toString() == _selectedProblemCategory;
      
      return matchesSearch && matchesCategory;
    }).toList();

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.getCardBackgroundColor(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.getBorderColor(context),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _problemsSearchController,
              decoration: InputDecoration(
                hintText: 'Search plant problems...',
                hintStyle: TextStyle(
                  color: AppColors.getTextLightColor(context),
                  fontSize: 15,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: AppColors.getTextLightColor(context),
                  size: 22,
                ),
                suffixIcon: _problemsSearchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear_rounded,
                          color: AppColors.getTextLightColor(context),
                          size: 20,
                        ),
                        onPressed: () {
                          _problemsSearchController.clear();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              style: TextStyle(
                color: AppColors.getTextColor(context),
                fontSize: 15,
              ),
            ),
          ),
        ),
        
        // Category Chips
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: problemCategories.length,
            itemBuilder: (context, index) {
              final category = problemCategories[index];
              final isSelected = _selectedProblemCategory == category;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  selected: isSelected,
                  label: Text(category),
                  onSelected: (selected) {
                    setState(() {
                      _selectedProblemCategory = category;
                    });
                    // Reload problems with new category
                    context.read<ExploreBloc>().add(
                      LoadProblems(
                        category: category == 'All' ? null : category,
                        search: _problemsSearchQuery.isEmpty ? null : _problemsSearchQuery,
                      ),
                    );
                  },
                  backgroundColor: AppColors.getCardBackgroundColor(context),
                  selectedColor: AppColors.statusRed.withValues(alpha: 0.15),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? AppColors.statusRed
                        : AppColors.getTextColor(context),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 13,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.statusRed
                        : AppColors.getBorderColor(context),
                    width: isSelected ? 1.5 : 1,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Problems List
        Expanded(
          child: filteredProblems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 64,
                        color: AppColors.getTextLightColor(context),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No problems found',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextColor(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try adjusting your search or filters',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.getTextLightColor(context),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredProblems.length,
                  itemBuilder: (context, index) {
                    final problem = filteredProblems[index];
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 300 + (index * 50)),
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
                      child: _buildProblemCard(problem, index),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildProblemCard(Map<String, dynamic> problem, int index) {
    final severity = problem['severity'] as String;
    final treatmentDifficulty = problem['treatmentDifficulty'] as String;
    final category = problem['category'] as String;
    
    final severityColor = severity == 'Mild'
        ? AppColors.statusGreen
        : severity == 'Moderate'
            ? AppColors.statusOrange
            : AppColors.statusRed;
    
    final difficultyColor = treatmentDifficulty == 'Easy'
        ? AppColors.statusGreen
        : treatmentDifficulty == 'Moderate'
            ? AppColors.statusOrange
            : AppColors.statusRed;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.getCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (problem['color'] as Color).withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (problem['color'] as Color).withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _showProblemDetails(problem);
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Problem Icon
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            (problem['color'] as Color).withValues(alpha: 0.25),
                            (problem['color'] as Color).withValues(alpha: 0.08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: (problem['color'] as Color).withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        problem['icon'] as IconData,
                        color: problem['color'] as Color,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Problem Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  problem['name'] as String,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.5,
                                    color: AppColors.getTextColor(context),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: severityColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: severityColor.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  severity,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: severityColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.getBorderColor(context).withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              category,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.getTextLightColor(context),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            problem['description'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.getTextLightColor(context),
                              fontWeight: FontWeight.w400,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Quick Info
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: severityColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: severityColor.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.warning_rounded, size: 16, color: severityColor),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Severity: $severity',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: severityColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: difficultyColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: difficultyColor.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.healing_rounded, size: 16, color: difficultyColor),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Treatment: $treatmentDifficulty',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: difficultyColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Quick Tip
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryGreen.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb_rounded, size: 16, color: AppColors.primaryGreen),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Quick Tip: ${(problem['solutions'] as List<String>).first}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryGreen,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
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

  void _showProblemDetails(Map<String, dynamic> problem) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: AppColors.getCardBackgroundColor(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.getBorderColor(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                (problem['color'] as Color).withValues(alpha: 0.25),
                                (problem['color'] as Color).withValues(alpha: 0.08),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: (problem['color'] as Color).withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            problem['icon'] as IconData,
                            color: problem['color'] as Color,
                            size: 40,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                problem['name'] as String,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.getTextColor(context),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.getBorderColor(context).withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  problem['category'] as String,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.getTextLightColor(context),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      problem['description'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.getTextColor(context),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Severity and Treatment
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailInfo(
                            'Severity',
                            problem['severity'] as String,
                            Icons.warning_rounded,
                            problem['severity'] == 'Mild' 
                                ? AppColors.statusGreen
                                : problem['severity'] == 'Moderate'
                                    ? AppColors.statusOrange
                                    : AppColors.statusRed,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDetailInfo(
                            'Treatment',
                            problem['treatmentDifficulty'] as String,
                            Icons.healing_rounded,
                            problem['treatmentDifficulty'] == 'Easy'
                                ? AppColors.statusGreen
                                : problem['treatmentDifficulty'] == 'Moderate'
                                    ? AppColors.statusOrange
                                    : AppColors.statusRed,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Common Causes
                    Text(
                      'Common Causes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.getTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...(problem['commonCauses'] as List<String>).map((cause) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 6, right: 12),
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: problem['color'] as Color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                cause,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.getTextColor(context),
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    
                    const SizedBox(height: 24),
                    
                    // Solutions
                    Text(
                      'Solutions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.getTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...(problem['solutions'] as List<String>).asMap().entries.map((entry) {
                      final index = entry.key;
                      final solution = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primaryGreen.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  solution,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.getTextColor(context),
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    
                    const SizedBox(height: 24),
                    
                    // Prevention
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.waterTeal.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.waterTeal.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.shield_rounded,
                                color: AppColors.waterTeal,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Prevention',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.waterTeal,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            problem['prevention'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.getTextColor(context),
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Affected Plants
                    Text(
                      'Commonly Affected',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.getTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (problem['affectedPlants'] as List<String>).map((plant) {
                        return Chip(
                          label: Text(plant),
                          backgroundColor: AppColors.getBorderColor(context).withValues(alpha: 0.2),
                          labelStyle: TextStyle(
                            color: AppColors.getTextColor(context),
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
