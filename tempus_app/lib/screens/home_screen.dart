import 'package:flutter/material.dart';
import 'package:tempus_app/widgets/animated_background.dart';
import '../widgets/navigation_container.dart';
import '../libraries/globals.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    context.select<TempusGlobals, bool>((globals) => globals.onFocus);

    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: const NavigationContainer(),
      ),
    );
  }
}
