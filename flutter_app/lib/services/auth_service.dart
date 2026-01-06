import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  UserModel? get currentUser {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return UserModel(
      uid: user.uid,
      name: user.displayName ?? 'User',
      email: user.email ?? '',
      pictureUrl: user.photoURL,
    );
  }

  // Stream of auth changes
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((User? user) {
      if (user == null) return null;
      return UserModel(
        uid: user.uid,
        name: user.displayName ?? 'User',
        email: user.email ?? '',
        pictureUrl: user.photoURL,
      );
    });
  }

  // Login with Google
  Future<UserModel?> loginWithGoogle() async {
    try {
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        UserCredential userCredential = await _firebaseAuth.signInWithPopup(googleProvider);
        
        return UserModel(
          uid: userCredential.user!.uid,
          name: userCredential.user?.displayName ?? 'User',
          email: userCredential.user?.email ?? '',
          pictureUrl: userCredential.user?.photoURL,
        );
      } else {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return null;

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
        
        return UserModel(
          uid: userCredential.user!.uid,
          name: userCredential.user?.displayName ?? 'User',
          email: userCredential.user?.email ?? '',
          pictureUrl: userCredential.user?.photoURL,
        );
      }
    } catch (e) {
      print('Google Sign-In Error: $e');
      rethrow;
    }
  }

  // Guest Login
  Future<UserModel> loginAsGuest() async {
    try {
      final userCredential = await _firebaseAuth.signInAnonymously();
      return UserModel(
          uid: userCredential.user!.uid,
          name: 'Guest',
          email: 'guest@finesight.app',
          pictureUrl: null,
        );
    } catch (e) {
      print('Guest Login Error: $e');
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
      await _firebaseAuth.signOut();
    } catch (e) {
      print('Logout Error: $e');
      rethrow;
    }
  }
}
