import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/explore_plant_model.dart';
import '../models/problem_model.dart';

abstract class ExploreRemoteDataSource {
  Future<List<ExplorePlantModel>> getExplorePlants({
    String? category,
    String? search,
  });
  Future<List<ProblemModel>> getProblems({
    String? category,
    String? search,
  });
}

class ExploreRemoteDataSourceImpl implements ExploreRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  ExploreRemoteDataSourceImpl({
    http.Client? client,
    String? baseUrl,
  })  : client = client ?? http.Client(),
        baseUrl = baseUrl ?? AppConstants.baseUrl;

  @override
  Future<List<ExplorePlantModel>> getExplorePlants({
    String? category,
    String? search,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (category != null && category.isNotEmpty && category != 'All') {
        queryParams['category'] = category;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final uri = Uri.parse('$baseUrl${AppConstants.apiPrefix}/explore/plants')
          .replace(queryParameters: queryParams.isEmpty ? null : queryParams);

      final response = await client.get(uri).timeout(
        Duration(milliseconds: AppConstants.connectTimeout),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> plantsData = responseData['data']['plants'] ?? [];
          return plantsData
              .map((plantJson) => ExplorePlantModel.fromJson(plantJson))
              .toList();
        } else {
          throw ServerException('Invalid response format from server');
        }
      } else if (response.statusCode >= 500) {
        throw ServerException('Server error: ${response.statusCode}');
      } else {
        throw ServerException('Failed to load explore plants: ${response.statusCode}');
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
  Future<List<ProblemModel>> getProblems({
    String? category,
    String? search,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (category != null && category.isNotEmpty && category != 'All') {
        queryParams['category'] = category;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final uri = Uri.parse('$baseUrl${AppConstants.apiPrefix}/explore/problems')
          .replace(queryParameters: queryParams.isEmpty ? null : queryParams);

      final response = await client.get(uri).timeout(
        Duration(milliseconds: AppConstants.connectTimeout),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> problemsData = responseData['data']['problems'] ?? [];
          return problemsData
              .map((problemJson) => ProblemModel.fromJson(problemJson))
              .toList();
        } else {
          throw ServerException('Invalid response format from server');
        }
      } else if (response.statusCode >= 500) {
        throw ServerException('Server error: ${response.statusCode}');
      } else {
        throw ServerException('Failed to load problems: ${response.statusCode}');
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
