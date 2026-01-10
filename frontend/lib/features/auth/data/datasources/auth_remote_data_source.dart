import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String email, String password, String name);
  Future<UserModel> signInWithGoogle();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<UserModel> login(String email, String password) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock authentication - replace with actual API call
    if (email.isEmpty || password.isEmpty) {
      throw const ValidationException('Email and password are required');
    }
    
    if (password.length < 6) {
      throw const ValidationException('Password must be at least 6 characters');
    }

    // Mock successful login
    return UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      name: email.split('@')[0],
      token: 'token_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  @override
  Future<UserModel> register(String email, String password, String name) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock validation
    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      throw const ValidationException('All fields are required');
    }
    
    if (password.length < 6) {
      throw const ValidationException('Password must be at least 6 characters');
    }

    // Mock successful registration
    return UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      name: name,
      token: 'token_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );
      
      final GoogleSignInAccount? account = await googleSignIn.signIn();
      
      if (account == null) {
        throw const ValidationException('Google Sign-In was cancelled');
      }
      
      final GoogleSignInAuthentication auth = await account.authentication;
      
      if (auth.idToken == null && auth.accessToken == null) {
        throw const ValidationException('Failed to authenticate with Google');
      }
      
      return UserModel(
        id: account.id,
        email: account.email,
        name: account.displayName ?? account.email.split('@')[0],
        token: auth.idToken ?? auth.accessToken ?? 'google_token_${DateTime.now().millisecondsSinceEpoch}',
      );
    } catch (e) {
      if (e is ValidationException) {
        rethrow;
      }
      throw ServerException('Google Sign-In failed: ${e.toString()}');
    }
  }
}

