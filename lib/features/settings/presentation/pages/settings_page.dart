import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';

/// Settings page: app preferences, theme customization, and backup.
///
/// Tab 3 of the bottom navigation shell.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _biometricLock = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          _SectionHeader(title: 'ظاهر و نمایش'),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('تم برنامه'),
            subtitle: const Text('پیروی از تم سیستم (روشن / تیره)'),
            trailing: const Icon(Icons.arrow_back_ios_new, size: 16),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.font_download_outlined),
            title: const Text('فونت'),
            subtitle: const Text('وزیرمتن (Vazirmatn)'),
          ),

          // Section 2: Security & Privacy
          _SectionHeader(title: 'امنیت و حریم خصوصی'),
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
