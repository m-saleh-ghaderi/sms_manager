import 'package:flutter/material.dart';

import '../../domain/entities/category_info.dart';
import '../theme/app_colors.dart';

/// Application-wide constants and mock data.
///
/// Contains the list of all 15 message categories defined in the
/// project specification. In future phases, these will be replaced
/// by real data from the database; the [CategoryInfo] entity will
/// remain the same (Liskov Substitution Principle).
abstract final class AppConstants {
  /// App display name.
  static const String appName = 'مدیریت پیامک';

  /// Mock categories matching the project document's 15 categories.
  /// Order: auto categories first, then virtual, then user categories.
  static const List<CategoryInfo> mockCategories = [
    // ── Automatic categories ──
    CategoryInfo(
      id: 'contacts',
      name: 'مخاطبین',
      icon: Icons.people_rounded,
      color: AppColors.contacts,
      messageCount: 45,
      unreadCount: 3,
    ),
    CategoryInfo(
      id: 'unknown',
      name: 'ناشناس',
      icon: Icons.person_off_rounded,
      color: AppColors.unknown,
      messageCount: 12,
      unreadCount: 5,
    ),
    CategoryInfo(
      id: 'bank',
      name: 'بانکی',
      icon: Icons.account_balance_rounded,
      color: AppColors.bank,
      messageCount: 230,
      unreadCount: 2,
    ),
    CategoryInfo(
      id: 'otp',
      name: 'کد تأیید',
      icon: Icons.pin_rounded,
      color: AppColors.otp,
      messageCount: 89,
      unreadCount: 1,
    ),
    CategoryInfo(
      id: 'promo',
      name: 'تبلیغاتی',
      icon: Icons.campaign_rounded,
      color: AppColors.promo,
      messageCount: 567,
      unreadCount: 120,
    ),
    CategoryInfo(
      id: 'discount',
      name: 'تخفیف‌ها',
      icon: Icons.local_offer_rounded,
      color: AppColors.discount,
      messageCount: 34,
      unreadCount: 8,
    ),
    CategoryInfo(
      id: 'order',
      name: 'سفارش و مرسوله',
      icon: Icons.local_shipping_rounded,
      color: AppColors.order,
      messageCount: 28,
      unreadCount: 0,
    ),
    CategoryInfo(
      id: 'bill',
      name: 'قبوض',
      icon: Icons.receipt_long_rounded,
      color: AppColors.bill,
      messageCount: 15,
      unreadCount: 1,
    ),
    CategoryInfo(
      id: 'travel',
      name: 'سفر و رزرو',
      icon: Icons.flight_rounded,
      color: AppColors.travel,
      messageCount: 7,
      unreadCount: 0,
    ),
    CategoryInfo(
      id: 'government',
      name: 'خدمات دولتی',
      icon: Icons.assured_workload_rounded,
      color: AppColors.government,
      messageCount: 19,
      unreadCount: 2,
    ),
    CategoryInfo(
      id: 'operator',
      name: 'اپراتور',
      icon: Icons.sim_card_rounded,
      color: AppColors.operatorColor,
      messageCount: 78,
      unreadCount: 4,
    ),
    CategoryInfo(
      id: 'suspicious',
      name: 'مشکوک',
      icon: Icons.warning_amber_rounded,
      color: AppColors.suspicious,
      messageCount: 23,
      unreadCount: 15,
    ),

    // ── Virtual category ──
    CategoryInfo(
      id: 'recent',
      name: 'آخرین پیام‌ها',
      icon: Icons.schedule_rounded,
      color: AppColors.recent,
      messageCount: 50,
      unreadCount: 10,
    ),

    // ── User categories ──
    CategoryInfo(
      id: 'starred',
      name: 'نشان‌دار',
      icon: Icons.star_rounded,
      color: AppColors.starred,
      messageCount: 5,
      unreadCount: 0,
    ),
    CategoryInfo(
      id: 'pinned',
      name: 'مهم / پین‌شده',
      icon: Icons.push_pin_rounded,
      color: AppColors.pinned,
      messageCount: 3,
      unreadCount: 0,
    ),
  ];
}
