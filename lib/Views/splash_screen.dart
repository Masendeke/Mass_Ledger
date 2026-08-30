import 'package:flutter/material.dart';
import 'package:mass_ledger/Views/app_shell.dart';

import 'package:mass_ledger/Views/calendar_screen.dart';
//import 'package:mass_ledger/Views/calendar_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

//import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    _checkLoginStatus();
  }

  // ==========================================================
  // CHECK LOGIN STATUS
  // ==========================================================

  Future<void> _checkLoginStatus() async {
    // Give the splash screen a little time to display
    await Future.delayed(
      const Duration(seconds: 2),
    );

    final prefs =
        await SharedPreferences.getInstance();

    // Check if the user has logged in before
    final isLoggedIn =
        prefs.getBool('isLoggedIn') ?? false;

    if (!mounted) return;

    if (isLoggedIn) {
      // ------------------------------------------------------
      // USER IS ALREADY LOGGED IN
      // Go directly to Calendar Screen
      // ------------------------------------------------------

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const CalendarScreen(),
        ),
      );
    } else {
      // ------------------------------------------------------
      // USER IS NOT LOGGED IN
      // Go to Login Screen
      // ------------------------------------------------------

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const AppShell(
                initialIndex: 0,
              ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 3, 29, 50),
              Color.fromARGB(255, 12, 55, 82),
            ],
          ),
        ),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            // ==================================================
            // LOGO
            // ==================================================

            Container(
              width: 110,
              height: 110,

              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,

                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black.withValues(
                      alpha: 0.2,
                    ),
                    blurRadius: 15,
                    offset:
                        const Offset(0, 6),
                  ),
                ],
              ),

              child: const Icon(
                Icons.account_balance_wallet_outlined,
                size: 55,
                color:
                    Color.fromARGB(
                  255,
                  3,
                  29,
                  50,
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ==================================================
            // APP NAME
            // ==================================================

            const Text(
              'Mass Ledger',

              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // ==================================================
            // SUBTITLE
            // ==================================================

            const Text(
              'Track your daily profit and loss',

              textAlign: TextAlign.center,

              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 40),

            // ==================================================
            // LOADING INDICATOR
            // ==================================================

            const SizedBox(
              width: 28,
              height: 28,

              child:
                  CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}