import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class GoogleSignInService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  // Sign in with Google
  static Future<GoogleSignInAccount?> signIn() async {
    try {
      return await _googleSignIn.signIn();
    } catch (error) {
      if (kDebugMode) {
        print('Google Sign-In Error: $error');
      }
      return null;
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (error) {
      if (kDebugMode) {
        print('Google Sign-Out Error: $error');
      }
    }
  }

  // Check if user is signed in
  static Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  // Get current user
  static Future<GoogleSignInAccount?> getCurrentUser() async {
    return _googleSignIn.currentUser;
  }

  // Disconnect (revoke access)
  static Future<void> disconnect() async {
    try {
      await _googleSignIn.disconnect();
    } catch (error) {
      if (kDebugMode) {
        print('Google Disconnect Error: $error');
      }
    }
  }
}
