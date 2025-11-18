import 'package:flutter/material.dart';
import 'package:tempus_app/widgets/animated_background.dart';
import '../widgets/navigation_container.dart';
import '../libraries/globals.dart';
import 'package:provider/provider.dart';
import '../services/authentication_service.dart';
import 'login_screen.dart';

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
        // appBar: AppBar(
        //   backgroundColor: Colors.transparent,
        //   elevation: 0,
        //   actions: [
        //     IconButton(
        //       icon: const Icon(Icons.logout),
        //       tooltip: 'Logout',
        //       onPressed: () async {
        //         final authService = Provider.of<AuthenticationService>(
        //           context,
        //           listen: false,
        //         );

        //         bool didLogout = false;
        //         try {
        //           didLogout = await authService.logout();
        //         } catch (e) {
        //           if (context.mounted) {
        //             ScaffoldMessenger.of(context).showSnackBar(
        //               SnackBar(content: Text('Logout failed: $e')),
        //             );
        //           }
        //           return;
        //         }

        //         if (didLogout && context.mounted) {
        //           WidgetsBinding.instance.addPostFrameCallback((_) {
        //             if (context.mounted) {
        //               Navigator.of(context).pushAndRemoveUntil(
        //                 MaterialPageRoute(
        //                   builder: (context) => const LoginScreen(),
        //                 ),
        //                 (Route<dynamic> route) => false,
        //               );
        //             }
        //           });
        //         }
        //       },
        //     ),
        //   ],
        // ),
        body: const NavigationContainer(),
      ),
    );
  }
}
