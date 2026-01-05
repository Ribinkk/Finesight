import '../models/user_model.dart';

class AuthService {
  UserModel? _user;

  AuthService() {
    // Initialization if needed
  }

  UserModel? get currentUser => _user;

  Future<void> login() async {
    // Mock login logic
    try {
      // Simulate a network delay
      await Future.delayed(const Duration(seconds: 1));
      
      _user = UserModel(
        name: 'Ribin K Karun',
        email: 'ribinkkarun@gmail.com',
        pictureUrl: 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
      );
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    // Mock logout logic
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _user = null;
    } catch (e) {
       print('Logout error: $e');
       rethrow;
    }
  }
}
