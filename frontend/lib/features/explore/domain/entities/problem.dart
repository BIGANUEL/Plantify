class Problem {
  final String id;
  final String name;
  final String category;
  final String description;
  final String severity;
  final String treatmentDifficulty;
  final List<String> commonCauses;
  final List<String> solutions;
  final String prevention;
  final List<String> affectedPlants;
  final String? icon;
  final String? color;

  const Problem({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.severity,
    required this.treatmentDifficulty,
    required this.commonCauses,
    required this.solutions,
    required this.prevention,
    required this.affectedPlants,
    this.icon,
    this.color,
  });
}
