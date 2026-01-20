class ExplorePlant {
  final String id;
  final String name;
  final String scientificName;
  final String category;
  final String difficulty;
  final String light;
  final String water;
  final String description;
  final List<String> tags;
  final String? icon;
  final String? imageUrl;

  const ExplorePlant({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.category,
    required this.difficulty,
    required this.light,
    required this.water,
    required this.description,
    required this.tags,
    this.icon,
    this.imageUrl,
  });
}
