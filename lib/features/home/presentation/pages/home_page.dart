import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../widgets/category_grid.dart';
import '../widgets/home_search_bar.dart';

/// Home page displaying category grid with search and quick filters.
///
/// Implements Presentation layer of the Home feature, keeping UI decoupled
/// from data sources by using domain entities and constants.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Selected SIM card filter: null = all, 1 = SIM 1, 2 = SIM 2
  int? _selectedSim;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          // SIM card filter menu (Requirement: dual-SIM support)
          PopupMenuButton<int?>(
            icon: Badge(
              isLabelVisible: _selectedSim != null,
              label: Text('$_selectedSim'),
              child: const Icon(Icons.sim_card_outlined),
            ),
            tooltip: 'فیلتر سیم‌کارت',
            initialValue: _selectedSim,
            onSelected: (sim) {
              setState(() {
                _selectedSim = sim;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('هر دو سیم‌کارت'),
              ),
              const PopupMenuItem(
                value: 1,
                child: Text('سیم‌کارت ۱'),
              ),
              const PopupMenuItem(
                value: 2,
                child: Text('سیم‌کارت ۲'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'همگام‌سازی پیام‌ها',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('همگام‌سازی پیام‌ها در فاز بعدی فعال می‌شود'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            const HomeSearchBar(),

            // Active SIM Indicator banner if filtered
            if (_selectedSim != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Chip(
                      avatar: const Icon(Icons.filter_alt, size: 16),
                      label: Text('نمایش سیم‌کارت $_selectedSim'),
                      onDeleted: () {
                        setState(() {
                          _selectedSim = null;
                        });
                      },
                    ),
                  ],
                ),
              ),

            // Grid of Categories
            const Expanded(
              child: CategoryGrid(
                categories: AppConstants.mockCategories,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
