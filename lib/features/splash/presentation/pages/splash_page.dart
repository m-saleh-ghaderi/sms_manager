import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/permissions/permission_service.dart';
import '../../../../core/router/app_router.dart';

/// Splash & Loading screen shown on app launch.
///
/// Follows Single Responsibility Principle (SRP):
/// 1. Displays app branding and loading status.
/// 2. Automatically requests necessary SMS and Contacts permissions.
/// 3. Navigates directly to [HomePage] upon permission approval.
/// 4. Provides recovery actions if permissions are denied.
class SplashPage extends StatefulWidget {
  const SplashPage({
    super.key,
    this.permissionService = const PermissionService(),
  });

  final IPermissionService permissionService;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  String _statusMessage = 'در حال راه‌اندازی و بررسی مجوزها...';
  bool _hasError = false;
  bool _isPermanentlyDenied = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initAndCheckPermissions();
    });
  }

  Future<void> _initAndCheckPermissions() async {
    setState(() {
      _statusMessage = 'در حال بررسی دسترسی‌ها...';
      _hasError = false;
      _isPermanentlyDenied = false;
    });

    // Slight delay for smooth visual transition
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    final status = await widget.permissionService.requestRequiredPermissions();
    if (!mounted) return;

    switch (status) {
      case AppPermissionStatus.granted:
        context.go(AppRouter.homePath);
      case AppPermissionStatus.permanentlyDenied:
        setState(() {
          _hasError = true;
          _isPermanentlyDenied = true;
          _statusMessage =
              'دسترسی پیامک یا مخاطبین غیرفعال است.\nلطفاً از تنظیمات برنامه آن را فعال کنید.';
        });
      case AppPermissionStatus.denied:
        setState(() {
          _hasError = true;
          _isPermanentlyDenied = false;
          _statusMessage =
              'برای خواندن و دسته‌بندی پیامک‌ها، نیاز به تایید دسترسی است.';
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),

                // App Brand Icon
                Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.15),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.mark_chat_unread_rounded,
                    size: 54,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),

                // App Title
                Text(
                  AppConstants.appName,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'مدیریت و دسته‌بندی هوشمند و آفلاین پیامک‌ها',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),

                const Spacer(flex: 2),

                // Loading Indicator / Status or Error actions
                if (!_hasError) ...[
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _statusMessage,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ] else ...[
                  Icon(
                    Icons.info_outline_rounded,
                    color: theme.colorScheme.error,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _statusMessage,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (_isPermanentlyDenied)
                    FilledButton.icon(
                      onPressed: () {
                        widget.permissionService.openAppSettingsScreen();
                      },
                      icon: const Icon(Icons.settings_outlined),
                      label: const Text('باز کردن تنظیمات برنامه'),
                    )
                  else
                    FilledButton.icon(
                      onPressed: _initAndCheckPermissions,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('تلاش مجدد و تایید دسترسی'),
                    ),
                ],

                const Spacer(flex: 1),

                // Bottom Offline Guarantee Note
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 16,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '۱۰۰٪ آفلاین و محافظت از حریم خصوصی',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
