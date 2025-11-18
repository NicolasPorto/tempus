import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../services/authentication_service.dart';
import 'login_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  void _checkAuthStatus() async {
    final authService = Provider.of<AuthenticationService>(
      context,
      listen: false,
    );
    final isAuthenticated = await authService.checkCredentials();

    setState(() {
      _isAuthenticated = isAuthenticated;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color.fromARGB(255, 18, 32, 47),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (_isAuthenticated) {
      return const BlackoutWrapper();
    } else {
      return const LoginScreen();
    }
  }
}
