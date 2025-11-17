import 'package:flutter/material.dart';
import '../widgets/navigation_container.dart';
import '../widgets/animated_background.dart';
import '../libraries/globals.dart';
import 'package:provider/provider.dart';
import '../services/authentication_service.dart';
import 'login_screen.dart';

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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () async {
                final authService = Provider.of<AuthenticationService>(
                  context,
                  listen: false,
                );

                await authService.logout(context);

                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                        (Route<dynamic> route) => false,
                  );
                }
              },
            ),
          ],
        ),
        body: const NavigationContainer(),
      ),
    );
  }
}