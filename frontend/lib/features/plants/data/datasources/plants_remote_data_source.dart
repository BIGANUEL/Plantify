import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/plant_model.dart';

abstract class PlantsRemoteDataSource {
  Future<List<PlantModel>> getPlants();
  Future<PlantModel> waterPlant(String plantId);
  Future<PlantModel> createPlant(String name, String type, DateTime nextWateringDate);
  Future<PlantModel> updatePlant(
    String id,
    String name,
    String type,
    int wateringInterval,
    String? light,
    String? humidity,
    String? careTips,
  );
}

class PlantsRemoteDataSourceImpl implements PlantsRemoteDataSource {
  final SharedPreferences sharedPreferences;
  final http.Client client;
  
  // Mock storage for development - in-memory list of plants
  static List<PlantModel> _mockPlants = [];

  PlantsRemoteDataSourceImpl({
    required this.sharedPreferences,
    http.Client? client,
  }) : client = client ?? http.Client() {
    // Initialize mock plants if empty
    if (_mockPlants.isEmpty) {
      _initializeMockPlants();
    }
  }
  
  void _initializeMockPlants() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _mockPlants = [
      PlantModel(
        id: '1',
        name: 'Ferny',
        type: 'Fern',
        nextWateringDate: today.subtract(const Duration(days: 1)), // Overdue
        wateringInterval: 3,
        lastWateredDate: today.subtract(const Duration(days: 4)),
        light: 'Medium',
        humidity: 'High',
        careTips: 'Keep soil moist but not waterlogged. Prefers indirect sunlight.',
      ),
      PlantModel(
        id: '2',
        name: 'Lily',
        type: 'Peace Lily',
        nextWateringDate: today.add(const Duration(days: 2)),
        wateringInterval: 5,
        lastWateredDate: today.subtract(const Duration(days: 3)),
        light: 'Low to Medium',
        humidity: 'High',
        careTips: 'Water when soil feels dry. Mist leaves regularly for humidity.',
      ),
      PlantModel(
        id: '3',
        name: 'Snake Plant',
        type: 'Sansevieria',
        nextWateringDate: today.add(const Duration(days: 5)),
        wateringInterval: 14,
        lastWateredDate: today.subtract(const Duration(days: 9)),
        light: 'Bright',
        humidity: 'Low',
        careTips: 'Very low maintenance. Water sparingly. Can tolerate low light.',
      ),
      PlantModel(
        id: '4',
        name: 'Pothos',
        type: 'Golden Pothos',
        nextWateringDate: today, // Overdue (today)
        wateringInterval: 7,
        lastWateredDate: today.subtract(const Duration(days: 7)),
        light: 'Medium',
        humidity: 'Medium',
        careTips: 'Easy to care for. Allow soil to dry between waterings.',
      ),
    ];
  }

  String get _baseUrl {
    if (AppConstants.baseUrl.endsWith('/')) {
      return '${AppConstants.baseUrl.substring(0, AppConstants.baseUrl.length - 1)}${AppConstants.apiPrefix}';
    } else {
      return '${AppConstants.baseUrl}${AppConstants.apiPrefix}';
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = sharedPreferences.getString(AppConstants.userTokenKey);
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  @override
  Future<List<PlantModel>> getPlants() async {
    try {
      // Mock data for development - remove this when API is ready
      if (AppConstants.baseUrl.contains('example.com')) {
        await Future.delayed(const Duration(milliseconds: 500));
        return List.from(_mockPlants);
      }

      final url = Uri.parse('$_baseUrl/plants');
      final headers = await _getHeaders();

      final response = await client
          .get(url, headers: headers)
          .timeout(
            Duration(milliseconds: AppConstants.connectTimeout),
          );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // Backend returns: { success: true, data: { plants: [...] } }
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> plantsData = responseData['data']['plants'] ?? [];
          return plantsData.map((plantJson) => PlantModel.fromJson(plantJson)).toList();
        } else {
          throw ServerException('Invalid response format from server');
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw const ServerException('Unauthorized. Please login again.');
      } else if (response.statusCode >= 500) {
        throw ServerException('Server error: ${response.statusCode}');
      } else {
        throw ServerException('Failed to load plants: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } on FormatException catch (e) {
      throw ServerException('Invalid response format: ${e.message}');
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<PlantModel> waterPlant(String plantId) async {
    try {
      // Mock data for development - remove this when API is ready
      if (AppConstants.baseUrl.contains('example.com')) {
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Find and update the plant in mock list
        final index = _mockPlants.indexWhere((p) => p.id == plantId);
        if (index != -1) {
          final plant = _mockPlants[index];
          final now = DateTime.now();
          final nextWatering = now.add(Duration(days: plant.wateringInterval));
          
          // Update the plant's next watering date and last watered date
          final updatedPlant = PlantModel(
            id: plant.id,
            name: plant.name,
            type: plant.type,
            nextWateringDate: nextWatering,
            photo: plant.photo,
            wateringInterval: plant.wateringInterval,
            lastWateredDate: now,
            light: plant.light,
            humidity: plant.humidity,
            careTips: plant.careTips,
          );
          _mockPlants[index] = updatedPlant;
          return updatedPlant;
        }
        
        // If plant not found, create a default one
        final now = DateTime.now();
        final nextWatering = now.add(const Duration(days: 7));
        return PlantModel(
          id: plantId,
          name: 'Plant',
          type: 'Type',
          nextWateringDate: nextWatering,
        );
      }

      final url = Uri.parse('$_baseUrl/plants/$plantId/water');
      final headers = await _getHeaders();

      final response = await client
          .post(url, headers: headers)
          .timeout(
            Duration(milliseconds: AppConstants.connectTimeout),
          );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        // Backend returns: { success: true, data: { plant: {...} } }
        if (responseData['success'] == true && responseData['data'] != null) {
          final plantData = responseData['data']['plant'] ?? responseData['data'];
          return PlantModel.fromJson(plantData);
        } else {
          throw ServerException('Invalid response format from server');
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw const ServerException('Unauthorized. Please login again.');
      } else if (response.statusCode == 404) {
        throw const ServerException('Plant not found');
      } else if (response.statusCode >= 500) {
        throw ServerException('Server error: ${response.statusCode}');
      } else {
        throw ServerException('Failed to water plant: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } on FormatException catch (e) {
      throw ServerException('Invalid response format: ${e.message}');
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<PlantModel> createPlant(String name, String type, DateTime nextWateringDate) async {
    try {
      // Mock data for development - remove this when API is ready
      if (AppConstants.baseUrl.contains('example.com')) {
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Create new plant and add to mock list
        final newPlant = PlantModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          type: type,
          nextWateringDate: nextWateringDate,
          wateringInterval: 7, // Default to 7 days
        );
        _mockPlants.add(newPlant);
        return newPlant;
      }

      final url = Uri.parse('$_baseUrl/plants');
      final headers = await _getHeaders();

      final response = await client
          .post(
            url,
            headers: headers,
            body: json.encode({
              'name': name,
              'type': type,
              'wateringFrequency': 7, // Default to 7 days, can be calculated from nextWateringDate
            }),
          )
          .timeout(
            Duration(milliseconds: AppConstants.connectTimeout),
          );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        // Backend returns: { success: true, data: { plant: {...} } }
        if (responseData['success'] == true && responseData['data'] != null) {
          final plantData = responseData['data']['plant'] ?? responseData['data'];
          if (plantData != null) {
            try {
              return PlantModel.fromJson(plantData);
            } catch (e) {
              throw ServerException('Failed to parse plant data: ${e.toString()}');
            }
          } else {
            throw ServerException('Plant data not found in response. Response: ${response.body}');
          }
        } else {
          final errorMsg = responseData['error']?['message'] ?? 'Invalid response format from server';
          throw ServerException(errorMsg);
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw const ServerException('Unauthorized. Please login again.');
      } else if (response.statusCode == 400) {
        throw const ServerException('Invalid plant data');
      } else if (response.statusCode >= 500) {
        throw ServerException('Server error: ${response.statusCode}');
      } else {
        throw ServerException('Failed to create plant: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } on FormatException catch (e) {
      throw ServerException('Invalid response format: ${e.message}');
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<PlantModel> updatePlant(
    String id,
    String name,
    String type,
    int wateringInterval,
    String? light,
    String? humidity,
    String? careTips,
  ) async {
    try {
      // Mock data for development - remove this when API is ready
      if (AppConstants.baseUrl.contains('example.com')) {
        await Future.delayed(const Duration(milliseconds: 500));

        // Find and update the plant in mock list
        final index = _mockPlants.indexWhere((p) => p.id == id);
        if (index != -1) {
          final existingPlant = _mockPlants[index];
          final updatedPlant = PlantModel(
            id: existingPlant.id,
            name: name,
            type: type,
            nextWateringDate: existingPlant.nextWateringDate,
            photo: existingPlant.photo,
            wateringInterval: wateringInterval,
            lastWateredDate: existingPlant.lastWateredDate,
            light: light,
            humidity: humidity,
            careTips: careTips,
          );
          _mockPlants[index] = updatedPlant;
          return updatedPlant;
        }

        // If plant not found, throw error
        throw const ServerException('Plant not found');
      }

      final url = Uri.parse('$_baseUrl/plants/$id');
      final headers = await _getHeaders();

      final response = await client
          .put(
            url,
            headers: headers,
            body: json.encode({
              'name': name,
              'type': type,
              'wateringInterval': wateringInterval,
              if (light != null) 'light': light,
              if (humidity != null) 'humidity': humidity,
              if (careTips != null) 'careTips': careTips,
            }),
          )
          .timeout(
            Duration(milliseconds: AppConstants.connectTimeout),
          );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // Backend returns: { success: true, data: { plant: {...} } }
        if (responseData['success'] == true && responseData['data'] != null) {
          final plantData = responseData['data']['plant'] ?? responseData['data'];
          return PlantModel.fromJson(plantData);
        } else {
          throw ServerException('Invalid response format from server');
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw const ServerException('Unauthorized. Please login again.');
      } else if (response.statusCode == 404) {
        throw const ServerException('Plant not found');
      } else if (response.statusCode == 400) {
        throw const ServerException('Invalid plant data');
      } else if (response.statusCode >= 500) {
        throw ServerException('Server error: ${response.statusCode}');
      } else {
        throw ServerException('Failed to update plant: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } on FormatException catch (e) {
      throw ServerException('Invalid response format: ${e.message}');
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }
}

