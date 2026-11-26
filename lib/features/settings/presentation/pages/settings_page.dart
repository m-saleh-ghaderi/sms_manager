import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/app_dependencies.dart';
import '../../../../core/theme/theme_controller.dart';

/// Settings page: app preferences, theme customization, and backup.
///
/// Tab 3 of the bottom navigation shell.
class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    this.themeController,
  });

  final ThemeController? themeController;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final ThemeController _themeController;
  bool _notificationsEnabled = true;
  bool _biometricLock = false;

  @override
  void initState() {
    super.initState();
    _themeController =
        widget.themeController ?? AppDependencies.instance.themeController;
  }

  String _themeModeLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'روشن (سفید)',
      ThemeMode.dark => 'تیره (دارک)',
      ThemeMode.system => 'پیروی از تم سیستم (روشن / تیره)',
    };
  }

  IconData _themeModeIcon(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => Icons.light_mode_rounded,
      ThemeMode.dark => Icons.dark_mode_rounded,
      ThemeMode.system => Icons.brightness_auto_rounded,
    };
  }

  Future<void> _showThemePickerSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final currentMode = _themeController.themeMode;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'انتخاب تم برنامه',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _ThemeOptionTile(
                  title: 'تم روشن (سفید)',
                  subtitle: 'پس‌زمینه روشن برای استفاده در روز',
                  icon: Icons.light_mode_rounded,
                  selected: currentMode == ThemeMode.light,
                  onTap: () {
                    _themeController.setThemeMode(ThemeMode.light);
                    Navigator.of(sheetContext).pop();
                  },
                ),
                _ThemeOptionTile(
                  title: 'تم تیره (دارک)',
                  subtitle: 'پس‌زمینه تیره و راحت برای چشم در شب',
                  icon: Icons.dark_mode_rounded,
                  selected: currentMode == ThemeMode.dark,
                  onTap: () {
                    _themeController.setThemeMode(ThemeMode.dark);
                    Navigator.of(sheetContext).pop();
                  },
                ),
                _ThemeOptionTile(
                  title: 'هماهنگ با سیستم',
                  subtitle: 'تغییر خودکار بر اساس تنظیمات گوشی',
                  icon: Icons.brightness_auto_rounded,
                  selected: currentMode == ThemeMode.system,
                  onTap: () {
                    _themeController.setThemeMode(ThemeMode.system);
                    Navigator.of(sheetContext).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final platformBrightness = MediaQuery.platformBrightnessOf(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تنظیمات'),
      ),
      body: ListView(
        children: [
          // App Header Card
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                    Icons.mark_chat_read_rounded,
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppConstants.appName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'نسخه ۱.۰.۰ (آفلاین و امن)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),

          // Section 1: Appearance & Display
          const _SectionHeader(title: 'ظاهر و نمایش'),
          ListenableBuilder(
            listenable: _themeController,
            builder: (context, _) {
              final currentMode = _themeController.themeMode;
              final isDark = _themeController.isDarkActive(platformBrightness);

              return Column(
                children: [
                  ListTile(
                    leading: Icon(_themeModeIcon(currentMode)),
                    title: const Text('تم برنامه'),
                    subtitle: Text(_themeModeLabel(currentMode)),
                    trailing: const Icon(Icons.arrow_back_ios_new, size: 16),
                    onTap: _showThemePickerSheet,
                  ),
                  SwitchListTile(
                    secondary: Icon(
                      isDark
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_outlined,
                    ),
                    title: const Text('حالت تیره (Dark Mode)'),
                    subtitle: Text(
                      isDark ? 'تم تیره فعال است' : 'تم روشن فعال است',
                    ),
                    value: isDark,
                    onChanged: (enabled) {
                      _themeController.setThemeMode(
                        enabled ? ThemeMode.dark : ThemeMode.light,
                      );
                    },
                  ),
                ],
              );
            },
          ),
          const ListTile(
            leading: Icon(Icons.font_download_outlined),
            title: Text('فونت'),
            subtitle: Text('وزیرمتن (Vazirmatn)'),
          ),

          // Section 2: Security & Privacy
          const _SectionHeader(title: 'امنیت و حریم خصوصی'),
          SwitchListTile(
            secondary: const Icon(Icons.fingerprint_rounded),
            title: const Text('قفل بیومتریک'),
            subtitle: const Text('ورود با اثر انگشت برای امنیت پیامک‌های بانکی'),
            value: _biometricLock,
            onChanged: (val) {
              setState(() => _biometricLock = val);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active_outlined),
            title: const Text('اعلان‌ها'),
            subtitle: const Text('اعلان برای پیامک‌های مهم و قبوض'),
            value: _notificationsEnabled,
            onChanged: (val) {
              setState(() => _notificationsEnabled = val);
            },
          ),

          // Section 3: Data & Classification
          _SectionHeader(title: 'مدیریت داده و دسته‌بندی'),
          ListTile(
            leading: const Icon(Icons.rule_rounded),
            title: const Text('قوانین سفارشی کاربر'),
            subtitle: const Text('تعریف قانون دسته‌بندی برای فرستنده‌های خاص'),
            trailing: const Icon(Icons.arrow_back_ios_new, size: 16),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.sync_rounded),
            title: const Text('دسته‌بندی مجدد همه پیام‌ها'),
            subtitle: const Text('اعمال مجدد الگوریتم روی صندوق پیام'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('این قابلیت در فاز ۲ فعال می‌شود')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: const Text('پشتیبان‌گیری و خروجی'),
            subtitle: const Text('دریافت خروجی دیتابیس محلی (CSV / JSON)'),
            onTap: () {},
          ),

          const Divider(),
          // About Section
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text('درباره برنامه'),
            subtitle: const Text('طراحی‌شده بر اساس Clean Architecture و SOLID'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ThemeOptionTile extends StatelessWidget {
  const _ThemeOptionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      selected: selected,
      selectedTileColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
      leading: Icon(
        icon,
        color: selected ? theme.colorScheme.primary : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: selected
          ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}
