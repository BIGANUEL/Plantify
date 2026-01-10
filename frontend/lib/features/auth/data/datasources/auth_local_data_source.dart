import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearCache();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  static const String cachedTokenKey = 'plantify_token';
  static const String cachedEmailKey = 'plantify_email';
  static const String cachedNameKey = 'plantify_name';
  static const String cachedUserIdKey = 'plantify_user_id';

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      await sharedPreferences.setString(cachedUserIdKey, user.id);
      await sharedPreferences.setString(cachedEmailKey, user.email);
      await sharedPreferences.setString(cachedTokenKey, user.token);
      if (user.name != null) {
        await sharedPreferences.setString(cachedNameKey, user.name!);
      }
    } catch (e) {
      throw CacheException('Failed to cache user: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final userId = sharedPreferences.getString(cachedUserIdKey);
      final email = sharedPreferences.getString(cachedEmailKey);
      final token = sharedPreferences.getString(cachedTokenKey);
      final name = sharedPreferences.getString(cachedNameKey);

      if (userId == null || email == null || token == null) {
        return null;
      }

      return UserModel.fromLocalStorage(
        id: userId,
        email: email,
        name: name,
        token: token,
      );
    } catch (e) {
      throw CacheException('Failed to get cached user: ${e.toString()}');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await sharedPreferences.remove(cachedUserIdKey);
      await sharedPreferences.remove(cachedEmailKey);
      await sharedPreferences.remove(cachedTokenKey);
      await sharedPreferences.remove(cachedNameKey);
    } catch (e) {
      throw CacheException('Failed to clear cache: ${e.toString()}');
    }
  }
}

