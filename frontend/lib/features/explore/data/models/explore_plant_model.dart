import '../../domain/entities/explore_plant.dart';

class ExplorePlantModel extends ExplorePlant {
  const ExplorePlantModel({
    required super.id,
    required super.name,
    required super.scientificName,
    required super.category,
    required super.difficulty,
    required super.light,
    required super.water,
    required super.description,
    required super.tags,
    super.icon,
    super.imageUrl,
  });

  factory ExplorePlantModel.fromJson(Map<String, dynamic> json) {
    return ExplorePlantModel(
      id: json['id'] as String,
      name: json['name'] as String,
      scientificName: json['scientificName'] as String,
      category: json['category'] as String,
      difficulty: json['difficulty'] as String,
      light: json['light'] as String,
      water: json['water'] as String,
      description: json['description'] as String,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      icon: json['icon'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'scientificName': scientificName,
      'category': category,
      'difficulty': difficulty,
      'light': light,
      'water': water,
      'description': description,
      'tags': tags,
      'icon': icon,
      'imageUrl': imageUrl,
    };
  }
}
