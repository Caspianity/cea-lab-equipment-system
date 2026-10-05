// -----------------------------------------------------------------------------
// LabTrack - application root widget
//
// Extracted from firstFile.dart on 2026-08-03 as step 8 (final) of the module
// split. firstFile.dart is retired by this step.
// -----------------------------------------------------------------------------

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'theme.dart';
import 'screens/auth/splash_screen.dart';

// ─── App Entry ───────────────────────────────────────────────────────────────
// (The real main() lives in lib/main.dart — this library only exports the app.)

// The web build is the staff portal (prof's comment 2026-10-05). Its screens
// were made for a phone, so on a monitor the whole app sits in a centred frame
// instead of stretching edge to edge.
const double kWebMaxWidth = 1280;

class LabBorrowApp extends StatelessWidget {
  const LabBorrowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kIsWeb ? 'LabTrack Staff Portal' : 'LabTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      builder: kIsWeb
          ? (context, child) => ColoredBox(
                color: const Color(0xFFDDE3EF),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: kWebMaxWidth),
                    child: child,
                  ),
                ),
              )
          : null,
    );
  }
}
