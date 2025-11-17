import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import 'login_screen.dart';
import '../services/authentication_service.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final authService = Provider.of<AuthenticationService>(context, listen: false);

    final bool loggedIn = await authService.isLoggedIn();

    if (!mounted) return;

    if (loggedIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const BlackoutWrapper()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color.fromARGB(255, 18, 32, 47),
      body: Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );
  }
}