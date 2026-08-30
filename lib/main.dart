import 'package:flutter/material.dart';
import 'package:mass_ledger/ViewModel/ledger_viewmodel.dart';
import 'package:provider/provider.dart';

import 'views/splash_screen.dart';

// ================================================================
// MAIN
// ================================================================

void main() {
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