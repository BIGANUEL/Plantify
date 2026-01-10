import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/plants/domain/entities/plant.dart';
import '../features/plants/presentation/bloc/plants_bloc.dart';
import '../features/plants/presentation/bloc/plants_event.dart';
import '../features/plants/presentation/bloc/plants_state.dart';
import '../features/plants/presentation/widgets/plant_list_item.dart';
import 'plant_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Plant> _filteredPlants = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterPlants(List<Plant> plants, String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPlants = plants;
      } else {
        _filteredPlants = plants.where((plant) {
          final name = plant.name.toLowerCase();
          final type = plant.type.toLowerCase();
          final searchLower = query.toLowerCase();
          return name.contains(searchLower) || type.contains(searchLower);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search plants...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF4CAF50)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterPlants(
                            context.read<PlantsBloc>().state is PlantsLoaded
                                ? (context.read<PlantsBloc>().state as PlantsLoaded).plants
                                : [],
                            '',
                          );
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onChanged: (value) {
                final state = context.read<PlantsBloc>().state;
                if (state is PlantsLoaded) {
                  _filterPlants(state.plants, value);
                }
              },
            ),
          ),
          // Search Results
          Expanded(
            child: BlocBuilder<PlantsBloc, PlantsState>(
              builder: (context, state) {
                if (state is PlantsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is PlantsError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                List<Plant> plants = [];
                if (state is PlantsLoaded) {
                  plants = state.plants;
                  if (_searchController.text.isEmpty) {
                    _filteredPlants = plants;
                  } else {
                    _filterPlants(plants, _searchController.text);
                  }
                }

                if (_searchController.text.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Search for plants by name or type',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (_filteredPlants.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No plants found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _filteredPlants.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: Colors.grey[200],
                  ),
                  itemBuilder: (context, index) {
                    final plant = _filteredPlants[index];
                    return PlantListItem(
                      plant: plant,
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
                      onWater: () {
                        // Water plant functionality
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
                                      color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.water_drop,
                                      color: Color(0xFF4CAF50),
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
                              content: Text('Mark ${plant.name} as Watered?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(dialogContext).pop(),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(dialogContext).pop();
                                    context.read<PlantsBloc>().add(PlantWatered(plantId: plant.id));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4CAF50),
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Confirm'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      isWatering: false,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

