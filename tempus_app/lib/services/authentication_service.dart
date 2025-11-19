import 'package:flutter/material.dart';
import 'package:auth0_flutter/auth0_flutter.dart';

class AuthenticationService {
  final Auth0 _auth0 = Auth0(
    'dev-tempus.us.auth0.com',
    'H6jITfyPgE1IyIR5rbyRCJtGjJ99alhK',
  );

  Credentials? _credentials;
  Credentials? get credentials => _credentials;

  bool get isAuthenticated => _credentials != null;

  Future<bool> checkCredentials() async {
    try {
      // If a Refresh Token is present, this method automatically refreshes 
      // the Access Token if it has expired.
      final bool hasCredentials = await _auth0.credentialsManager.hasValidCredentials();
      
      if (hasCredentials) {
        _credentials = await _auth0.credentialsManager.credentials();
        print('--- AUTH RESTORED ---');
        print('Access Token: ${_credentials?.accessToken}');
        print('-----------------------');
        return true;
      }
      return false;
    } catch (e) {
      print('Error checking credentials: $e');
      return false;
    }
  }

  Future<bool> login() async {
    try {
      final creds = await _auth0
          .webAuthentication(scheme: 'com.dev.tempusapp')
          .login(
            audience: 'https://tempusapi.fly.dev/',
            // --- ADD THIS SECTION ---
            scopes: {
              'openid',
              'profile',
              'email',
              'offline_access' // <--- This requests the Refresh Token
            },
          );
      
      _credentials = creds;

      print('--- AUTH SUCCESS ---');
      print('Access Token: ${_credentials?.accessToken}');
      print('Refresh Token: ${_credentials?.refreshToken}'); // You should see this now
      print('--------------------');

      // REMOVED: await _auth0.credentialsManager.storeCredentials(_credentials!);
      // Reason: The SDK stores it automatically on login.

      return true;
    } catch (e) {
      print('Error logging in: $e');
      throw e;
    }
  }

  Future<bool> logout() async {
    try {
      await _auth0
          .webAuthentication(scheme: 'com.dev.tempusapp')
          .logout();
      _credentials = null;
      
      // This ensures the Refresh Token is removed from the device
      await _auth0.credentialsManager.clearCredentials();
      return true;
    } catch (e) {
      print('Error logging out: $e');
      throw e;
    }
  }
}