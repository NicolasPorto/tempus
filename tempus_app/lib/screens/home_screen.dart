import 'package:flutter/material.dart';
import '../widgets/navigation_container.dart';
import '../widgets/animated_background.dart';
import '../libraries/globals.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    context.select<TempusGlobals, bool>(
      (globals) => globals.onFocus,
    );

    return OrbDynamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: const NavigationContainer(),
      ),
    );
  }
}
