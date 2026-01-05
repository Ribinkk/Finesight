import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../config/auth0_config.dart';

class AuthService {
  late final Auth0 _auth0;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  UserModel? _user;
  Credentials? _credentials;

  AuthService() {
    _auth0 = Auth0(Auth0Config.domain, Auth0Config.clientId);
    _loadStoredCredentials();
  }

  UserModel? get currentUser => _user;
  bool get isLoggedIn => _user != null;

  // Load stored credentials on app start
  Future<void> _loadStoredCredentials() async {
    try {
      final accessToken = await _secureStorage.read(key: 'access_token');
      final idToken = await _secureStorage.read(key: 'id_token');
      final refreshToken = await _secureStorage.read(key: 'refresh_token');
      
      if (accessToken != null && idToken != null) {
        // Create credentials from stored tokens
        _credentials = Credentials(
          accessToken: accessToken,
          idToken: idToken,
          refreshToken: refreshToken,
        );
        
        // Get user info
        final userProfile = await _auth0.api.userProfile(accessToken: accessToken);
        
        _user = UserModel(
          name: userProfile.name ?? 'User',
          email: userProfile.email ?? '',
          pictureUrl: userProfile.pictureUrl,
        );
      }
    } catch (e) {
      print('Error loading stored credentials: $e');
      // Clear invalid credentials
      await _clearStoredCredentials();
    }
  }

  // Login with Auth0
  Future<void> login() async {
    try {
      final credentials = await _auth0.webAuthentication(scheme: Auth0Config.scheme).login(
        scopes: Auth0Config.scopes,
      );

      _credentials = credentials;
      
      // Store credentials securely
      await _secureStorage.write(key: 'access_token', value: credentials.accessToken);
      await _secureStorage.write(key: 'id_token', value: credentials.idToken);
      if (credentials.refreshToken != null) {
        await _secureStorage.write(key: 'refresh_token', value: credentials.refreshToken);
      }

      // Get user profile
      final userProfile = await _auth0.api.userProfile(accessToken: credentials.accessToken);
      
      _user = UserModel(
        name: userProfile.name ?? 'User',
        email: userProfile.email ?? '',
        pictureUrl: userProfile.pictureUrl,
      );
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _auth0.webAuthentication(scheme: Auth0Config.scheme).logout();
      await _clearStoredCredentials();
      _user = null;
      _credentials = null;
    } catch (e) {
      print('Logout error: $e');
      rethrow;
    }
  }

  // Clear stored credentials
  Future<void> _clearStoredCredentials() async {
    await _secureStorage.delete(key: 'access_token');
    await _secureStorage.delete(key: 'id_token');
    await _secureStorage.delete(key: 'refresh_token');
  }

  // Refresh access token
  Future<void> refreshToken() async {
    try {
      if (_credentials?.refreshToken == null) {
        throw Exception('No refresh token available');
      }

      final newCredentials = await _auth0.api.renewCredentials(
        refreshToken: _credentials!.refreshToken!,
      );

      _credentials = newCredentials;
      
      // Update stored tokens
      await _secureStorage.write(key: 'access_token', value: newCredentials.accessToken);
      await _secureStorage.write(key: 'id_token', value: newCredentials.idToken);
    } catch (e) {
      print('Token refresh error: $e');
      rethrow;
    }
  }
}
