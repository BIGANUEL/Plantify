import '../../../../core/usecases/usecase.dart';
import '../entities/plant.dart';

abstract class PlantsRepository {
  Future<Result<List<Plant>>> getPlants();
  Future<Result<Plant>> waterPlant(String plantId);
  Future<Result<Plant>> createPlant(String name, String type, DateTime nextWateringDate);
  Future<Result<Plant>> updatePlant(
    String id,
    String name,
    String type,
    int wateringInterval,
    String? light,
    String? humidity,
    String? careTips,
  );
}

