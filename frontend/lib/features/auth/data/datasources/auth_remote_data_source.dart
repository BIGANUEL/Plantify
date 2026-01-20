import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String email, String password, String name);
  Future<bool> refreshAccessToken();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;
  final SharedPreferences sharedPreferences;

  AuthRemoteDataSourceImpl({
    http.Client? client,
    required this.sharedPreferences,
  }) : client = client ?? http.Client();

  String get _baseUrl {
    if (AppConstants.baseUrl.endsWith('/')) {
      return '${AppConstants.baseUrl.substring(0, AppConstants.baseUrl.length - 1)}${AppConstants.apiPrefix}';
    } else {
      return '${AppConstants.baseUrl}${AppConstants.apiPrefix}';
    }
  }

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        throw const ValidationException('Email and password are required');
      }

      final url = Uri.parse('$_baseUrl/auth/login');
      developer.log(
        'AuthRemoteDataSource: Attempting login to: $url',
        name: 'AuthRemoteDataSource',
      );
      final response = await client
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(Duration(milliseconds: AppConstants.connectTimeout));

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        final data = responseData['data'];
        final userData = data['user'];
        final accessToken = data['accessToken'] as String;
        final refreshToken = data['refreshToken'] as String;

        // Store tokens
        await sharedPreferences.setString(AppConstants.userTokenKey, accessToken);
        await sharedPreferences.setString(AppConstants.refreshTokenKey, refreshToken);
        await sharedPreferences.setString(AppConstants.userIdKey, userData['id'] as String);
        await sharedPreferences.setString(AppConstants.userEmailKey, userData['email'] as String);

        return UserModel(
          id: userData['id'] as String,
          email: userData['email'] as String,
          name: userData['name'] as String?,
          token: accessToken,
        );
      } else if (response.statusCode == 401) {
        final errorMessage = responseData['error']?['message'] ?? 'Invalid credentials';
        throw ServerException(errorMessage);
      } else {
        final errorMessage = responseData['error']?['message'] ?? 'Login failed';
        throw ServerException(errorMessage);
      }
    } on http.ClientException catch (e) {
      developer.log(
        'AuthRemoteDataSource: ClientException during login - ${e.message}',
        name: 'AuthRemoteDataSource',
        error: e,
      );
      throw NetworkException('Network error: ${e.message}');
    } on FormatException catch (e) {
      throw ServerException('Invalid response format: ${e.message}');
    } catch (e) {
      if (e.toString().contains('TimeoutException') || e.toString().contains('timeout')) {
        developer.log(
          'AuthRemoteDataSource: Timeout connecting to $_baseUrl/auth/login',
          name: 'AuthRemoteDataSource',
          error: e,
        );
        throw NetworkException(
          'Connection timeout. Make sure your backend is running on ${AppConstants.baseUrl}. '
          'If using Android emulator, use http://10.0.2.2:5000 (or your backend port).',
        );
      }
      if (e is ServerException || e is NetworkException || e is ValidationException) {
        rethrow;
      }
      developer.log(
        'AuthRemoteDataSource: Unexpected error during login: ${e.toString()}',
        name: 'AuthRemoteDataSource',
        error: e,
      );
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> register(String email, String password, String name) async {
    try {
      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        throw const ValidationException('All fields are required');
      }

      if (password.length < 6) {
        throw const ValidationException('Password must be at least 6 characters');
      }

      final url = Uri.parse('$_baseUrl/auth/register');
      final response = await client
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({
              'email': email,
              'password': password,
              'name': name,
            }),
          )
          .timeout(Duration(milliseconds: AppConstants.connectTimeout));

      final responseData = json.decode(response.body);

      if (response.statusCode == 201 && responseData['success'] == true) {
        final data = responseData['data'];
        final userData = data['user'];
        final accessToken = data['accessToken'] as String;
        final refreshToken = data['refreshToken'] as String;

        // Store tokens
        await sharedPreferences.setString(AppConstants.userTokenKey, accessToken);
        await sharedPreferences.setString(AppConstants.refreshTokenKey, refreshToken);
        await sharedPreferences.setString(AppConstants.userIdKey, userData['id'] as String);
        await sharedPreferences.setString(AppConstants.userEmailKey, userData['email'] as String);

        return UserModel(
          id: userData['id'] as String,
          email: userData['email'] as String,
          name: userData['name'] as String?,
          token: accessToken,
        );
      } else if (response.statusCode == 400) {
        final errorMessage = responseData['error']?['message'] ?? 'Registration failed';
        throw ServerException(errorMessage);
      } else {
        final errorMessage = responseData['error']?['message'] ?? 'Registration failed';
        throw ServerException(errorMessage);
      }
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } on FormatException catch (e) {
      throw ServerException('Invalid response format: ${e.message}');
    } catch (e) {
      if (e is ServerException || e is NetworkException || e is ValidationException) {
        rethrow;
      }
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<bool> refreshAccessToken() async {
    try {
      final refreshToken = sharedPreferences.getString(AppConstants.refreshTokenKey);
      if (refreshToken == null) {
        return false;
      }

      final url = Uri.parse('$_baseUrl/auth/refresh');
      developer.log(
        'AuthRemoteDataSource: Attempting token refresh',
        name: 'AuthRemoteDataSource',
      );

      final response = await client
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({
              'refreshToken': refreshToken,
            }),
          )
          .timeout(Duration(milliseconds: AppConstants.connectTimeout));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final newAccessToken = responseData['data']['accessToken'] as String;
          // Store the new access token
          await sharedPreferences.setString(AppConstants.userTokenKey, newAccessToken);
          developer.log(
            'AuthRemoteDataSource: Token refreshed successfully',
            name: 'AuthRemoteDataSource',
          );
          return true;
        }
      }

      developer.log(
        'AuthRemoteDataSource: Token refresh failed with status ${response.statusCode}',
        name: 'AuthRemoteDataSource',
      );
      return false;
    } catch (e) {
      developer.log(
        'AuthRemoteDataSource: Token refresh error: ${e.toString()}',
        name: 'AuthRemoteDataSource',
        error: e,
      );
      return false;
    }
  }
}

