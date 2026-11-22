import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../widgets/permission_card.dart';

/// Welcome / Onboarding page shown on initial launch.
///
/// Clearly explains to the user:
/// 1. Why SMS read access is required
/// 2. Why Contacts access is needed (to classify known vs unknown)
/// 3. Strict offline and on-device privacy guarantee
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

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
                  onPressed: () {
                    context.go(AppRouter.homePath);
                  },
                  icon: const Icon(Icons.arrow_back), // RTL direction: arrow_back points forward
                  label: const Text(
                    'شروع کنید',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
