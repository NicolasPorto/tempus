import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';
import 'services/storage_service.dart';
import '/libraries/globals.dart';
import 'package:provider/provider.dart';
import '/libraries/screen_dimmer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  await StorageService.initialize(prefs);
  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TempusGlobals()),
        ChangeNotifierProvider<ScreenDimmer>(create: (context) => screenDimmer), 
      ],
      child: const TempusApp(),
    )
  );
}

class TempusApp extends StatelessWidget {
  const TempusApp({super.key});
  
  Widget _materialAppContent()
    => MaterialApp(
      title: 'Tempus',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );

@override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tempus',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const BlackoutWrapper(), 
    );
  }
}

class BlackoutWrapper extends StatelessWidget {
  const BlackoutWrapper({super.key});

  Widget _blackoutOverlay(ScreenDimmer dimmer) {
    final blackoutOpacity = dimmer.blackoutOpacity;
    final isBlackedOut = dimmer.blackoutOpacity > 0.8;
    final currentOffset = dimmer.dragOffset;

    return IgnorePointer(
        ignoring: !isBlackedOut,
        child: AnimatedOpacity(
          opacity: blackoutOpacity,
          duration: const Duration(milliseconds: 2000), // 2 segundos
          child: GestureDetector(
            onVerticalDragUpdate: (details) {
              dimmer.updateDragOffset(details.delta.dy);
              if (dimmer.dragOffset < dimmer.minimumDragOffSet) {
                 dimmer.restoreTemporary();
              }
            },
            onVerticalDragEnd: (_) {
              if (dimmer.dragOffset > dimmer.minimumDragOffSet) {
                 dimmer.resetDragOffset();
              }
            },
            child: Container(
              color: Colors.black,
              constraints: const BoxConstraints.expand(),
              alignment: Alignment.bottomCenter,
              child: Transform.translate(
                offset: Offset(0.0, currentOffset),
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                      padding: const EdgeInsets.only(bottom: 50.0),
                      child: const Text(
                          'Arraste para revelar...',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white54, 
                              fontSize: 20, 
                              fontWeight: FontWeight.w900,
                          ),
                      ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final bool onFocus = context.select<TempusGlobals, bool>(
      (globals) => globals.onFocus,
    );

    return Consumer<ScreenDimmer>(
      builder: (context, dimmer, child) {
        return Stack(
          children: [
            const HomeScreen(), 
            if (onFocus) _blackoutOverlay(dimmer),
          ],
        );
      },
    );
  }
}