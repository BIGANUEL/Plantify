import '../../domain/entities/problem.dart';

class ProblemModel extends Problem {
  const ProblemModel({
    required super.id,
    required super.name,
    required super.category,
    required super.description,
    required super.severity,
    required super.treatmentDifficulty,
    required super.commonCauses,
    required super.solutions,
    required super.prevention,
    required super.affectedPlants,
    super.icon,
    super.color,
  });

  factory ProblemModel.fromJson(Map<String, dynamic> json) {
    return ProblemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      severity: json['severity'] as String,
      treatmentDifficulty: json['treatmentDifficulty'] as String,
      commonCauses: (json['commonCauses'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      solutions: (json['solutions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      prevention: json['prevention'] as String,
      affectedPlants: (json['affectedPlants'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      icon: json['icon'] as String?,
      color: json['color'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'severity': severity,
      'treatmentDifficulty': treatmentDifficulty,
      'commonCauses': commonCauses,
      'solutions': solutions,
      'prevention': prevention,
      'affectedPlants': affectedPlants,
      'icon': icon,
      'color': color,
    };
  }
}
