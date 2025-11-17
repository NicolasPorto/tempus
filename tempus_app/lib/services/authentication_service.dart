import 'package:flutter/material.dart';
import 'package:auth0_flutter/auth0_flutter.dart';

class AuthenticationService {
  final Auth0 auth0 = Auth0(
      'dev-tempus.us.auth0.com',
      'H6jITfyPgE1IyIR5rbyRCJtGjJ99alhK'
  );

  Credentials? credentials;

  Future<bool> isLoggedIn() async {
    try {
      final bool hasCredentials = await auth0.credentialsManager.hasValidCredentials();

      if (hasCredentials) {
        this.credentials = await auth0.credentialsManager.credentials();
        return true;
      }
      return false;
    } catch (e) {
      print("Error checking credentials: $e");
      return false;
    }
  }

  Future<bool> login(BuildContext context) async {
    try {
      final Credentials credentials = await auth0
          .webAuthentication(scheme: 'com.dev.tempusapp')
          .login(
          audience: 'https://tempusapi.fly.dev/',
          scopes: {
            'openid',
            'profile',
            'email',
            'offline_access'
          }
      );

      this.credentials = credentials;
      print('Access Token: ${credentials.accessToken}');
      print('User ID: ${credentials.user.sub}');
      print('User Email: ${credentials.user.email}');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login successful! Welcome ${credentials.user.name}'))
        );
      }
      return true;

    } on WebAuthenticationException catch (e) {
      print(e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed: ${e.message}'))
        );
      }
      return false;
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      await auth0
          .webAuthentication(scheme: 'com.dev.tempusapp')
          .logout();

      this.credentials = null;

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Logout successful'))
        );
      }

    } on WebAuthenticationException catch (e) {
      print(e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Logout failed: ${e.message}'))
        );
      }
    }
  }
}