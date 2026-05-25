import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  bool _loginPressed = false;

  late final AnimationController _heroCtrl;
  late final AnimationController _featuresCtrl;
  late final AnimationController _bottomCtrl;
  late final AnimationController _pulseCtrl;

  late final Animation<double> _heroFade;
  late final Animation<Offset> _heroSlide;
  late final Animation<double> _featuresFade;
  late final Animation<Offset> _featuresSlide;
  late final Animation<double> _bottomFade;
  late final Animation<Offset> _bottomSlide;
  late final Animation<double> _logoGlow;
  late final Animation<double> _logoScale;

  @override
  void initState() {
    super.initState();

    _heroCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _heroFade = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);
    _heroSlide = Tween<Offset>(
      begin: const Offset(0, -0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOutCubic));

    _featuresCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _featuresFade = CurvedAnimation(parent: _featuresCtrl, curve: Curves.easeOut);
    _featuresSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _featuresCtrl, curve: Curves.easeOutCubic));

    _bottomCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _bottomFade = CurvedAnimation(parent: _bottomCtrl, curve: Curves.easeOut);
    _bottomSlide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _bottomCtrl, curve: Curves.easeOutCubic));

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _logoGlow = Tween<double>(begin: 0.15, end: 0.32).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _logoScale = Tween<double>(begin: 1.0, end: 1.045).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _heroCtrl.forward();
    Future.delayed(const Duration(milliseconds: 280), () {
      if (mounted) _featuresCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 520), () {
      if (mounted) _bottomCtrl.forward();
    });
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    _featuresCtrl.dispose();
    _bottomCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    HapticFeedback.lightImpact();
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
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 0, 24, bottomPadding + 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Hero ─────────────────────────────────────────
              Expanded(
                flex: 5,
                child: FadeTransition(
                  opacity: _heroFade,
                  child: SlideTransition(
                    position: _heroSlide,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo container — animated pulse
                        AnimatedBuilder(
                          animation: _pulseCtrl,
                          builder: (context, child) => Transform.scale(
                            scale: _logoScale.value,
                            child: Container(
                              width: 92,
                              height: 92,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    TempusColors.accent.withValues(alpha: 0.18),
                                    TempusColors.accentBlue.withValues(alpha: 0.10),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: TempusColors.accent.withValues(alpha: 0.30),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: TempusColors.accent.withValues(
                                        alpha: _logoGlow.value),
                                    blurRadius: 48,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: child,
                            ),
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              'lib/assets/icons/icon_login.svg',
                              width: 52,
                              height: 52,
                            ),
                          ),
                        ),
                        const SizedBox(height: 26),
                        // App name — gradient text
                        ShaderMask(
                          shaderCallback: (bounds) =>
                              TempusColors.gradient.createShader(
                            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                          ),
                          child: const Text(
                            'Tempus',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 44,
                              fontFamily: 'Arimo',
                              fontWeight: FontWeight.w700,
                              letterSpacing: -1.5,
                              height: 1.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Estude com foco.\nEvolua com dados.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: TempusColors.textSub,
                            fontSize: 16,
                            fontFamily: 'Arimo',
                            fontWeight: FontWeight.w400,
                            height: 1.55,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Features ─────────────────────────────────────
              FadeTransition(
                opacity: _featuresFade,
                child: SlideTransition(
                  position: _featuresSlide,
                  child: Column(
                    children: [
                      _FeatureRow(
                        icon: Icons.timer_rounded,
                        color: TempusColors.accent,
                        title: 'Timer de Foco',
                        subtitle: 'Sessões cronometradas com modo Pomodoro',
                      ),
                      const SizedBox(height: 10),
                      _FeatureRow(
                        icon: Icons.task_alt_rounded,
                        color: TempusColors.accentBlue,
                        title: 'Gestão de Tarefas',
                        subtitle: 'Organize e priorize o que precisa estudar',
                      ),
                      const SizedBox(height: 10),
                      _FeatureRow(
                        icon: Icons.bar_chart_rounded,
                        color: TempusColors.green,
                        title: 'Estatísticas',
                        subtitle: 'Acompanhe seu progresso e sequência de dias',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── Login button ──────────────────────────────────
              FadeTransition(
                opacity: _bottomFade,
                child: SlideTransition(
                  position: _bottomSlide,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GestureDetector(
                        onTapDown: _isLoading ? null : (_) => setState(() => _loginPressed = true),
                        onTapUp: _isLoading ? null : (_) {
                          setState(() => _loginPressed = false);
                          _handleLogin();
                        },
                        onTapCancel: () => setState(() => _loginPressed = false),
                        child: AnimatedScale(
                          scale: _loginPressed ? 0.96 : 1.0,
                          duration: const Duration(milliseconds: 100),
                          curve: Curves.easeOutBack,
                          child: AnimatedOpacity(
                          opacity: _isLoading ? 0.75 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: TempusColors.gradient,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: TempusColors.accent
                                      .withValues(alpha: 0.38),
                                  blurRadius: 28,
                                  offset: const Offset(0, 8),
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
                                  : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.login_rounded,
                                            color: Colors.white, size: 20),
                                        SizedBox(width: 10),
                                        Text(
                                          'Entrar com Google',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontFamily: 'Arimo',
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.1,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lock_outline_rounded,
                            color: TempusColors.textMuted,
                            size: 12,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Dados salvos com segurança na nuvem',
                            style: TextStyle(
                              color: TempusColors.textMuted,
                              fontSize: 11,
                              fontFamily: 'Arimo',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Feature row widget ────────────────────────────────────────────

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _FeatureRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: TempusColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TempusColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: color.withValues(alpha: 0.22)),
            ),
            child: Center(child: Icon(icon, color: color, size: 20)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: TempusColors.text,
                    fontSize: 14,
                    fontFamily: 'Arimo',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: TempusColors.textSub,
                    fontSize: 12,
                    fontFamily: 'Arimo',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
