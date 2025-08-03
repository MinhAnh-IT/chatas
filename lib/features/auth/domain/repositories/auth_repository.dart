import '../entities/auth_result.dart';
import '../entities/login_request.dart';
import '../entities/register_request.dart';
import '../entities/User.dart';

abstract class AuthRepository {
  Future<AuthResult> register(RegisterRequest request);
  
  Future<AuthResult> login(LoginRequest request);
  
  Future<AuthResult> logout();
  
  Future<User?> getCurrentUser();
  
  Future<bool> isLoggedIn();

  Future<User?> getUserById(String userId);
  
  Future<AuthResult> updateUser(User user);
  
  Future<AuthResult> deleteAccount();
} 