import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/permissions/permission_service.dart';
import '../../../../core/router/app_router.dart';
import '../widgets/permission_card.dart';

/// Welcome / Onboarding page shown on initial launch.
///
/// Follows Single Responsibility Principle (SRP):
/// 1. Educates user on SMS & Contacts permissions and privacy guarantees.
/// 2. Requests permissions through [IPermissionService].
/// 3. Handles permanently denied states by routing users to system settings.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({
    super.key,
    this.permissionService = const PermissionService(),
  });

  final IPermissionService permissionService;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  bool _isLoading = false;

  Future<void> _handlePermissionRequest() async {
    setState(() => _isLoading = true);

    try {
      final status = await widget.permissionService.requestRequiredPermissions();

      if (!mounted) return;

      switch (status) {
        case AppPermissionStatus.granted:
          context.go(AppRouter.homePath);
        case AppPermissionStatus.permanentlyDenied:
          _showPermanentlyDeniedDialog();
        case AppPermissionStatus.denied:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'برای خواندن و دسته‌بندی خودکار، دسترسی به پیامک و مخاطبین الزامی است.',
              ),
              duration: Duration(seconds: 4),
            ),
          );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showPermanentlyDeniedDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.settings_suggest_rounded, size: 40),
        title: const Text('دسترسی‌ها غیرفعال است'),
        content: const Text(
          'دسترسی پیامک یا مخاطبین رد شده است. لطفاً برای فعال‌سازی وارد تنظیمات برنامه شوید.\n\n'
          'نکته در اندروید ۱۳ به بالا: اگر گزینه‌ها خاکستری بود، از منوی سه نقطه بالای صفحه تنظیمات، گزینه Allow restricted settings را انتخاب کنید.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('انصراف'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.permissionService.openAppSettingsScreen();
            },
            icon: const Icon(Icons.open_in_new_rounded),
            label: const Text('باز کردن تنظیمات'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // App Logo / Icon Header
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.mark_chat_unread_rounded,
                  size: 50,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 20),

              // Title & Subtitle
              Text(
                'به ${AppConstants.appName} خوش آمدید',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'سازمان‌دهی، فیلتر و دسته‌بندی هوشمند و ۱۰۰٪ آفلاین پیامک‌ها روی دستگاه شما',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 1),

              // Permission and Privacy Cards
              const PermissionCard(
                icon: Icons.sms_rounded,
                title: 'دسترسی خواندن پیامک‌ها',
                description:
                    'فقط برای خواندن و دسته‌بندی خودکار پیام‌های صندوق ورودی دستگاه.',
              ),
              const SizedBox(height: 12),
              const PermissionCard(
                icon: Icons.contacts_rounded,
                title: 'دسترسی به مخاطبین',
                description:
                    'برای تشخیص فرستنده‌های شخصی ذخیره‌شده و تفکیک از شماره‌های ناشناس.',
              ),
              const SizedBox(height: 12),
              const PermissionCard(
                icon: Icons.security_rounded,
                title: 'امنیت و حریم خصوصی آفلاین',
                description:
                    'هیچ پیامی هرگز از دستگاه شما خارج نمی‌شود و به هیچ سروری ارسال نخواهد شد.',
              ),

              const Spacer(flex: 2),

              // Action button to proceed
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed: _isLoading ? null : _handlePermissionRequest,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.arrow_back), // RTL direction: arrow_back points forward
                  label: Text(
                    _isLoading ? 'در حال بررسی...' : 'تایید دسترسی و شروع',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
