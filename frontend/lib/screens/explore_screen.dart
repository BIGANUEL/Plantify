import 'package:flutter/material.dart';
import '../core/widgets/plantify_header.dart';
import '../core/constants/app_colors.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      body: Column(
        children: [
          // Green Header
          const PlantifyHeader(
            title: 'Explore',
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

  Widget _buildPlantsTab() {
    final popularPlants = [
      {'name': 'Snake Plant', 'scientific': 'Sansevieria', 'icon': Icons.grass_rounded},
      {'name': 'Pothos', 'scientific': 'Epipremnum aureum', 'icon': Icons.park_rounded},
      {'name': 'Monstera', 'scientific': 'Monstera deliciosa', 'icon': Icons.eco_rounded},
      {'name': 'ZZ Plant', 'scientific': 'Zamioculcas', 'icon': Icons.local_florist_rounded},
      {'name': 'Spider Plant', 'scientific': 'Chlorophytum', 'icon': Icons.water_drop_rounded},
      {'name': 'Peace Lily', 'scientific': 'Spathiphyllum', 'icon': Icons.local_florist_rounded},
      {'name': 'Fiddle Leaf Fig', 'scientific': 'Ficus lyrata', 'icon': Icons.forest_rounded},
      {'name': 'Rubber Plant', 'scientific': 'Ficus elastica', 'icon': Icons.nature_rounded},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: popularPlants.length,
      itemBuilder: (context, index) {
        final plant = popularPlants[index];
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
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.getCardBackgroundColor(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.getBorderColor(context),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${plant['name']} - Coming soon!'),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: AppColors.primaryGreen,
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryGreen.withValues(alpha: 0.15),
                              AppColors.primaryGreen.withValues(alpha: 0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.primaryGreen.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          plant['icon'] as IconData,
                          color: AppColors.primaryGreen,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plant['name'] as String,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.3,
                                color: AppColors.getTextColor(context),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              plant['scientific'] as String,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.getTextLightColor(context),
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: AppColors.getBorderColor(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProblemsTab() {
    final problems = [
      {
        'name': 'Deformation',
        'description': 'Leaves or stems showing abnormal growth patterns',
        'icon': Icons.bug_report_rounded,
        'color': const Color(0xFFF59E0B),
      },
      {
        'name': 'Pests',
        'description': 'Common pests like aphids, spider mites, mealybugs',
        'icon': Icons.bug_report_rounded,
        'color': const Color(0xFFEF4444),
      },
      {
        'name': 'Yellowing Leaves',
        'description': 'Leaves turning yellow due to various causes',
        'icon': Icons.warning_rounded,
        'color': const Color(0xFFF59E0B),
      },
      {
        'name': 'Brown Spots',
        'description': 'Brown spots or patches on leaves',
        'icon': Icons.circle_rounded,
        'color': const Color(0xFF92400E),
      },
      {
        'name': 'Root Rot',
        'description': 'Overwatering leading to root decay',
        'icon': Icons.water_damage_rounded,
        'color': const Color(0xFFDC2626),
      },
      {
        'name': 'Wilting',
        'description': 'Plants drooping or losing turgor',
        'icon': Icons.arrow_downward_rounded,
        'color': const Color(0xFF3B82F6),
      },
      {
        'name': 'Fungal Diseases',
        'description': 'Fungal infections affecting plant health',
        'icon': Icons.science_rounded,
        'color': const Color(0xFF9333EA),
      },
      {
        'name': 'Nutrient Deficiency',
        'description': 'Lack of essential nutrients in plants',
        'icon': Icons.bloodtype_rounded,
        'color': const Color(0xFF14B8A6),
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: problems.length,
      itemBuilder: (context, index) {
        final problem = problems[index];
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
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.getCardBackgroundColor(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.getBorderColor(context),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${problem['name']} - Solutions coming soon!'),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: problem['color'] as Color,
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              (problem['color'] as Color).withValues(alpha: 0.15),
                              (problem['color'] as Color).withValues(alpha: 0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: (problem['color'] as Color).withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          problem['icon'] as IconData,
                          color: problem['color'] as Color,
                          size: 28,
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
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.3,
                                color: AppColors.getTextColor(context),
                              ),
                            ),
                            const SizedBox(height: 4),
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
                      const SizedBox(width: 12),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: AppColors.getBorderColor(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
