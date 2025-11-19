import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tempus_app/widgets/animated_background.dart';
import '/libraries/globals.dart';
import '/libraries/screen_dimmer.dart';
import 'screens/home_screen.dart';
import 'services/storage_service.dart';
import 'services/authentication_service.dart';
import 'screens/auth_wrapper.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  await StorageService.initialize(prefs);
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (context) => AuthenticationService()),
        ChangeNotifierProvider(create: (context) => TempusGlobals()),
        ChangeNotifierProvider<ScreenDimmer>(create: (context) => screenDimmer),
        ProxyProvider<AuthenticationService, ApiService>(
          update: (context, authService, previousApiService) =>
              ApiService(authService),
        ),
      ],
      child: const TempusApp(),
    ),
  );
}

class TempusApp extends StatelessWidget {
  const TempusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tempus',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.indigo,
        ).copyWith(background: Colors.transparent),
      ),
      debugShowCheckedModeBanner: false,
      home: const AnimatedBackground(child: AuthWrapper()),
    );
  }
}

class BlackoutWrapper extends StatelessWidget {
  const BlackoutWrapper({super.key});

  Widget _blackoutOverlay(BuildContext context, ScreenDimmer dimmer) {
    final blackoutOpacity = dimmer.blackoutOpacity;
    final isBlackedOut = dimmer.blackoutOpacity > 0.8;
    final currentOffset = dimmer.dragOffset;
    final textOpacity = (1 - (currentOffset.abs() / 100)).clamp(0.0, 1.0);

    return IgnorePointer(
      ignoring: !isBlackedOut,
      child: AnimatedOpacity(
        opacity: blackoutOpacity,
        duration: const Duration(milliseconds: 750),
        child: GestureDetector(
          onVerticalDragUpdate: (details) {
            dimmer.updateDragOffset(details.delta.dy);
          },
          onVerticalDragEnd: (_) {
            if (dimmer.dragOffset < dimmer.minimumDragOffSet) {
              dimmer.stopBlackout();
            }
            dimmer.resetDragOffset();
          },
          child: Container(
            color: Colors.black,
            constraints: const BoxConstraints.expand(),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Center(
                  child: ValueListenableBuilder<double>(
                    valueListenable: dimmer.currentDecibels,
                    builder: (context, decibels, child) {
                      return CustomPaint(
                        size: Size(MediaQuery.of(context).size.width, 100),
                        painter: AudioWavePainter(decibels: decibels),
                      );
                    },
                  ),
                ),
                Transform.translate(
                  offset: Offset(0.0, currentOffset),
                  child: SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 50.0),
                      child: Material(
                        color: Colors.transparent,
                        child: Icon(
                          Icons.keyboard_arrow_up,
                          color: Colors.white54.withOpacity(textOpacity),
                          size: 64.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ScreenDimmer>(
      builder: (context, dimmer, child) {
        return Stack(
          children: [
            const HomeScreen(),
            if (dimmer.blackoutOpacity > 0.0) _blackoutOverlay(context, dimmer),
          ],
        );
      },
    );
  }
}

class AudioWavePainter extends CustomPainter {
  final double decibels;
  final Random _random = Random();

  AudioWavePainter({required this.decibels});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    path.moveTo(0, size.height / 2);

    final double maxAmplitude = size.height;
    final double minDb = 35.0;
    final double maxDb = 90.0;

    double amplitude;

    if (decibels < minDb) {
      amplitude = 1.0;
    } else {
      double clampedDb = decibels.clamp(minDb, maxDb);
      double normalizedDb = (clampedDb - minDb) / (maxDb - minDb);
      amplitude = max(1.0, normalizedDb * maxAmplitude);
    }

    final double step = 5;

    for (double x = 0; x <= size.width; x += step) {
      final double noise = (_random.nextDouble() - 0.5) * amplitude;
      final y = (size.height / 2) + noise;
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant AudioWavePainter oldDelegate) {
    return decibels != oldDelegate.decibels;
  }
}
