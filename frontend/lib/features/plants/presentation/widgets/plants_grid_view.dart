import 'package:flutter/material.dart';
import '../../domain/entities/plant.dart';
import 'plant_card.dart';

class PlantsGridView extends StatelessWidget {
  final List<Plant> plants;
  final Function(String plantId) onWater;
  final String? wateringPlantId;

  const PlantsGridView({
    super.key,
    required this.plants,
    required this.onWater,
    this.wateringPlantId,
  });

  @override
  Widget build(BuildContext context) {
    if (plants.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.eco_outlined,
                  size: 80,
                  color: Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'No plants yet',
                style: TextStyle(
                  fontSize: 24,
                  color: Color(0xFF1A1A1A),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tap the button below to add your first plant',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.82,
      ),
      itemCount: plants.length,
      itemBuilder: (context, index) {
        final plant = plants[index];
        return PlantCard(
          plant: plant,
          onWater: () => onWater(plant.id),
          isWatering: wateringPlantId == plant.id,
          isListView: false,
        );
      },
    );
  }
}

