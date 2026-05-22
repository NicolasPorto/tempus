import 'package:flutter/material.dart';
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

    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: NavigationContainer(),
      ),
    );
  }
}
