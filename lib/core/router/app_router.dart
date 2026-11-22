import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/category/presentation/pages/category_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/insights/presentation/pages/insights_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/shell/presentation/pages/app_shell.dart';

/// Centralized routing configuration using go_router.
///
/// Route structure:
/// - `/onboarding`      → Welcome page (shown once)
/// - `/home`            → Home page with category grid  (ShellRoute)
/// - `/insights`        → Financial insights page       (ShellRoute)
/// - `/settings`        → Settings page                 (ShellRoute)
/// - `/category/:id`    → Category detail (full-screen, outside shell)
///
/// The [ShellRoute] wraps the bottom navigation tabs so the
/// [NavigationBar] persists across tab switches.
abstract final class AppRouter {
  // Route path constants (Single Source of Truth)
  static const String onboardingPath = '/onboarding';
  static const String homePath = '/home';
  static const String insightsPath = '/insights';
  static const String settingsPath = '/settings';
  static const String categoryPath = '/category/:id';

  /// Builds the category detail path for a given [categoryId].
  static String categoryDetailPath(String categoryId) =>
      '/category/$categoryId';

  /// The main router instance.
  static final GoRouter router = GoRouter(
    initialLocation: onboardingPath,
    routes: [
      // ── Onboarding (outside shell) ──
      GoRoute(
        path: onboardingPath,
        builder: (context, state) => const OnboardingPage(),
      ),

      // ── Main app shell with bottom navigation ──
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: homePath,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomePage(),
            ),
          ),
          GoRoute(
            path: insightsPath,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: InsightsPage(),
            ),
          ),
          GoRoute(
            path: settingsPath,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsPage(),
            ),
          ),
        ],
      ),

      // ── Category detail (full-screen, outside shell) ──
      GoRoute(
        path: categoryPath,
        builder: (context, state) => CategoryPage(
          categoryId: state.pathParameters['id']!,
        ),
      ),
    ],
  );
}
