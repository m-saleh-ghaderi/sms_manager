import 'package:flutter/material.dart';

/// Top search bar widget for the home screen.
///
/// Encapsulates the Material 3 search bar look-and-feel with RTL support.
class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({
    super.key,
    this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: SearchBar(
        hintText: 'جستجوی پیام‌ها، شماره یا کلمات کلیدی...',
        leading: const Icon(Icons.search),
        trailing: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'فیلترها',
            onPressed: () {
              // Filters placeholder for upcoming phases
            },
          ),
        ],
        onTap: onTap,
      ),
    );
  }
}
