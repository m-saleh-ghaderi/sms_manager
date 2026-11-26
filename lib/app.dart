import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/constants/app_constants.dart';
import 'core/di/app_dependencies.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';

/// Root application widget for SMS Manager.
///
/// Configures:
/// - Persian locale ('fa') with RTL layout direction by default
/// - Material 3 Light & Dark themes with Vazirmatn typography
/// - Reactive theme mode switching via [ThemeController]
/// - Declarative routing with go_router via [AppRouter]
class SmsManagerApp extends StatelessWidget {
  const SmsManagerApp({
    super.key,
    this.themeController,
  });

  final ThemeController? themeController;

  @override
  Widget build(BuildContext context) {
    final controller =
        themeController ?? AppDependencies.instance.themeController;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
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
          themeMode: controller.themeMode,

          // Keep Android status & navigation bars synced on pages without AppBar (e.g. Splash)
          builder: (context, child) {
            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness:
                    isDark ? Brightness.light : Brightness.dark,
                statusBarBrightness: theme.brightness,
                systemNavigationBarColor: theme.colorScheme.surface,
                systemNavigationBarIconBrightness:
                    isDark ? Brightness.light : Brightness.dark,
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },

          // ── Router ──
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
