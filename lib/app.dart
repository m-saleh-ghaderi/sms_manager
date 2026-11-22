import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// Root application widget for SMS Manager.
///
/// Configures:
/// - Persian locale ('fa') with RTL layout direction by default
/// - Material 3 Light & Dark themes with Vazirmatn typography
/// - Declarative routing with go_router via [AppRouter]
class SmsManagerApp extends StatelessWidget {
  const SmsManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // ── Localization & RTL ──
      locale: const Locale('fa'),
      supportedLocales: const [
        Locale('fa'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ── Themes ──
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,

      // ── Router ──
      routerConfig: AppRouter.router,
    );
  }
}
