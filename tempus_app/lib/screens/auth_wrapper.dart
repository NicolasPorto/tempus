import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';

Shader _gradientShader(Rect bounds) =>
    TempusColors.gradient.createShader(bounds);

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isAuthenticated = false;
  bool _showOnboarding = false;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _checkInitialState();
    _authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      if (!mounted) return;
      final authenticated = data.session != null;
      if (authenticated && !_isAuthenticated) {
        // Just logged in — check onboarding
        final done = await isOnboardingDone();
        if (mounted) {
          setState(() {
            _isAuthenticated = true;
            _showOnboarding = !done;
          });
        }
      } else if (mounted) {
        setState(() => _isAuthenticated = authenticated);
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkInitialState() async {
    final session = Supabase.instance.client.auth.currentSession;
    final authenticated = session != null;
    final done = authenticated ? await isOnboardingDone() : false;
    if (mounted) {
      setState(() {
        _isAuthenticated = authenticated;
        _showOnboarding = authenticated && !done;
        _isLoading = false;
      });
    }
  }

  void _onOnboardingDone() {
    setState(() => _showOnboarding = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ShaderMask(
                shaderCallback: _gradientShader,
                child: Text(
                  'Tempus',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontFamily: 'Arimo',
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1,
                  ),
                ),
              ),
              SizedBox(height: 32),
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Color(0xFFA855F7),
                  strokeWidth: 2,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isAuthenticated) return const LoginScreen();

    if (_showOnboarding) {
      return OnboardingScreen(onDone: _onOnboardingDone);
    }

    return const BlackoutWrapper();
  }
}
