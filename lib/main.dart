import 'package:flutter/material.dart';
import 'package:mass_ledger/ViewModel/ledger_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'Views/login_screen.dart';
import 'Views/splash_screen.dart';

final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey<NavigatorState>();

// ================================================================
// MAIN
// ================================================================

Future<void> main() async {
  // Required before using asynchronous code in main().
  WidgetsFlutterBinding.ensureInitialized();

  // ==============================================================
  // SUPABASE INITIALIZATION
  // ==============================================================

  await Supabase.initialize(
    url: 'https://phiofuqttskjvsyqbukf.supabase.co',
    // ignore: deprecated_member_use
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBoaW9mdXF0dHNranZzeXFidWtmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODgxMTA4MzIsImV4cCI6MjEwMzY4NjgzMn0.MXD89_zwvbPdzbpcXes9WliyJa4SbVkoI0e5PuCVXOo',
  );

  // ==============================================================
  // PASSWORD RECOVERY
  // ==============================================================
  //
  // When the user opens the link from the "Forgot password" email,
  // Supabase signs them in temporarily and fires passwordRecovery.
  // Show the screen where they choose a new password.

  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    if (data.event == AuthChangeEvent.passwordRecovery) {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const ResetPasswordScreen(),
        ),
        (route) => false,
      );
    }
  });

  // ==============================================================
  // START APP
  // ==============================================================

  runApp(
    const MassLedgerApp(),
  );
}

// ================================================================
// MASS LEDGER APP
// ================================================================

class MassLedgerApp extends StatelessWidget {
  const MassLedgerApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LedgerViewModel(),

      child: MaterialApp(
        navigatorKey: navigatorKey,

        debugShowCheckedModeBanner: false,

        title: 'Mass Ledger',

        // ========================================================
        // THEME
        // ========================================================

        theme: ThemeData(
          useMaterial3: true,

          scaffoldBackgroundColor:
              const Color(0xFFF7F8FA),

          colorScheme:
              ColorScheme.fromSeed(
            seedColor:
                const Color(0xFF09275F),
          ),

          // ======================================================
          // APP BAR
          // ======================================================

          appBarTheme:
              const AppBarTheme(
            backgroundColor:
                Colors.white,

            foregroundColor:
                Color(0xFF09275F),

            elevation: 0,

            centerTitle: false,
          ),

          // ======================================================
          // INPUT FIELDS
          // ======================================================

          inputDecorationTheme:
              InputDecorationTheme(
            filled: true,

            fillColor:
                Colors.white,

            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),

            border:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                10,
              ),

              borderSide:
                  BorderSide(
                color:
                    Colors.grey.shade300,
              ),
            ),

            enabledBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                10,
              ),

              borderSide:
                  BorderSide(
                color:
                    Colors.grey.shade300,
              ),
            ),

            focusedBorder:
                const OutlineInputBorder(
              borderRadius:
                  BorderRadius.all(
                Radius.circular(10),
              ),

              borderSide:
                  BorderSide(
                color:
                    Color(0xFF09275F),
                width: 1.5,
              ),
            ),

            errorBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                10,
              ),

              borderSide:
                  const BorderSide(
                color:
                    Colors.red,
              ),
            ),

            focusedErrorBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                10,
              ),

              borderSide:
                  const BorderSide(
                color:
                    Colors.red,
              ),
            ),
          ),

          // ======================================================
          // ELEVATED BUTTON
          // ======================================================

          elevatedButtonTheme:
              ElevatedButtonThemeData(
            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(
                0xFF09275F,
              ),

              foregroundColor:
                  Colors.white,

              elevation: 0,

              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  10,
                ),
              ),
            ),
          ),

          // ======================================================
          // OUTLINED BUTTON
          // ======================================================

          outlinedButtonTheme:
              OutlinedButtonThemeData(
            style:
                OutlinedButton.styleFrom(
              foregroundColor:
                  const Color(
                0xFF09275F,
              ),

              side:
                  BorderSide(
                color:
                    Colors.grey.shade300,
              ),

              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  10,
                ),
              ),
            ),
          ),

          // ======================================================
          // NAVIGATION BAR
          // ======================================================

          navigationBarTheme:
              const NavigationBarThemeData(
            backgroundColor:
                Colors.white,

            indicatorColor:
                Color(0xFFE7EDF7),

            labelTextStyle:
                WidgetStatePropertyAll(
              TextStyle(
                fontSize: 10,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ),

        // ========================================================
        // FIRST SCREEN
        // ========================================================
        //
        // The app will now open with the Splash Screen.
        //
        // Splash Screen checks:
        //
        // isLoggedIn == true
        //       ↓
        // Calendar Screen
        //
        // isLoggedIn == false
        //       ↓
        // Login Screen
        //
        // ========================================================

        home:
            const SplashScreen(),
      ),
    );
  }
}