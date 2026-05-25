import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';
import 'splash_screen.dart';

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
    final results = await Future.wait([
      authenticated ? isOnboardingDone() : Future.value(false),
      Future.delayed(const Duration(milliseconds: 1800)),
    ]);
    final done = results[0] as bool;
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

  Widget get _content {
    if (_isLoading) return const SplashScreen(key: ValueKey('splash'));
    if (!_isAuthenticated) return const LoginScreen(key: ValueKey('login'));
    if (_showOnboarding) {
      return OnboardingScreen(
        key: const ValueKey('onboarding'),
        onDone: _onOnboardingDone,
      );
    }
    return const BlackoutWrapper(key: ValueKey('main'));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      child: _content,
    );
  }
}
