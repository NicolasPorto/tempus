import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tempus_app/widgets/animated_background.dart';
import 'package:tempus_app/libraries/globals.dart';
import 'package:tempus_app/libraries/screen_dimmer.dart';
import 'package:tempus_app/screens/home_screen.dart';
import 'package:tempus_app/screens/auth_wrapper.dart';
import 'package:tempus_app/services/supabase_service.dart';
import 'package:tempus_app/core/supabase/supabase_client.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseClientConfig.initialize();
  await MobileAds.instance.initialize();

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => SupabaseService()),
        ChangeNotifierProvider.value(value: tempusGlobals),
        ChangeNotifierProvider<ScreenDimmer>(create: (_) => screenDimmer),
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
      home: Stack(
        children: [
          const AnimatedBackground(child: AuthWrapper()),
          Consumer<TempusGlobals>(
            builder: (context, globals, child) {
              if (!globals.isLoading) return const SizedBox.shrink();
              return Container(
                color: Colors.black54,
                child: const Center(child: CircularProgressIndicator()),
              );
            },
          ),
        ],
      ),
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
        duration: const Duration(milliseconds: 1250),
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
            _blackoutOverlay(context, dimmer),
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

    const double minDb = 35.0;
    const double maxDb = 90.0;

    double amplitude;

    if (decibels < minDb) {
      amplitude = 1.0;
    } else {
      double clampedDb = decibels.clamp(minDb, maxDb);
      double normalizedDb = (clampedDb - minDb) / (maxDb - minDb);
      amplitude = max(1.0, normalizedDb * size.height);
    }

    for (double x = 0; x <= size.width; x += 5) {
      final double noise = (_random.nextDouble() - 0.5) * amplitude;
      final y = (size.height / 2) + noise;
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant AudioWavePainter oldDelegate) =>
      decibels != oldDelegate.decibels;
}
