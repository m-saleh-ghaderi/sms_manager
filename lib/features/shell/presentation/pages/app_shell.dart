import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';

/// Main application shell providing persistent bottom navigation.
///
/// Uses go_router's [ShellRoute] pattern: the [child] parameter
/// receives the currently active tab page, while the [NavigationBar]
/// remains visible across all tabs.
///
/// Tabs:
/// - خانه (Home)       → Category grid
/// - تراکنش‌ها (Insights) → Financial summary
/// - تنظیمات (Settings)   → App configuration
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  /// The routed page content displayed above the navigation bar.
  final Widget child;

  /// Determines the active tab index from the current route location.
  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith(AppRouter.insightsPath)) return 1;
    if (location.startsWith(AppRouter.settingsPath)) return 2;
    return 0; // Default to home
  }

  /// Navigates to the tab at [index].
  void _onDestinationSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRouter.homePath);
      case 1:
        context.go(AppRouter.insightsPath);
      case 2:
        context.go(AppRouter.settingsPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex(context),
        onDestinationSelected: (index) =>
            _onDestinationSelected(context, index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'خانه',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights_rounded),
            label: 'تراکنش‌ها',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'تنظیمات',
          ),
        ],
      ),
    );
  }
}
