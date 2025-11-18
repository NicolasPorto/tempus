import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../services/authentication_service.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    final authService = Provider.of<AuthenticationService>(
      context,
      listen: false,
    );

    bool didLogin = false;
    try {
      didLogin = await authService.login();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (didLogin && context.mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!context.mounted) return;

        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const BlackoutWrapper()),
          );
        }
      });
    } else if (!didLogin) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth > 400 ? 370.31 : screenWidth * 0.9;
    const cardHeight = 567.12;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          width: cardWidth,
          height: cardHeight,
          padding: const EdgeInsets.symmetric(horizontal: 33.14),
          decoration: ShapeDecoration(
            color: const Color(0x66171717),
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1.16, color: Color(0x19FFFEFE)),
              borderRadius: BorderRadius.circular(24),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x3F000000),
                blurRadius: 50,
                offset: Offset(0, 25),
                spreadRadius: -12,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: ShapeDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment(0.00, 0.00),
                        end: Alignment(1.00, 1.00),
                        colors: [Color(0x33AC46FF), Color(0x332B7FFF)],
                      ),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                          width: 2,
                          color: Color(0x33FFFEFE),
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'lib/assets/icons/icon_login.svg',
                        width: 50,
                        height: 50,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (bounds) {
                      return const LinearGradient(
                        colors: [Color(0xFFAC46FF), Color(0xFF2B7FFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds);
                    },
                    child: const Text(
                      'Tempus',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontFamily: 'Arimo',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Entre para continuar estudando',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFA0A0A0),
                      fontSize: 16,
                      fontFamily: 'Arimo',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),

              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 47.99,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: ShapeDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment(0.00, 0.50),
                            end: Alignment(1.00, 0.50),
                            colors: [Color(0xFFAC46FF), Color(0xFF2B7FFF)],
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          shadows: const [
                            BoxShadow(
                              color: Color(0x3FAC46FF),
                              blurRadius: 6,
                              offset: Offset(0, 4),
                              spreadRadius: -4,
                            ),
                            BoxShadow(
                              color: Color(0x3FAC46FF),
                              blurRadius: 15,
                              offset: Offset(0, 10),
                              spreadRadius: -3,
                            ),
                          ],
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : const Text(
                                'Login / Sign Up',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontFamily: 'Arimo',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),

              Container(
                alignment: Alignment.center,
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: double.infinity,
                    height: 0.99,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(0.00, 0.50),
                        end: Alignment(1.00, 0.50),
                        colors: [
                          Color(0x00000000),
                          Color(0x7FAC46FF),
                          Color(0x00000000),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const Text(
                'Seus dados são armazenados localmente no seu dispositivo',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF737373),
                  fontSize: 12,
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.w400,
                  height: 1.33,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
