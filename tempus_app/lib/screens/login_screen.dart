import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  void _handleLogin() async {
    setState(() => _isLoading = true);

    try {
      await context.read<SupabaseService>().signInWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login falhou: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth > 420 ? 360.0 : screenWidth * 0.88;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          width: cardWidth,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: TempusColors.surface.withOpacity(0.9),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: TempusColors.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x50000000),
                blurRadius: 60,
                offset: Offset(0, 24),
                spreadRadius: -8,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0x33A855F7), Color(0x1560A5FA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: TempusColors.accent.withOpacity(0.3),
                    ),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'lib/assets/icons/icon_login.svg',
                      width: 40,
                      height: 40,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Center(
                child: Text(
                  'Tempus',
                  style: TextStyle(
                    color: TempusColors.text,
                    fontSize: 28,
                    fontFamily: 'Arimo',
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              const Center(
                child: Text(
                  'Entre para continuar estudando',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: TempusColors.textSub,
                    fontSize: 14,
                    fontFamily: 'Arimo',
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Login button
              GestureDetector(
                onTap: _isLoading ? null : _handleLogin,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: TempusColors.gradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: TempusColors.accent.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Login / Sign Up',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Arimo',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Seus dados são sincronizados com segurança na nuvem',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: TempusColors.textMuted,
                  fontSize: 11,
                  fontFamily: 'Arimo',
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
